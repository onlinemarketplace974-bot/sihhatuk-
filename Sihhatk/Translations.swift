import Foundation

struct AppStrings {
    let welcomeTitle: String
    let welcomeSubtitle: String
    let getStarted: String
    let loginTitle: String
    let loginSubtitle: String
    let registerTitle: String
    let registerSubtitle: String
    let emailLabel: String
    let passwordLabel: String
    let nameLabel: String
    let loginBtn: String
    let registerBtn: String
    let dontHaveAccount: String
    let alreadyHaveAccount: String
    let guestUser: String
    let termsTitle: String
    let termsBody: String
    let acceptTerms: String
    let next: String
    let back: String
    let questionsTitle: String
    let questionsSubtitle: String
    let ageLabel: String
    let genderLabel: String
    let maleOpt: String
    let femaleOpt: String
    let otherOpt: String
    let calorieTargetLabel: String
    let exerciseLabel: String
    let exNone: String
    let exLight: String
    let exMod: String
    let exHeavy: String
    let gymLabel: String
    let dietLabel: String
    let favFoodsLabel: String
    let submitProfile: String
    let navHome: String
    let navHistory: String
    let navProfile: String
    let hiGreeting: String
    let trackerTitle: String
    let trackerSubtitle: String
    let dailyGoal: String
    let eaten: String
    let remaining: String
    let uploadTitle: String
    let uploadDesc: String
    let uploadBtn: String
    let analyzeBtn: String
    let analyzingLoader: String
    let acceptNotice: String
    let warningSensitive: String
    let resultTitle: String
    let healthScore: String
    let confidenceLabel: String
    let carbsLabel: String
    let proteinLabel: String
    let fatLabel: String
    let fiberLabel: String
    let sugarLabel: String
    let sodiumLabel: String
    let insightsTitle: String
    let recipeTitle: String
    let recipeSource: String
    let ingredientsTitle: String
    let instructionsTitle: String
    let closeBtn: String
    let profileTitle: String
    let languageSelect: String
    let themeToggle: String
    let logoutBtn: String
    let saveBtn: String
    let profileSaved: String
    let historyTitle: String
    let emptyHistory: String
    let caloriesKcal: String
    let loggedAt: String
}

enum Translations {
    static func strings(for language: AppLanguage) -> AppStrings {
        switch language {
        case .en:
            return english
        case .ar:
            return arabic
        }
    }

    static let english = AppStrings(
        welcomeTitle: "Sihhatk Calories",
        welcomeSubtitle: "Identify food, estimate nutrient metrics, and receive healthier meal ideas powered by AI.",
        getStarted: "Begin Health Journey",
        loginTitle: "Sign In",
        loginSubtitle: "Sign in to keep tracking visual calorie logs on this device.",
        registerTitle: "Create Account",
        registerSubtitle: "Register to personalize calories, fitness level, and diet preferences.",
        emailLabel: "Email Address",
        passwordLabel: "Password",
        nameLabel: "Your Name",
        loginBtn: "Sign In",
        registerBtn: "Create My Account",
        dontHaveAccount: "New to Sihhatk? Register here",
        alreadyHaveAccount: "Already have an account? Sign in",
        guestUser: "Continue as Guest",
        termsTitle: "Terms of Service & AI Analysis Agreement",
        termsBody: "Sihhatk analyzes meal photos for health awareness. Upload food images only and avoid sensitive personal content. Results are estimates, not medical advice.",
        acceptTerms: "I agree to the terms and will only upload food images",
        next: "Continue",
        back: "Back",
        questionsTitle: "Personalize Your Coach",
        questionsSubtitle: "Set your fitness parameters so Sihhatk can tailor calorie and meal recommendations.",
        ageLabel: "Your Age",
        genderLabel: "Biological Gender",
        maleOpt: "Male",
        femaleOpt: "Female",
        otherOpt: "Other",
        calorieTargetLabel: "Target Daily Intake (kcal)",
        exerciseLabel: "Daily Exercise Activity",
        exNone: "Sedentary (no sports)",
        exLight: "Light (1-2 days/week)",
        exMod: "Moderate (3-5 days/week)",
        exHeavy: "Heavy athlete (almost daily)",
        gymLabel: "Do you actively go to the gym?",
        dietLabel: "Do you follow a strict diet routine?",
        favFoodsLabel: "Favorite foods",
        submitProfile: "Complete Dashboard Setup",
        navHome: "Scan",
        navHistory: "History",
        navProfile: "Coach",
        hiGreeting: "Welcome to Sihhatk,",
        trackerTitle: "Calorie & Portion Target",
        trackerSubtitle: "Tracked from meal analysis",
        dailyGoal: "Daily Target",
        eaten: "Consumed",
        remaining: "Remaining",
        uploadTitle: "Capture or Upload Meal",
        uploadDesc: "Take a food photo or select from your library to estimate calories and macros.",
        uploadBtn: "Select Food Photo",
        analyzeBtn: "Analyze Meal with AI",
        analyzingLoader: "Sihhatk AI is analyzing portions...",
        acceptNotice: "Safe AI upload active",
        warningSensitive: "Please upload food images only. Avoid sensitive personal content.",
        resultTitle: "Nutritional Appraisal",
        healthScore: "Health Score",
        confidenceLabel: "Detection Confidence",
        carbsLabel: "Carbohydrates",
        proteinLabel: "Protein",
        fatLabel: "Fat",
        fiberLabel: "Fiber",
        sugarLabel: "Sugar",
        sodiumLabel: "Sodium",
        insightsTitle: "Dietary Summary",
        recipeTitle: "Healthier Options & Recipes",
        recipeSource: "Guideline Source",
        ingredientsTitle: "Ingredients",
        instructionsTitle: "Instructions",
        closeBtn: "Done",
        profileTitle: "My Coach Profile",
        languageSelect: "Application Language",
        themeToggle: "Visual Mode",
        logoutBtn: "Exit / Switch Account",
        saveBtn: "Save Changes",
        profileSaved: "Profile details updated successfully!",
        historyTitle: "Visual Food Archive",
        emptyHistory: "No dishes logged yet. Scan your first meal to begin.",
        caloriesKcal: "kcal",
        loggedAt: "Logged on"
    )

    static let arabic = AppStrings(
        welcomeTitle: "صحتك للسعرات",
        welcomeSubtitle: "تعرّف على طعامك، وقدّر العناصر الغذائية، واحصل على أفكار وجبات صحية مدعومة بالذكاء الاصطناعي.",
        getStarted: "ابدأ رحلتك الصحية",
        loginTitle: "تسجيل الدخول",
        loginSubtitle: "سجّل الدخول للاحتفاظ بسجل السعرات والصور على هذا الجهاز.",
        registerTitle: "إنشاء حساب",
        registerSubtitle: "أنشئ حسابًا لتخصيص السعرات ومستوى النشاط وتفضيلات الطعام.",
        emailLabel: "البريد الإلكتروني",
        passwordLabel: "كلمة المرور",
        nameLabel: "الاسم",
        loginBtn: "دخول",
        registerBtn: "إنشاء حسابي",
        dontHaveAccount: "جديد في صحتك؟ أنشئ حسابًا",
        alreadyHaveAccount: "لديك حساب؟ سجّل دخولك",
        guestUser: "المتابعة كزائر",
        termsTitle: "الشروط واتفاقية تحليل الذكاء الاصطناعي",
        termsBody: "يحلل تطبيق صحتك صور الوجبات للتوعية الصحية. ارفع صور الطعام فقط وتجنب أي محتوى شخصي حساس. النتائج تقديرية وليست نصيحة طبية.",
        acceptTerms: "أوافق على الشروط وسأرفع صور الطعام فقط",
        next: "متابعة",
        back: "رجوع",
        questionsTitle: "خصّص مدربك",
        questionsSubtitle: "أدخل بياناتك الصحية ليخصص صحتك السعرات والاقتراحات المناسبة لك.",
        ageLabel: "العمر",
        genderLabel: "الجنس",
        maleOpt: "ذكر",
        femaleOpt: "أنثى",
        otherOpt: "آخر",
        calorieTargetLabel: "هدف السعرات اليومي",
        exerciseLabel: "النشاط الرياضي اليومي",
        exNone: "خامل (لا توجد رياضة)",
        exLight: "خفيف (يوم أو يومان أسبوعيًا)",
        exMod: "متوسط (3-5 أيام أسبوعيًا)",
        exHeavy: "نشاط عالٍ أو تدريب شبه يومي",
        gymLabel: "هل تذهب إلى النادي الرياضي؟",
        dietLabel: "هل تتبع نظامًا غذائيًا صارمًا؟",
        favFoodsLabel: "الأطعمة المفضلة",
        submitProfile: "إكمال إعداد اللوحة",
        navHome: "الفحص",
        navHistory: "السجل",
        navProfile: "المدرب",
        hiGreeting: "أهلاً بك في صحتك،",
        trackerTitle: "هدف السعرات والحصص",
        trackerSubtitle: "يتم تتبعه من تحليل الوجبات",
        dailyGoal: "الهدف اليومي",
        eaten: "المستهلك",
        remaining: "المتبقي",
        uploadTitle: "التقط أو ارفع وجبتك",
        uploadDesc: "التقط صورة طعام أو اختر من مكتبة الصور لتقدير السعرات والعناصر.",
        uploadBtn: "اختيار صورة وجبة",
        analyzeBtn: "تحليل الوجبة بالذكاء الاصطناعي",
        analyzingLoader: "يقوم صحتك بتحليل الحصص...",
        acceptNotice: "رفع آمن بالذكاء الاصطناعي",
        warningSensitive: "يرجى رفع صور الطعام فقط وتجنب المحتوى الشخصي الحساس.",
        resultTitle: "التقييم الغذائي",
        healthScore: "مؤشر الصحة",
        confidenceLabel: "دقة التعرف",
        carbsLabel: "الكربوهيدرات",
        proteinLabel: "البروتين",
        fatLabel: "الدهون",
        fiberLabel: "الألياف",
        sugarLabel: "السكر",
        sodiumLabel: "الصوديوم",
        insightsTitle: "ملخص غذائي",
        recipeTitle: "خيارات ووصفات صحية",
        recipeSource: "مصدر الإرشادات",
        ingredientsTitle: "المكونات",
        instructionsTitle: "طريقة التحضير",
        closeBtn: "تم",
        profileTitle: "ملف المدرب الشخصي",
        languageSelect: "لغة التطبيق",
        themeToggle: "المظهر",
        logoutBtn: "خروج / تبديل الحساب",
        saveBtn: "حفظ التغييرات",
        profileSaved: "تم تحديث بيانات الملف بنجاح!",
        historyTitle: "أرشيف الوجبات",
        emptyHistory: "لم تسجل أي وجبة بعد. افحص وجبتك الأولى للبدء.",
        caloriesKcal: "سعرة",
        loggedAt: "تم التسجيل في"
    )
}
