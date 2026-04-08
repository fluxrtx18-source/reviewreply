import Testing
import Foundation
@testable import ReviewReply

// MARK: - ReviewPlatform Tests

@Suite("ReviewPlatform")
struct ReviewPlatformTests {

    @Test("All cases are present", arguments: ReviewPlatform.allCases)
    func allCasesHaveProperties(platform: ReviewPlatform) {
        #expect(!platform.rawValue.isEmpty)
        #expect(!platform.icon.isEmpty)
        #expect(!platform.contextHint.isEmpty)
        #expect(!platform.id.isEmpty)
    }

    @Test("ID matches rawValue")
    func idMatchesRawValue() {
        for platform in ReviewPlatform.allCases {
            #expect(platform.id == platform.rawValue)
        }
    }

    @Test("Expected case count")
    func caseCount() {
        #expect(ReviewPlatform.allCases.count == 5)
    }

    @Test("Context hints describe the platform", arguments: [
        (ReviewPlatform.google, "Google"),
        (.appStore, "App Store"),
        (.yelp, "Yelp"),
        (.tripadvisor, "TripAdvisor"),
        (.other, "customer")
    ])
    func contextHintContainsPlatformName(platform: ReviewPlatform, keyword: String) {
        #expect(platform.contextHint.contains(keyword))
    }

    @Test("Codable round-trip")
    func codableRoundTrip() throws {
        for platform in ReviewPlatform.allCases {
            let data = try JSONEncoder().encode(platform)
            let decoded = try JSONDecoder().decode(ReviewPlatform.self, from: data)
            #expect(decoded == platform)
        }
    }
}
