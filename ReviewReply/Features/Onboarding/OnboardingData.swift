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

// MARK: - Testimonials (cinematic social proof)

struct Testimonial: Identifiable {
    let id      = UUID()
    let quote:   String
    let name:    String
    let role:    String
    let stars:   Int

    var initials: String {
        name.split(separator: " ").compactMap(\.first).map(String.init).joined()
    }
}

extension Testimonial {
    static let all: [Testimonial] = [
        Testimonial(
            quote:  "Saved me hours every week replying to Google reviews.",
            name:   "Sarah K.",
            role:   "Restaurant Owner",
            stars:  5
        ),
        Testimonial(
            quote:  "My responses sound professional now instead of defensive.",
            name:   "Marcus T.",
            role:   "Auto Shop Owner",
            stars:  5
        ),
        Testimonial(
            quote:  "Love that nothing leaves my phone. Privacy matters for my clients.",
            name:   "Dr. Patel",
            role:   "Dental Practice",
            stars:  5
        )
    ]
}

// MARK: - Social Proof Badges (per-step trust signals)

struct SocialProofItem {
    let icon: String
    let text: String
}

extension SocialProofItem {
    static func forStep(_ step: OnboardingStep) -> SocialProofItem? {
        switch step {
        case .welcome:    return SocialProofItem(icon: "person.2.fill", text: "Trusted by 2,500+ Business Owners")
        case .features:   return SocialProofItem(icon: "text.bubble.fill", text: "Over 50,000+ Replies Generated")
        case .platforms:  return SocialProofItem(icon: "star.fill", text: "4.8★ Average Rating")
        case .valueProof: return SocialProofItem(icon: "bolt.fill", text: "Replies in Under 10 Seconds")
        case .paywall:    return nil
        }
    }
}

// MARK: - Onboarding Step Icons

extension OnboardingStep {
    var icon: String {
        switch self {
        case .welcome:    return "star.bubble.fill"
        case .features:   return "sparkles"
        case .platforms:  return "globe"
        case .valueProof: return "checkmark.shield"
        case .paywall:    return "crown.fill"
        }
    }
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
