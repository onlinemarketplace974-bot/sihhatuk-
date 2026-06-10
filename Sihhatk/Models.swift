import Foundation

enum AppLanguage: String, Codable, CaseIterable, Identifiable {
    case en
    case ar

    var id: String { rawValue }
    var isRightToLeft: Bool { self == .ar }
    var localeIdentifier: String { self == .ar ? "ar" : "en_US" }
}

enum AppTheme: String, Codable, CaseIterable {
    case light
    case dark
}

enum Gender: String, Codable, CaseIterable, Identifiable {
    case male
    case female
    case other

    var id: String { rawValue }

    func title(_ strings: AppStrings) -> String {
        switch self {
        case .male:
            return strings.maleOpt
        case .female:
            return strings.femaleOpt
        case .other:
            return strings.otherOpt
        }
    }
}

enum ExerciseLevel: String, Codable, CaseIterable, Identifiable {
    case none
    case light
    case moderate
    case heavy

    var id: String { rawValue }

    func title(_ strings: AppStrings) -> String {
        switch self {
        case .none:
            return strings.exNone
        case .light:
            return strings.exLight
        case .moderate:
            return strings.exMod
        case .heavy:
            return strings.exHeavy
        }
    }
}

struct UserAccount: Codable, Equatable, Identifiable {
    var email: String
    var name: String

    var id: String { email.lowercased() }
}

struct RegisteredUser: Codable, Equatable, Identifiable {
    var email: String
    var name: String
    var password: String

    var id: String { email.lowercased() }
}

struct UserProfile: Codable, Equatable {
    var name: String
    var age: Int
    var gender: Gender
    var dailyCalorieTarget: Int
    var exercise: ExerciseLevel
    var goesToGym: Bool
    var followsDiet: Bool
    var favoriteFoods: String
}

struct SuggestedRecipe: Codable, Identifiable {
    var recipeName: String
    var source: String
    var calories: Int
    var benefits: String
    var ingredients: [String]
    var instructions: String

    var id: String { recipeName + source }
}

struct FoodAnalysis: Codable {
    var foodName: String
    var confidence: String
    var calories: Int
    var carbohydrates: Int
    var protein: Int
    var fat: Int
    var fiber: Int?
    var sugar: Int?
    var sodium: Int?
    var nutritionalSummary: String
    var nutritionalHighlights: [String]
    var healthScore: Int
    var suggestedRecipes: [SuggestedRecipe]
}

struct HistoryItem: Codable, Identifiable {
    var id: UUID
    var dateTime: Date
    var imageData: Data?
    var foodAnalysis: FoodAnalysis
}

enum AuthError: LocalizedError {
    case missingFields
    case termsRequired
    case alreadyRegistered
    case passwordMismatch

    var errorDescription: String? {
        switch self {
        case .missingFields:
            return "Please fill in all required fields."
        case .termsRequired:
            return "Please agree to the Terms & Conditions first."
        case .alreadyRegistered:
            return "This account is already registered."
        case .passwordMismatch:
            return "The password does not match this account."
        }
    }
}

extension Date {
    func formattedLogDate(language: AppLanguage) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: language.localeIdentifier)
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}
