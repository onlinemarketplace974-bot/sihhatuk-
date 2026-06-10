import Foundation

enum FoodAnalysisServiceError: LocalizedError {
    case invalidURL
    case emptyResponse
    case invalidResponse
    case apiFailure(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The Gemini endpoint could not be created."
        case .emptyResponse:
            return "No analysis was returned."
        case .invalidResponse:
            return "The analysis response could not be decoded."
        case .apiFailure(let message):
            return message
        }
    }
}

final class FoodAnalysisService {
    func analyze(imageData: Data, language: AppLanguage, profile: UserProfile) async throws -> FoodAnalysis {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "GeminiAPIKey") as? String,
              !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            try await Task.sleep(nanoseconds: 800_000_000)
            return Self.sampleAnalysis(language: language)
        }

        let model = (Bundle.main.object(forInfoDictionaryKey: "GeminiModelName") as? String) ?? "gemini-2.0-flash"
        guard let encodedModel = model.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let encodedKey = apiKey.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/\(encodedModel):generateContent?key=\(encodedKey)") else {
            throw FoodAnalysisServiceError.invalidURL
        }

        let body = try makeRequestBody(imageData: imageData, language: language, profile: profile)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            let message = String(data: data, encoding: .utf8) ?? "Gemini request failed."
            throw FoodAnalysisServiceError.apiFailure(message)
        }

        return try decodeGeminiResponse(data)
    }

    private func makeRequestBody(imageData: Data, language: AppLanguage, profile: UserProfile) throws -> Data {
        let userLanguage = language == .ar ? "Arabic" : "English"
        let profileContext = """
        User Profile:
        - Age: \(profile.age)
        - Gender: \(profile.gender.rawValue)
        - Daily calorie target: \(profile.dailyCalorieTarget) kcal
        - Exercise: \(profile.exercise.rawValue)
        - Goes to gym: \(profile.goesToGym ? "yes" : "no")
        - Follows diet: \(profile.followsDiet ? "yes" : "no")
        - Favorite foods: \(profile.favoriteFoods.isEmpty ? "N/A" : profile.favoriteFoods)
        """

        let systemPrompt = """
        You are Sihhatk, a careful nutrition analysis assistant. Analyze the meal image, estimate portions, calories, carbohydrates, protein, fat, fiber, sugar, sodium, a 0-100 health score, and healthier recipe ideas. Return only valid JSON. All user-facing values must be in \(userLanguage).
        """

        let prompt = """
        Analyze this meal photo and tailor the advice to the user.

        \(profileContext)
        """

        let schema: [String: Any] = [
            "type": "object",
            "required": [
                "foodName", "confidence", "calories", "carbohydrates", "protein", "fat",
                "nutritionalSummary", "nutritionalHighlights", "healthScore", "suggestedRecipes"
            ],
            "properties": [
                "foodName": ["type": "string"],
                "confidence": ["type": "string"],
                "calories": ["type": "integer"],
                "carbohydrates": ["type": "integer"],
                "protein": ["type": "integer"],
                "fat": ["type": "integer"],
                "fiber": ["type": "integer"],
                "sugar": ["type": "integer"],
                "sodium": ["type": "integer"],
                "nutritionalSummary": ["type": "string"],
                "nutritionalHighlights": ["type": "array", "items": ["type": "string"]],
                "healthScore": ["type": "integer"],
                "suggestedRecipes": [
                    "type": "array",
                    "items": [
                        "type": "object",
                        "required": ["recipeName", "source", "calories", "benefits", "ingredients", "instructions"],
                        "properties": [
                            "recipeName": ["type": "string"],
                            "source": ["type": "string"],
                            "calories": ["type": "integer"],
                            "benefits": ["type": "string"],
                            "ingredients": ["type": "array", "items": ["type": "string"]],
                            "instructions": ["type": "string"]
                        ]
                    ]
                ]
            ]
        ]

        let requestBody: [String: Any] = [
            "systemInstruction": [
                "parts": [
                    ["text": systemPrompt]
                ]
            ],
            "contents": [
                [
                    "role": "user",
                    "parts": [
                        ["text": prompt],
                        [
                            "inline_data": [
                                "mime_type": "image/jpeg",
                                "data": imageData.base64EncodedString()
                            ]
                        ]
                    ]
                ]
            ],
            "generationConfig": [
                "response_mime_type": "application/json",
                "response_schema": schema
            ]
        ]

        return try JSONSerialization.data(withJSONObject: requestBody, options: [])
    }

    private func decodeGeminiResponse(_ data: Data) throws -> FoodAnalysis {
        let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
        guard let text = geminiResponse.candidates?.first?.content.parts.first?.text else {
            throw FoodAnalysisServiceError.emptyResponse
        }

        let cleaned = cleanJSONText(text)
        guard let jsonData = cleaned.data(using: .utf8) else {
            throw FoodAnalysisServiceError.invalidResponse
        }

        do {
            return try JSONDecoder().decode(FoodAnalysis.self, from: jsonData)
        } catch {
            throw FoodAnalysisServiceError.invalidResponse
        }
    }

    private func cleanJSONText(_ text: String) -> String {
        var cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.hasPrefix("```") {
            cleaned = cleaned
                .replacingOccurrences(of: "```json", with: "")
                .replacingOccurrences(of: "```", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return cleaned
    }

    static func sampleAnalysis(language: AppLanguage) -> FoodAnalysis {
        if language == .ar {
            return FoodAnalysis(
                foodName: "طبق دجاج مشوي مع أرز وخضار",
                confidence: "مرتفعة",
                calories: 620,
                carbohydrates: 68,
                protein: 42,
                fat: 18,
                fiber: 7,
                sugar: 8,
                sodium: 720,
                nutritionalSummary: "الوجبة متوازنة نسبيًا وتحتوي على بروتين جيد من الدجاج وكربوهيدرات متوسطة من الأرز. يمكن تحسينها بزيادة الخضار وتقليل الصلصة المالحة.",
                nutritionalHighlights: ["بروتين مرتفع", "ألياف جيدة", "صوديوم متوسط"],
                healthScore: 78,
                suggestedRecipes: [
                    SuggestedRecipe(
                        recipeName: "وعاء دجاج وخضار مع كينوا",
                        source: "USDA MyPlate",
                        calories: 520,
                        benefits: "يزيد الألياف ويقلل كمية الكربوهيدرات المكررة مع الحفاظ على البروتين.",
                        ingredients: ["صدر دجاج مشوي", "كينوا مطبوخة", "خضار ورقية", "خيار وطماطم", "ليمون وزيت زيتون"],
                        instructions: "اشوِ الدجاج، ثم قدّمه فوق الكينوا والخضار مع تتبيلة خفيفة من الليمون وزيت الزيتون."
                    )
                ]
            )
        }

        return FoodAnalysis(
            foodName: "Grilled Chicken Rice Bowl",
            confidence: "High",
            calories: 620,
            carbohydrates: 68,
            protein: 42,
            fat: 18,
            fiber: 7,
            sugar: 8,
            sodium: 720,
            nutritionalSummary: "This looks like a balanced meal with strong protein from grilled chicken and moderate carbohydrates from rice. It can be improved by increasing vegetables and reducing salty sauces.",
            nutritionalHighlights: ["High Protein", "Good Fiber", "Moderate Sodium"],
            healthScore: 78,
            suggestedRecipes: [
                SuggestedRecipe(
                    recipeName: "Chicken Quinoa Vegetable Bowl",
                    source: "USDA MyPlate",
                    calories: 520,
                    benefits: "Adds fiber and reduces refined carbohydrate density while keeping protein high.",
                    ingredients: ["Grilled chicken breast", "Cooked quinoa", "Leafy greens", "Cucumber and tomato", "Lemon and olive oil"],
                    instructions: "Grill the chicken, serve over quinoa and vegetables, then dress lightly with lemon and olive oil."
                )
            ]
        )
    }
}

private struct GeminiResponse: Decodable {
    var candidates: [Candidate]?

    struct Candidate: Decodable {
        var content: Content
    }

    struct Content: Decodable {
        var parts: [Part]
    }

    struct Part: Decodable {
        var text: String?
    }
}
