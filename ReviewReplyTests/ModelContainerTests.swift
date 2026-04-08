import Testing
import SwiftData
import Foundation
@testable import ReviewReply

// MARK: - ModelContainer + Seeding Tests

@Suite("AppModelContainer")
struct ModelContainerTests {

    @Test("Seeding default tones into empty context creates 3 tones")
    @MainActor
    func seedCreates3Tones() throws {
        let container = try ModelContainer(
            for: ReviewSession.self, SavedResponse.self, ToneConfig.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext

        // Verify empty before seeding
        let beforeCount = try context.fetchCount(FetchDescriptor<ToneConfig>())
        #expect(beforeCount == 0)

        AppModelContainer.seedDefaultTonesIfNeeded(context: context)

        let afterCount = try context.fetchCount(FetchDescriptor<ToneConfig>())
        #expect(afterCount == 3)
    }

    @Test("Seeding is idempotent — calling twice does not duplicate")
    @MainActor
    func seedIdempotent() throws {
        let container = try ModelContainer(
            for: ReviewSession.self, SavedResponse.self, ToneConfig.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext

        AppModelContainer.seedDefaultTonesIfNeeded(context: context)
        AppModelContainer.seedDefaultTonesIfNeeded(context: context)

        let count = try context.fetchCount(FetchDescriptor<ToneConfig>())
        #expect(count == 3, "Seeding twice should not create duplicates")
    }

    @Test("Seeded tones match expected names")
    @MainActor
    func seededToneNames() throws {
        let container = try ModelContainer(
            for: ReviewSession.self, SavedResponse.self, ToneConfig.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext

        AppModelContainer.seedDefaultTonesIfNeeded(context: context)

        let tones = try context.fetch(FetchDescriptor<ToneConfig>(sortBy: [SortDescriptor<ToneConfig>(\.sortOrder)]))
        let names = tones.map(\.name)

        #expect(names == ["Apologetic", "Professional", "Grateful"])
    }

    @Test("Seeded tones are all enabled by default")
    @MainActor
    func seededTonesEnabled() throws {
        let container = try ModelContainer(
            for: ReviewSession.self, SavedResponse.self, ToneConfig.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext

        AppModelContainer.seedDefaultTonesIfNeeded(context: context)

        let tones = try context.fetch(FetchDescriptor<ToneConfig>())
        for tone in tones {
            #expect(tone.isEnabled == true, "\(tone.name) should be enabled")
        }
    }
}
