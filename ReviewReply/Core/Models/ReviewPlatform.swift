import SwiftUI

// MARK: - Review Platform

enum ReviewPlatform: String, CaseIterable, Codable, Identifiable, Sendable {
    case google      = "Google"
    case appStore    = "App Store"
    case yelp        = "Yelp"
    case tripadvisor = "TripAdvisor"
    case other       = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .google:      return "globe"
        case .appStore:    return "apple.logo"
        case .yelp:        return "star.fill"
        case .tripadvisor: return "airplane.circle.fill"
        case .other:       return "ellipsis.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .google:      return Color(hex: "#EA4335")
        case .appStore:    return Color(hex: "#007AFF")
        case .yelp:        return Color(hex: "#D32323")
        case .tripadvisor: return Color(hex: "#34A853")
        case .other:       return Color(.secondaryLabel)
        }
    }

    /// Describes the platform in the AI prompt context.
    var contextHint: String {
        switch self {
        case .google:      return "Google Business review"
        case .appStore:    return "App Store review"
        case .yelp:        return "Yelp review"
        case .tripadvisor: return "TripAdvisor review"
        case .other:       return "customer review"
        }
    }
}
