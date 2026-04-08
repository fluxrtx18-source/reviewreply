import Testing
@testable import ReviewReply

// MARK: - Onboarding Data Tests

@Suite("OnboardingData")
struct OnboardingDataTests {

    @Test("OnboardingStep has 5 steps")
    func stepCount() {
        #expect(OnboardingStep.allCases.count == 5)
    }

    @Test("Steps are in expected order")
    func stepOrder() {
        let steps = OnboardingStep.allCases.sorted { $0.rawValue < $1.rawValue }
        #expect(steps[0] == .welcome)
        #expect(steps[1] == .features)
        #expect(steps[2] == .platforms)
        #expect(steps[3] == .valueProof)
        #expect(steps[4] == .paywall)
    }

    @Test("Feature cards have 3 entries")
    func featureCardCount() {
        #expect(OnboardingFeatureCard.all.count == 3)
    }

    @Test("Feature cards have non-empty content")
    func featureCardsContent() {
        for card in OnboardingFeatureCard.all {
            #expect(!card.icon.isEmpty)
            #expect(!card.headline.isEmpty)
            #expect(!card.body.isEmpty)
            #expect(!card.accentHex.isEmpty)
            #expect(card.accentHex.hasPrefix("#"), "Hex color should start with #")
        }
    }

    @Test("Value items have 3 entries")
    func valueItemCount() {
        #expect(ValueItem.all.count == 3)
    }

    @Test("Value items have non-empty before/after")
    func valueItemsContent() {
        for item in ValueItem.all {
            #expect(!item.icon.isEmpty)
            #expect(!item.before.isEmpty)
            #expect(!item.after.isEmpty)
        }
    }

    @Test("UserDefaultsKeys are unique")
    func keysUnique() {
        let keys = [
            UserDefaultsKeys.onboardingComplete,
            UserDefaultsKeys.lastFreeReplyDate,
            UserDefaultsKeys.managedPlatforms,
            UserDefaultsKeys.recentResponsesKey
        ]
        let uniqueKeys = Set(keys)
        #expect(keys.count == uniqueKeys.count, "All UserDefaults keys must be unique")
    }
}
