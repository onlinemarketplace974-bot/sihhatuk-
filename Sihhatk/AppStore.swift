import Combine
import Foundation

@MainActor
final class AppStore: ObservableObject {
    @Published var language: AppLanguage = .en
    @Published var theme: AppTheme = .light
    @Published var activeUser: UserAccount?
    @Published var profile: UserProfile?
    @Published var history: [HistoryItem] = []

    private var registeredUsers: [RegisteredUser] = []
    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    var strings: AppStrings {
        Translations.strings(for: language)
    }

    init() {
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        loadAppMemory()
    }

    func toggleLanguage() {
        language = language == .en ? .ar : .en
        defaults.set(language.rawValue, forKey: "sihhatk_language")
    }

    func toggleTheme() {
        theme = theme == .light ? .dark : .light
        defaults.set(theme.rawValue, forKey: "sihhatk_theme")
    }

    func continueAsGuest() {
        let guest = UserAccount(email: "guest@sihhatk.com", name: language == .ar ? "زائر صحتك" : "Guest User")
        setActiveUser(guest)
    }

    func signIn(email: String, password: String) throws {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedEmail.isEmpty, !password.isEmpty else {
            throw AuthError.missingFields
        }

        if let registered = registeredUsers.first(where: { $0.email.caseInsensitiveCompare(normalizedEmail) == .orderedSame }) {
            guard registered.password == password else {
                throw AuthError.passwordMismatch
            }
            setActiveUser(UserAccount(email: registered.email, name: registered.name))
        } else {
            let generatedName = normalizedEmail.split(separator: "@").first.map(String.init) ?? "Sihhatk User"
            let newUser = RegisteredUser(email: normalizedEmail, name: generatedName, password: password)
            registeredUsers.append(newUser)
            saveRegisteredUsers()
            setActiveUser(UserAccount(email: normalizedEmail, name: generatedName))
        }
    }

    func register(name: String, email: String, password: String, termsAccepted: Bool) throws {
        let cleanedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanedName.isEmpty, !normalizedEmail.isEmpty, !password.isEmpty else {
            throw AuthError.missingFields
        }
        guard termsAccepted else {
            throw AuthError.termsRequired
        }
        guard !registeredUsers.contains(where: { $0.email.caseInsensitiveCompare(normalizedEmail) == .orderedSame }) else {
            throw AuthError.alreadyRegistered
        }

        let newUser = RegisteredUser(email: normalizedEmail, name: cleanedName, password: password)
        registeredUsers.append(newUser)
        saveRegisteredUsers()
        setActiveUser(UserAccount(email: normalizedEmail, name: cleanedName))
    }

    func completeProfile(_ completedProfile: UserProfile) {
        profile = completedProfile
        saveProfile()
    }

    func updateProfile(_ updatedProfile: UserProfile) {
        profile = updatedProfile
        saveProfile()
    }

    func addHistory(imageData: Data?, analysis: FoodAnalysis) {
        let item = HistoryItem(id: UUID(), dateTime: Date(), imageData: imageData, foodAnalysis: analysis)
        history.insert(item, at: 0)
        saveHistory()
    }

    func deleteHistoryItem(_ item: HistoryItem) {
        history.removeAll { $0.id == item.id }
        saveHistory()
    }

    func clearHistory() {
        history.removeAll()
        saveHistory()
    }

    func logout() {
        activeUser = nil
        profile = nil
        history = []
        defaults.removeObject(forKey: "sihhatk_active_user")
    }

    private func loadAppMemory() {
        if let rawLanguage = defaults.string(forKey: "sihhatk_language"),
           let cachedLanguage = AppLanguage(rawValue: rawLanguage) {
            language = cachedLanguage
        }

        if let rawTheme = defaults.string(forKey: "sihhatk_theme"),
           let cachedTheme = AppTheme(rawValue: rawTheme) {
            theme = cachedTheme
        }

        registeredUsers = decode([RegisteredUser].self, fromKey: "sihhatk_registered_users") ?? []

        if let cachedUser = decode(UserAccount.self, fromKey: "sihhatk_active_user") {
            activeUser = cachedUser
            loadProfileAndHistory(for: cachedUser)
        }
    }

    private func setActiveUser(_ user: UserAccount) {
        activeUser = user
        encode(user, forKey: "sihhatk_active_user")
        loadProfileAndHistory(for: user)
    }

    private func loadProfileAndHistory(for user: UserAccount) {
        profile = decode(UserProfile.self, fromKey: profileKey(for: user.email))
        history = decode([HistoryItem].self, fromKey: historyKey(for: user.email)) ?? []
    }

    private func saveRegisteredUsers() {
        encode(registeredUsers, forKey: "sihhatk_registered_users")
    }

    private func saveProfile() {
        guard let activeUser, let profile else { return }
        encode(profile, forKey: profileKey(for: activeUser.email))
    }

    private func saveHistory() {
        guard let activeUser else { return }
        encode(history, forKey: historyKey(for: activeUser.email))
    }

    private func profileKey(for email: String) -> String {
        "sihhatk_profile_\(sanitized(email))"
    }

    private func historyKey(for email: String) -> String {
        "sihhatk_history_\(sanitized(email))"
    }

    private func sanitized(_ email: String) -> String {
        email.replacingOccurrences(of: ".", with: "_").replacingOccurrences(of: "@", with: "_")
    }

    private func encode<T: Encodable>(_ value: T, forKey key: String) {
        guard let data = try? encoder.encode(value) else { return }
        defaults.set(data, forKey: key)
    }

    private func decode<T: Decodable>(_ type: T.Type, fromKey key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? decoder.decode(type, from: data)
    }
}
