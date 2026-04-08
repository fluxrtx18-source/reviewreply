import Foundation
import FoundationModels

// MARK: - Generable Output Types

@Generable
struct ReviewResponseBundle {
    var responses: [AIReviewResponse]
}

@Generable
struct AIReviewResponse {
    var tone: String
    var response: String
    var keyPoints: [String]
}

// MARK: - Sendable Tone Snapshot (safe to cross actor boundaries)

struct ToneSnapshot: Sendable {
    let name: String
    let emoji: String
    let instruction: String
}

// MARK: - Service

struct ReviewAIService: Sendable {

    static func generateResponses(
        reviewText: String,
        platform: String,
        starRating: Int?,
        tones: [ToneSnapshot]
    ) async throws -> [AIReviewResponse] {

        guard !tones.isEmpty else { return [] }

        let tonesBlock = tones.enumerated().map { idx, t in
            "\(idx + 1). \(t.emoji) \(t.name): \(t.instruction)"
        }.joined(separator: "\n")

        let ratingLine = starRating.map { "Star rating: \($0)/5.\n" } ?? ""

        let instructions = """
        You are a professional customer service expert helping small business owners respond to online reviews. \
        Your responses are empathetic, constructive, and never defensive. Keep each response under 100 words. \
        Write as if it will be posted publicly. Never use placeholder text such as [Business Name] or [Your Name]. \
        Return a ReviewResponseBundle with a "responses" array containing one AIReviewResponse per tone. \
        Each AIReviewResponse has: "tone" (the tone name), "response" (the reply text), "keyPoints" (array of addressed issues).
        """

        let prompt = """
        Write \(tones.count) professional response(s) to the following \(platform).
        \(ratingLine)
        Review:
        "\(reviewText)"

        Use exactly these tone(s) in order:
        \(tonesBlock)
        """

        let session = LanguageModelSession(instructions: instructions)
        let result = try await session.respond(to: prompt, generating: ReviewResponseBundle.self)
        return result.content.responses
    }
}
