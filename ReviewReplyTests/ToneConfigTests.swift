import Testing
import SwiftData
@testable import ReviewReply

// MARK: - ToneConfig Tests

@Suite("ToneConfig")
struct ToneConfigTests {

    @Test("Seed data has 3 default tones")
    func seedDataCount() {
        #expect(ToneConfig.seedData.count == 3)
    }

    @Test("Seed data tones have non-empty fields")
    func seedDataFieldsNonEmpty() {
        for tone in ToneConfig.seedData {
            #expect(!tone.name.isEmpty, "Tone name should not be empty")
            #expect(!tone.instruction.isEmpty, "Tone instruction should not be empty")
            #expect(!tone.emoji.isEmpty, "Tone emoji should not be empty")
        }
    }

    @Test("Seed data sort orders are unique")
    func seedDataUniqueSortOrders() {
        let orders = ToneConfig.seedData.map(\.sortOrder)
        let uniqueOrders = Set(orders)
        #expect(orders.count == uniqueOrders.count)
    }

    @Test("Seed data contains expected tone names", arguments: ["Apologetic", "Professional", "Grateful"])
    func seedDataContainsTone(name: String) {
        let names = ToneConfig.seedData.map(\.name)
        #expect(names.contains(name))
    }

    @Test("ToneConfig initializer sets all properties")
    @MainActor
    func initSetsProperties() throws {
        let container = try ModelContainer(
            for: ToneConfig.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext

        let tone = ToneConfig(
            name: "Firm",
            instruction: "Be direct and assertive",
            emoji: "💪",
            isEnabled: true,
            sortOrder: 5
        )
        context.insert(tone)
        try context.save()

        let descriptor = FetchDescriptor<ToneConfig>()
        let fetched = try context.fetch(descriptor)
        let result = try #require(fetched.first)

        #expect(result.name == "Firm")
        #expect(result.instruction == "Be direct and assertive")
        #expect(result.emoji == "💪")
        #expect(result.isEnabled == true)
        #expect(result.sortOrder == 5)
    }

    @Test("Disabled tone can be toggled")
    @MainActor
    func toggleEnabled() throws {
        let container = try ModelContainer(
            for: ToneConfig.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext

        let tone = ToneConfig(name: "Test", instruction: "x", emoji: "🔧", isEnabled: true, sortOrder: 0)
        context.insert(tone)

        #expect(tone.isEnabled == true)
        tone.isEnabled = false
        #expect(tone.isEnabled == false)
    }
}
