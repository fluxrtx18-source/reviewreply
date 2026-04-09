import SwiftUI
import SwiftData

struct DashboardView: View {

    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            ComposeView()
                .tabItem { Label("Compose", systemImage: "square.and.pencil") }
                .tag(0)

            HistoryView()
                .tabItem { Label("History", systemImage: "clock") }
                .tag(1)

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(2)
        }
        .task {
            AppModelContainer.seedDefaultTonesIfNeeded(context: modelContext)
        }
        .onOpenURL { url in
            handleDeepLink(url)
        }
    }

    // MARK: - Deep Link (from Share Extension)
    // URL format: reviewreply://compose?text=<encoded review>

    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "reviewreply",
              url.host == "compose",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let text = components.queryItems?.first(where: { $0.name == "text" })?.value
        else { return }

        selectedTab = 0
        NotificationCenter.default.post(name: .reviewReplyDidReceiveSharedText, object: text)
    }
}

extension Notification.Name {
    static let reviewReplyDidReceiveSharedText = Notification.Name("reviewReplyDidReceiveSharedText")
}
