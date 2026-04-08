import Foundation

// MARK: - Step enum  (mirrors QuizzerAI pattern)

enum OnboardingStep: Int, CaseIterable {
    case welcome      = 0
    case features     = 1
    case platforms    = 2
    case valueProof   = 3
    case paywall      = 4
}

// MARK: - Feature Cards  (carousel step)

struct OnboardingFeatureCard: Identifiable {
    let id        = UUID()
    let icon:     String
    let headline: String
    let body:     String
    let accentHex: String
}

extension OnboardingFeatureCard {
    static let all: [OnboardingFeatureCard] = [
        OnboardingFeatureCard(
            icon:      "doc.text.magnifyingglass",
            headline:  "Paste Any Review",
            body:      "Drop in a 1-star Google, Yelp, or App Store review and get 3 professional responses in seconds.",
            accentHex: "#2B5CE6"
        ),
        OnboardingFeatureCard(
            icon:      "lock.shield.fill",
            headline:  "100% On-Device AI",
            body:      "Apple's Foundation Models run entirely on your iPhone. Your reviews never touch a server.",
            accentHex: "#10B981"
        ),
        OnboardingFeatureCard(
            icon:      "square.on.square",
            headline:  "Copy, Save & Reuse",
            body:      "Tap to copy your favourite response and paste it straight into Google Maps, Yelp, or App Store Connect.",
            accentHex: "#F59E0B"
        )
    ]
}

// MARK: - Value Proof Items  (before/after step)

struct ValueItem: Identifiable {
    let id     = UUID()
    let icon:   String
    let before: String
    let after:  String
}

extension ValueItem {
    static let all: [ValueItem] = [
        ValueItem(
            icon:   "clock.badge.xmark",
            before: "30 min crafting a careful reply",
            after:  "Professional response in under 10 seconds"
        ),
        ValueItem(
            icon:   "lock.shield.fill",
            before: "Pasting reviews into ChatGPT",
            after:  "Fully on-device — zero data leaves your phone"
        ),
        ValueItem(
            icon:   "person.crop.circle.badge.checkmark",
            before: "Looking defensive under pressure",
            after:  "Calm, crafted replies that build customer trust"
        )
    ]
}

// MARK: - UserDefaults Keys

enum UserDefaultsKeys {
    static let onboardingComplete  = "onboardingComplete"
    static let lastFreeReplyDate   = "com.reviewreply.lastFreeReplyDate"
    static let managedPlatforms    = "com.reviewreply.managedPlatforms"
    /// Shared group key used by Keyboard Extension
    static let recentResponsesKey  = "com.reviewreply.recentResponses"
    static let sharedGroupID       = "group.com.reviewreply.shared"
}
