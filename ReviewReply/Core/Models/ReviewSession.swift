import Foundation
import SwiftData

// MARK: - Review Session

@Model
final class ReviewSession {
    var id: UUID
    var platformRaw: String
    var customPlatformName: String?
    var reviewText: String
    var starRating: Int?
    var createdAt: Date
    var isFavorited: Bool

    @Relationship(deleteRule: .cascade, inverse: \SavedResponse.session)
    var responses: [SavedResponse]

    var platform: ReviewPlatform {
        get { ReviewPlatform(rawValue: platformRaw) ?? .other }
        set { platformRaw = newValue.rawValue }
    }

    var displayPlatform: String {
        platform == .other ? (customPlatformName ?? "Other") : platform.rawValue
    }

    init(
        platform: ReviewPlatform,
        reviewText: String,
        starRating: Int? = nil,
        customPlatformName: String? = nil
    ) {
        self.id                 = UUID()
        self.platformRaw        = platform.rawValue
        self.customPlatformName = customPlatformName
        self.reviewText         = reviewText
        self.starRating         = starRating
        self.createdAt          = Date()
        self.isFavorited        = false
        self.responses          = []
    }
}

// MARK: - Saved Response

@Model
final class SavedResponse {
    var id: UUID
    var tone: String
    var toneEmoji: String
    var responseText: String
    var keyPoints: [String]
    var isFavorited: Bool
    var copiedCount: Int
    var createdAt: Date
    var session: ReviewSession?

    init(tone: String, toneEmoji: String, responseText: String, keyPoints: [String]) {
        self.id           = UUID()
        self.tone         = tone
        self.toneEmoji    = toneEmoji
        self.responseText = responseText
        self.keyPoints    = keyPoints
        self.isFavorited  = false
        self.copiedCount  = 0
        self.createdAt    = Date()
    }
}
