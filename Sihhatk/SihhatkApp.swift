import SwiftUI

@main
struct SihhatkApp: App {
    @StateObject private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .preferredColorScheme(store.theme == .dark ? .dark : .light)
        }
    }
}
