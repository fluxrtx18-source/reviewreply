import Testing
import SwiftData
@testable import ReviewReply

// MARK: - ReviewSession + SavedResponse Tests

@Suite("ReviewSession")
@MainActor
struct ReviewSessionTests {

    private func makeContainer() throws -> ModelContainer {
        try ModelContainer(
            for: ReviewSession.self, SavedResponse.self, ToneConfig.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
    }

    @Test("Session initializer sets platform and review text")
    func initSetsFields() throws {
        let container = try makeContainer()
        let context = container.mainContext

        let session = ReviewSession(
            platform: .google,
            reviewText: "Terrible service!",
            starRating: 1
        )
        context.insert(session)
        try context.save()

        #expect(session.platform == .google)
        #expect(session.platformRaw == "Google")
        #expect(session.reviewText == "Terrible service!")
        #expect(session.starRating == 1)
        #expect(session.isFavorited == false)
        #expect(session.responses.isEmpty)
    }

    @Test("displayPlatform returns custom name for .other")
    func displayPlatformOther() {
        let session = ReviewSession(
            platform: .other,
            reviewText: "Bad",
            customPlatformName: "Trustpilot"
        )
        #expect(session.displayPlatform == "Trustpilot")
    }

    @Test("displayPlatform returns rawValue for known platforms", arguments: [
        ReviewPlatform.google, .appStore, .yelp, .tripadvisor
    ])
    func displayPlatformKnown(platform: ReviewPlatform) {
        let session = ReviewSession(platform: platform, reviewText: "x")
        #expect(session.displayPlatform == platform.rawValue)
    }

    @Test("Adding responses to session")
    func addResponses() throws {
        let container = try makeContainer()
        let context = container.mainContext

        let session = ReviewSession(platform: .yelp, reviewText: "Slow food")
        context.insert(session)

        let response = SavedResponse(
            tone: "Apologetic",
            toneEmoji: "🙏",
            responseText: "We're sorry about the wait.",
            keyPoints: ["slow service", "food quality"]
        )
        session.responses.append(response)
        try context.save()

        #expect(session.responses.count == 1)
        let saved = try #require(session.responses.first)
        #expect(saved.tone == "Apologetic")
        #expect(saved.keyPoints.count == 2)
        #expect(saved.copiedCount == 0)
        #expect(saved.isFavorited == false)
    }

    @Test("SavedResponse copiedCount increments")
    func copiedCountIncrements() {
        let response = SavedResponse(
            tone: "Professional",
            toneEmoji: "💼",
            responseText: "Thank you for your feedback.",
            keyPoints: []
        )
        #expect(response.copiedCount == 0)
        response.copiedCount += 1
        #expect(response.copiedCount == 1)
    }

    @Test("Cascade deletion removes responses")
    func cascadeDeletion() throws {
        let container = try makeContainer()
        let context = container.mainContext

        let session = ReviewSession(platform: .google, reviewText: "Bad")
        context.insert(session)

        session.responses.append(SavedResponse(tone: "A", toneEmoji: "🙏", responseText: "Sorry", keyPoints: []))
        session.responses.append(SavedResponse(tone: "B", toneEmoji: "💼", responseText: "Thanks", keyPoints: []))
        try context.save()

        let responsesCount = try context.fetchCount(FetchDescriptor<SavedResponse>())
        #expect(responsesCount == 2)

        context.delete(session)
        try context.save()

        let afterDelete = try context.fetchCount(FetchDescriptor<SavedResponse>())
        #expect(afterDelete == 0, "Cascade delete should remove child responses")
    }
}
