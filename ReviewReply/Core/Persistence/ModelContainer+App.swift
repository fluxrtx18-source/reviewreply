import SwiftData
import Foundation

// MARK: - App Model Container

enum AppModelContainer {

    static let shared: ModelContainer = {
        let schema = Schema([ReviewSession.self, SavedResponse.self, ToneConfig.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: config)
        } catch {
            // Fallback to in-memory store so the app doesn't crash on corrupt database
            print("[AppModelContainer] Persistent store failed: \(error). Falling back to in-memory.")
            let fallback = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            return try! ModelContainer(for: schema, configurations: fallback)
        }
    }()

    // MARK: - Default tone seeding

    /// Call from a @MainActor context (e.g. DashboardView.onAppear).
    @MainActor
    static func seedDefaultTonesIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<ToneConfig>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        guard count == 0 else { return }

        for (i, data) in ToneConfig.seedData.enumerated() {
            let tone = ToneConfig(
                name: data.name,
                instruction: data.instruction,
                emoji: data.emoji,
                sortOrder: i
            )
            context.insert(tone)
        }
        try? context.save()
    }
}
