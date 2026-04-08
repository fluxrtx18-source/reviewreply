import SwiftUI
import SwiftData

@main
struct ReviewReplyApp: App {

    @AppStorage(UserDefaultsKeys.onboardingComplete) private var onboardingComplete = false

    @State private var store = StoreService.shared

    var body: some Scene {
        WindowGroup {
            Group {
                if onboardingComplete {
                    DashboardView()
                } else {
                    OnboardingContainerView()
                }
            }
            .modelContainer(AppModelContainer.shared)
            .environment(store)
        }
    }
}
