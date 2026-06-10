import SwiftUI
import PhotosUI
import UIKit

private let sihhatkGreen = Color(red: 0.06, green: 0.66, blue: 0.46)

private enum AuthMode {
    case welcome
    case login
    case register
}

private enum DashboardTab: CaseIterable {
    case scan
    case history
    case profile

    func title(_ strings: AppStrings) -> String {
        switch self {
        case .scan:
            return strings.navHome
        case .history:
            return strings.navHistory
        case .profile:
            return strings.navProfile
        }
    }

    var icon: String {
        switch self {
        case .scan:
            return "camera.viewfinder"
        case .history:
            return "clock.arrow.circlepath"
        case .profile:
            return "person.crop.circle"
        }
    }
}

struct RootView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            Group {
                if store.activeUser == nil {
                    AuthView()
                } else if store.profile == nil {
                    OnboardingView(initialName: store.activeUser?.name ?? "")
                } else {
                    DashboardView()
                }
            }
            .environment(\.layoutDirection, store.language.isRightToLeft ? .rightToLeft : .leftToRight)
        }
        .tint(sihhatkGreen)
    }
}

private struct AuthView: View {
    @EnvironmentObject private var store: AppStore
    @State private var mode: AuthMode = .welcome
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var termsAccepted = false
    @State private var errorMessage = ""

    var body: some View {
        let strings = store.strings

        ScrollView {
            VStack(spacing: 24) {
                HStack {
                    BrandMark()
                    Spacer()
                    Button {
                        store.toggleLanguage()
                    } label: {
                        Label(store.language == .en ? "العربية" : "EN", systemImage: "globe")
                            .font(.footnote.weight(.semibold))
                    }
                    .buttonStyle(.bordered)
                }

                switch mode {
                case .welcome:
                    welcomeContent(strings)
                case .login:
                    loginContent(strings)
                case .register:
                    registerContent(strings)
                }

                Text(strings.acceptNotice)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
            }
            .padding(20)
            .frame(maxWidth: 520)
            .frame(maxWidth: .infinity)
        }
    }

    private func welcomeContent(_ strings: AppStrings) -> some View {
        VStack(spacing: 22) {
            VStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(sihhatkGreen)
                    Text("ص")
                        .font(.system(size: 38, weight: .black))
                        .foregroundStyle(.white)
                }
                .frame(width: 76, height: 76)

                Text(strings.welcomeTitle)
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)

                Text(strings.welcomeSubtitle)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
            .padding(.top, 40)

            VStack(spacing: 12) {
                Button(strings.getStarted) {
                    mode = .register
                    errorMessage = ""
                }
                .buttonStyle(PrimaryButtonStyle())

                Button(strings.loginTitle) {
                    mode = .login
                    errorMessage = ""
                }
                .buttonStyle(SecondaryButtonStyle())

                Button(strings.guestUser) {
                    store.continueAsGuest()
                }
                .font(.footnote.weight(.semibold))
            }
        }
    }

    private func loginContent(_ strings: AppStrings) -> some View {
        VStack(spacing: 16) {
            ScreenTitle(title: strings.loginTitle, subtitle: strings.loginSubtitle)
            errorBanner

            FormField(title: strings.emailLabel, systemImage: "envelope", text: $email, keyboard: .emailAddress)
            SecureFormField(title: strings.passwordLabel, text: $password)

            Button(strings.loginBtn) {
                do {
                    try store.signIn(email: email, password: password)
                } catch {
                    errorMessage = localizedError(error)
                }
            }
            .buttonStyle(PrimaryButtonStyle())

            Button(strings.dontHaveAccount) {
                mode = .register
                errorMessage = ""
            }
            .font(.footnote.weight(.semibold))
        }
        .padding(.top, 32)
    }

    private func registerContent(_ strings: AppStrings) -> some View {
        VStack(spacing: 14) {
            ScreenTitle(title: strings.registerTitle, subtitle: strings.registerSubtitle)
            errorBanner

            FormField(title: strings.nameLabel, systemImage: "person", text: $name)
            FormField(title: strings.emailLabel, systemImage: "envelope", text: $email, keyboard: .emailAddress)
            SecureFormField(title: strings.passwordLabel, text: $password)

            VStack(alignment: .leading, spacing: 10) {
                Label(strings.termsTitle, systemImage: "shield.checkered")
                    .font(.footnote.bold())
                    .foregroundStyle(sihhatkGreen)

                Text(strings.termsBody)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineSpacing(2)

                Toggle(strings.acceptTerms, isOn: $termsAccepted)
                    .font(.caption.weight(.semibold))
            }
            .padding()
            .background(CardBackground())

            Button(strings.registerBtn) {
                do {
                    try store.register(name: name, email: email, password: password, termsAccepted: termsAccepted)
                } catch {
                    errorMessage = localizedError(error)
                }
            }
            .buttonStyle(PrimaryButtonStyle())

            Button(strings.alreadyHaveAccount) {
                mode = .login
                errorMessage = ""
            }
            .font(.footnote.weight(.semibold))
        }
    }

    @ViewBuilder
    private var errorBanner: some View {
        if !errorMessage.isEmpty {
            Text(errorMessage)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.red)
                .multilineTextAlignment(.center)
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }

    private func localizedError(_ error: Error) -> String {
        guard store.language == .ar, let authError = error as? AuthError else {
            return error.localizedDescription
        }

        switch authError {
        case .missingFields:
            return "يرجى تعبئة جميع الحقول المطلوبة."
        case .termsRequired:
            return "يرجى الموافقة على الشروط أولًا."
        case .alreadyRegistered:
            return "هذا الحساب مسجل مسبقًا."
        case .passwordMismatch:
            return "كلمة المرور غير مطابقة لهذا الحساب."
        }
    }
}

private struct OnboardingView: View {
    @EnvironmentObject private var store: AppStore
    @State private var step = 1
    @State private var name: String
    @State private var age = 25
    @State private var gender: Gender = .male
    @State private var calorieTarget = 2000
    @State private var exercise: ExerciseLevel = .moderate
    @State private var goesToGym = false
    @State private var followsDiet = false
    @State private var favoriteFoods = ""

    private let totalSteps = 4

    init(initialName: String) {
        _name = State(initialValue: initialName)
    }

    var body: some View {
        let strings = store.strings

        VStack(spacing: 18) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(strings.questionsTitle)
                        .font(.footnote.bold())
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(step) / \(totalSteps)")
                        .font(.caption.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(sihhatkGreen.opacity(0.12), in: Capsule())
                        .foregroundStyle(sihhatkGreen)
                }

                ProgressView(value: Double(step), total: Double(totalSteps))
            }

            ScrollView {
                VStack(spacing: 18) {
                    switch step {
                    case 1:
                        profileStep(strings)
                    case 2:
                        calorieStep(strings)
                    case 3:
                        exerciseStep(strings)
                    default:
                        tasteStep(strings)
                    }
                }
                .padding(.vertical, 10)
            }

            HStack(spacing: 12) {
                if step > 1 {
                    Button(strings.back) {
                        withAnimation { step -= 1 }
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }

                Button(step == totalSteps ? strings.submitProfile : strings.next) {
                    if step < totalSteps {
                        withAnimation { step += 1 }
                    } else {
                        completeProfile()
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
        .padding(20)
    }

    private func profileStep(_ strings: AppStrings) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "target")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 68, height: 68)
                .background(sihhatkGreen, in: Circle())

            ScreenTitle(
                title: store.language == .ar ? "أهلاً بك، لنتعرف عليك" : "Hi, let's get acquainted",
                subtitle: strings.questionsSubtitle
            )

            FormField(title: strings.nameLabel, systemImage: "person", text: $name)

            VStack(alignment: .leading, spacing: 8) {
                Text(strings.ageLabel)
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                TextField(strings.ageLabel, value: $age, format: .number)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
            }
        }
    }

    private func calorieStep(_ strings: AppStrings) -> some View {
        VStack(spacing: 18) {
            ScreenTitle(title: strings.genderLabel, subtitle: strings.calorieTargetLabel)

            HStack(spacing: 10) {
                ForEach(Gender.allCases) { item in
                    SelectionTile(title: item.title(strings), isSelected: gender == item) {
                        gender = item
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(strings.calorieTargetLabel)
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)

                HStack(spacing: 10) {
                    TextField(strings.calorieTargetLabel, value: $calorieTarget, format: .number)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)

                    Button {
                        autoCalculateCalories()
                    } label: {
                        Label(store.language == .ar ? "حساب" : "Auto", systemImage: "sparkles")
                            .labelStyle(.iconOnly)
                            .font(.headline)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.borderedProminent)
                }

                Text(store.language == .ar ? "يتم تقدير السعرات حسب العمر والجنس والنشاط." : "Estimated from age, gender, and activity level.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func exerciseStep(_ strings: AppStrings) -> some View {
        VStack(spacing: 14) {
            ScreenTitle(title: strings.exerciseLabel, subtitle: strings.questionsSubtitle)

            ForEach(ExerciseLevel.allCases) { level in
                Button {
                    exercise = level
                } label: {
                    HStack {
                        Text(level.title(strings))
                            .font(.callout.weight(.semibold))
                            .multilineTextAlignment(store.language.isRightToLeft ? .trailing : .leading)
                        Spacer()
                        if exercise == level {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(sihhatkGreen)
                        }
                    }
                    .padding()
                    .background(CardBackground(isSelected: exercise == level))
                }
                .buttonStyle(.plain)
            }

            Toggle(strings.gymLabel, isOn: $goesToGym)
                .font(.callout.weight(.semibold))
                .padding()
                .background(CardBackground())
        }
    }

    private func tasteStep(_ strings: AppStrings) -> some View {
        VStack(spacing: 16) {
            ScreenTitle(
                title: store.language == .ar ? "الأهداف والأطعمة المفضلة" : "Daily Diet & Taste",
                subtitle: strings.warningSensitive
            )

            Toggle(strings.dietLabel, isOn: $followsDiet)
                .font(.callout.weight(.semibold))
                .padding()
                .background(CardBackground())

            VStack(alignment: .leading, spacing: 8) {
                Text(strings.favFoodsLabel)
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                TextField(
                    store.language == .ar ? "مثال: الحمص، الدجاج، السلطات" : "e.g. hummus, grilled chicken, salads",
                    text: $favoriteFoods,
                    axis: .vertical
                )
                .lineLimit(2...4)
                .textFieldStyle(.roundedBorder)
            }

            Label(strings.warningSensitive, systemImage: "exclamationmark.shield")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.red)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }

    private func autoCalculateCalories() {
        var base = gender == .male ? 1800 : gender == .female ? 1600 : 1700
        switch exercise {
        case .none:
            base += 100
        case .light:
            base += 350
        case .moderate:
            base += 600
        case .heavy:
            base += 900
        }
        if goesToGym { base += 250 }
        if age < 30 { base += 100 }
        if age > 50 { base -= 150 }
        calorieTarget = base
    }

    private func completeProfile() {
        let profile = UserProfile(
            name: name.isEmpty ? (store.language == .ar ? "صديق صحتك" : "Nutrition Friend") : name,
            age: max(1, age),
            gender: gender,
            dailyCalorieTarget: max(900, calorieTarget),
            exercise: exercise,
            goesToGym: goesToGym,
            followsDiet: followsDiet,
            favoriteFoods: favoriteFoods
        )
        store.completeProfile(profile)
    }
}

private struct DashboardView: View {
    @EnvironmentObject private var store: AppStore
    @State private var activeTab: DashboardTab = .scan
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var showCamera = false
    @State private var isAnalyzing = false
    @State private var analysisError = ""
    @State private var activeAnalysis: FoodAnalysis?
    @State private var showResult = false

    private let analysisService = FoodAnalysisService()

    var body: some View {
        VStack(spacing: 0) {
            appHeader

            ScrollView {
                VStack(spacing: 18) {
                    switch activeTab {
                    case .scan:
                        scanContent
                    case .history:
                        historyContent
                    case .profile:
                        if let profile = store.profile {
                            ProfileEditView(profile: profile)
                        }
                    }
                }
                .padding(18)
            }

            tabBar
        }
        .sheet(isPresented: $showCamera) {
            CameraPicker(imageData: $selectedImageData)
                .ignoresSafeArea()
        }
        .sheet(isPresented: $showResult) {
            if let activeAnalysis {
                ResultSheet(analysis: activeAnalysis)
            }
        }
        .onChange(of: selectedPhoto) { item in
            loadPhoto(item)
        }
    }

    private var appHeader: some View {
        HStack(spacing: 12) {
            BrandMark()

            VStack(alignment: .leading, spacing: 2) {
                Text(store.language == .ar ? "صحتك الذكي" : "Sihhatk AI")
                    .font(.headline.bold())
                Text(store.language == .ar ? "ذاكرة التطبيق مفعّلة" : "App memory active")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                store.toggleTheme()
            } label: {
                Image(systemName: store.theme == .dark ? "sun.max" : "moon")
            }
            .buttonStyle(.borderless)

            Button {
                store.toggleLanguage()
            } label: {
                Text(store.language == .en ? "AR" : "EN")
                    .font(.footnote.bold())
            }
            .buttonStyle(.borderless)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(.background)
    }

    private var scanContent: some View {
        let strings = store.strings
        let profile = store.profile
        let consumed = consumedCaloriesToday
        let target = max(profile?.dailyCalorieTarget ?? 1, 1)
        let remaining = max(0, target - consumed)
        let percent = min(1, Double(consumed) / Double(target))

        return VStack(spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(strings.hiGreeting)
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    Text(profile?.name ?? "")
                        .font(.title3.bold())
                }
                Spacer()
                Label("Score", systemImage: "medal")
                    .font(.caption.bold())
                    .foregroundStyle(.orange)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(.orange.opacity(0.12), in: Capsule())
            }

            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(strings.trackerTitle)
                            .font(.headline)
                        Text(strings.trackerSubtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)
                }

                ProgressView(value: percent)

                HStack(spacing: 10) {
                    MetricTile(title: strings.dailyGoal, value: "\(target)")
                    MetricTile(title: strings.eaten, value: "\(consumed)", color: sihhatkGreen)
                    MetricTile(title: strings.remaining, value: "\(remaining)", color: .orange)
                }
            }
            .padding()
            .background(CardBackground())

            VStack(spacing: 14) {
                ScreenTitle(title: strings.uploadTitle, subtitle: strings.uploadDesc)

                imagePreview

                HStack(spacing: 10) {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Label(strings.uploadBtn, systemImage: "photo")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SecondaryButtonStyle())

                    Button {
                        showCamera = true
                    } label: {
                        Image(systemName: "camera")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }

                if !analysisError.isEmpty {
                    Text(analysisError)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .background(.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                }

                if isAnalyzing {
                    VStack(spacing: 10) {
                        ProgressView()
                        Text(strings.analyzingLoader)
                            .font(.footnote.weight(.semibold))
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                } else {
                    Button(strings.analyzeBtn) {
                        analyzeSelectedMeal()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(selectedImageData == nil)

                    Button(store.language == .ar ? "تشغيل تحليل تجريبي" : "Run Demo Analysis") {
                        runDemoAnalysis()
                    }
                    .font(.footnote.weight(.semibold))
                }

                Label(strings.warningSensitive, systemImage: "shield.lefthalf.filled")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(CardBackground())
        }
    }

    @ViewBuilder
    private var imagePreview: some View {
        if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
            ZStack(alignment: .topTrailing) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 220)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                Button {
                    self.selectedImageData = nil
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(.black.opacity(0.65), in: Circle())
                }
                .padding(10)
            }
        } else {
            VStack(spacing: 10) {
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(sihhatkGreen)
                Text(store.strings.uploadBtn)
                    .font(.footnote.bold())
                Text("JPEG / PNG")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(height: 180)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [8]))
                    .foregroundStyle(.secondary.opacity(0.35))
            )
        }
    }

    private var historyContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(store.strings.historyTitle)
                    .font(.title3.bold())
                Spacer()
                if !store.history.isEmpty {
                    Button(role: .destructive) {
                        store.clearHistory()
                    } label: {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.borderless)
                }
            }

            if store.history.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text(store.strings.emptyHistory)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(36)
                .frame(maxWidth: .infinity)
                .background(CardBackground())
            } else {
                ForEach(store.history) { item in
                    HStack(spacing: 12) {
                        MealThumbnail(data: item.imageData)
                        VStack(alignment: .leading, spacing: 5) {
                            Text(item.foodAnalysis.foodName)
                                .font(.callout.bold())
                                .lineLimit(2)
                            Text("\(store.strings.loggedAt) \(item.dateTime.formattedLogDate(language: store.language))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("\(item.foodAnalysis.calories) \(store.strings.caloriesKcal) • Score \(item.foodAnalysis.healthScore)")
                                .font(.caption.bold())
                                .foregroundStyle(sihhatkGreen)
                        }
                        Spacer()
                        Button(role: .destructive) {
                            store.deleteHistoryItem(item)
                        } label: {
                            Image(systemName: "trash")
                        }
                        .buttonStyle(.borderless)
                    }
                    .padding()
                    .background(CardBackground())
                    .onTapGesture {
                        activeAnalysis = item.foodAnalysis
                        showResult = true
                    }
                }
            }
        }
    }

    private var tabBar: some View {
        HStack {
            ForEach(DashboardTab.allCases, id: \.self) { tab in
                Button {
                    activeTab = tab
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.headline)
                        Text(tab.title(store.strings))
                            .font(.caption2.bold())
                    }
                    .foregroundStyle(activeTab == tab ? sihhatkGreen : .secondary)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 10)
        .padding(.bottom, 8)
        .padding(.horizontal)
        .background(.background)
    }

    private var consumedCaloriesToday: Int {
        store.history
            .filter { Calendar.current.isDateInToday($0.dateTime) }
            .reduce(0) { $0 + $1.foodAnalysis.calories }
    }

    private func loadPhoto(_ item: PhotosPickerItem?) {
        guard let item else { return }
        Task { @MainActor in
            if let data = try? await item.loadTransferable(type: Data.self) {
                selectedImageData = data
                analysisError = ""
            }
        }
    }

    private func analyzeSelectedMeal() {
        guard let selectedImageData, let profile = store.profile else { return }
        isAnalyzing = true
        analysisError = ""

        Task { @MainActor in
            do {
                let analysis = try await analysisService.analyze(imageData: selectedImageData, language: store.language, profile: profile)
                store.addHistory(imageData: selectedImageData, analysis: analysis)
                activeAnalysis = analysis
                showResult = true
            } catch {
                analysisError = store.language == .ar ? "تعذر تحليل الوجبة. تحقق من الاتصال أو مفتاح Gemini." : error.localizedDescription
            }
            isAnalyzing = false
        }
    }

    private func runDemoAnalysis() {
        let analysis = FoodAnalysisService.sampleAnalysis(language: store.language)
        store.addHistory(imageData: nil, analysis: analysis)
        activeAnalysis = analysis
        showResult = true
    }
}

private struct ProfileEditView: View {
    @EnvironmentObject private var store: AppStore
    @State private var name: String
    @State private var age: Int
    @State private var calorieTarget: Int
    @State private var exercise: ExerciseLevel
    @State private var goesToGym: Bool
    @State private var followsDiet: Bool
    @State private var favoriteFoods: String
    @State private var message = ""

    private let gender: Gender

    init(profile: UserProfile) {
        _name = State(initialValue: profile.name)
        _age = State(initialValue: profile.age)
        _calorieTarget = State(initialValue: profile.dailyCalorieTarget)
        _exercise = State(initialValue: profile.exercise)
        _goesToGym = State(initialValue: profile.goesToGym)
        _followsDiet = State(initialValue: profile.followsDiet)
        _favoriteFoods = State(initialValue: profile.favoriteFoods)
        gender = profile.gender
    }

    var body: some View {
        let strings = store.strings

        VStack(alignment: .leading, spacing: 16) {
            Text(strings.profileTitle)
                .font(.title3.bold())

            if !message.isEmpty {
                Text(message)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(sihhatkGreen)
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .background(sihhatkGreen.opacity(0.1), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            }

            VStack(spacing: 14) {
                FormField(title: strings.nameLabel, systemImage: "person", text: $name)

                HStack(spacing: 12) {
                    NumberField(title: strings.ageLabel, value: $age)
                    NumberField(title: strings.calorieTargetLabel, value: $calorieTarget)
                }

                Picker(strings.exerciseLabel, selection: $exercise) {
                    ForEach(ExerciseLevel.allCases) { level in
                        Text(level.title(strings)).tag(level)
                    }
                }
                .pickerStyle(.menu)

                Toggle(strings.gymLabel, isOn: $goesToGym)
                Toggle(strings.dietLabel, isOn: $followsDiet)

                FormField(title: strings.favFoodsLabel, systemImage: "fork.knife", text: $favoriteFoods)
            }
            .padding()
            .background(CardBackground())

            Button(strings.saveBtn) {
                let updated = UserProfile(
                    name: name.isEmpty ? "User" : name,
                    age: max(1, age),
                    gender: gender,
                    dailyCalorieTarget: max(900, calorieTarget),
                    exercise: exercise,
                    goesToGym: goesToGym,
                    followsDiet: followsDiet,
                    favoriteFoods: favoriteFoods
                )
                store.updateProfile(updated)
                message = strings.profileSaved
            }
            .buttonStyle(PrimaryButtonStyle())

            Button(role: .destructive) {
                store.logout()
            } label: {
                Label(strings.logoutBtn, systemImage: "rectangle.portrait.and.arrow.right")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }
}

private struct ResultSheet: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    let analysis: FoodAnalysis

    var body: some View {
        let strings = store.strings

        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    VStack(spacing: 10) {
                        Text(analysis.foodName)
                            .font(.title3.bold())
                            .multilineTextAlignment(.center)

                        HStack(spacing: 24) {
                            ScoreBlock(value: analysis.healthScore, title: strings.healthScore, color: sihhatkGreen)
                            ScoreBlock(value: analysis.calories, title: strings.caloriesKcal, color: .orange)
                        }

                        HStack {
                            Text("\(strings.confidenceLabel): \(analysis.confidence)")
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)
                        }

                        FlowTags(tags: analysis.nutritionalHighlights)
                    }
                    .padding()
                    .background(CardBackground())

                    HStack(spacing: 10) {
                        MacroCard(title: strings.carbsLabel, value: analysis.carbohydrates, color: .orange)
                        MacroCard(title: strings.proteinLabel, value: analysis.protein, color: sihhatkGreen)
                        MacroCard(title: strings.fatLabel, value: analysis.fat, color: .red)
                    }

                    HStack(spacing: 10) {
                        MicroCard(title: strings.fiberLabel, value: "\(analysis.fiber ?? 0)g")
                        MicroCard(title: strings.sugarLabel, value: "\(analysis.sugar ?? 0)g")
                        MicroCard(title: strings.sodiumLabel, value: "\(analysis.sodium ?? 0)mg")
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text(strings.insightsTitle)
                            .font(.headline)
                        Text(analysis.nutritionalSummary)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .lineSpacing(3)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(CardBackground())

                    VStack(alignment: .leading, spacing: 12) {
                        Label(strings.recipeTitle, systemImage: "leaf")
                            .font(.headline)
                            .foregroundStyle(sihhatkGreen)

                        ForEach(analysis.suggestedRecipes) { recipe in
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(alignment: .top) {
                                    Text(recipe.recipeName)
                                        .font(.headline)
                                    Spacer()
                                    Text("\(recipe.calories) kcal")
                                        .font(.caption.bold())
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 5)
                                        .background(sihhatkGreen, in: Capsule())
                                        .foregroundStyle(.white)
                                }

                                Text(recipe.benefits)
                                    .font(.callout)
                                    .foregroundStyle(.secondary)

                                Text("\(strings.recipeSource): \(recipe.source)")
                                    .font(.caption.bold())
                                    .foregroundStyle(sihhatkGreen)

                                VStack(alignment: .leading, spacing: 5) {
                                    Text(strings.ingredientsTitle)
                                        .font(.caption.bold())
                                    ForEach(recipe.ingredients, id: \.self) { item in
                                        Text("• \(item)")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }

                                VStack(alignment: .leading, spacing: 5) {
                                    Text(strings.instructionsTitle)
                                        .font(.caption.bold())
                                    Text(recipe.instructions)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding()
                            .background(CardBackground())
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(strings.resultTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(strings.closeBtn) {
                        dismiss()
                    }
                }
            }
        }
    }
}

private struct BrandMark: View {
    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(sihhatkGreen)
                Text("ص")
                    .font(.headline.bold())
                    .foregroundStyle(.white)
            }
            .frame(width: 34, height: 34)

            Text("Sihhatk")
                .font(.headline.bold())
        }
    }
}

private struct ScreenTitle: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.title2.bold())
                .multilineTextAlignment(.center)
            Text(subtitle)
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
    }
}

private struct FormField: View {
    let title: String
    let systemImage: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            HStack {
                Image(systemName: systemImage)
                    .foregroundStyle(.secondary)
                TextField(title, text: $text)
                    .keyboardType(keyboard)
                    .textInputAutocapitalization(keyboard == .emailAddress ? .never : .words)
                    .autocorrectionDisabled(keyboard == .emailAddress)
            }
            .padding(12)
            .background(CardBackground())
        }
    }
}

private struct SecureFormField: View {
    let title: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            HStack {
                Image(systemName: "lock")
                    .foregroundStyle(.secondary)
                SecureField(title, text: $text)
            }
            .padding(12)
            .background(CardBackground())
        }
    }
}

private struct NumberField: View {
    let title: String
    @Binding var value: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            TextField(title, value: $value, format: .number)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
        }
    }
}

private struct SelectionTile: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.bold())
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(CardBackground(isSelected: isSelected))
        }
        .buttonStyle(.plain)
    }
}

private struct MetricTile: View {
    let title: String
    let value: String
    var color: Color = .primary

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption2.bold())
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            Text(value)
                .font(.headline.bold())
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

private struct MealThumbnail: View {
    let data: Data?

    var body: some View {
        if let data, let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(sihhatkGreen.opacity(0.12))
                Image(systemName: "fork.knife")
                    .foregroundStyle(sihhatkGreen)
            }
            .frame(width: 64, height: 64)
        }
    }
}

private struct ScoreBlock: View {
    let value: Int
    let title: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundStyle(color)
            Text(title)
                .font(.caption2.bold())
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct MacroCard: View {
    let title: String
    let value: Int
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption2.bold())
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text("\(value)g")
                .font(.headline.bold())
                .foregroundStyle(color)
            ProgressView(value: min(1, Double(value) / 100))
                .tint(color)
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .background(CardBackground())
    }
}

private struct MicroCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption2.bold())
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption.bold())
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .background(CardBackground())
    }
}

private struct FlowTags: View {
    let tags: [String]

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: 8)], spacing: 8) {
            ForEach(tags, id: \.self) { tag in
                Text(tag)
                    .font(.caption2.bold())
                    .foregroundStyle(sihhatkGreen)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 6)
                    .background(sihhatkGreen.opacity(0.1), in: Capsule())
            }
        }
    }
}

private struct CardBackground: View {
    var isSelected = false

    var body: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(Color(.secondarySystemGroupedBackground))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isSelected ? sihhatkGreen : Color(.separator).opacity(0.35), lineWidth: isSelected ? 1.5 : 0.5)
            }
    }
}

private struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.callout.weight(.bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(sihhatkGreen.opacity(configuration.isPressed ? 0.78 : 1), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

private struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.callout.weight(.semibold))
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}
