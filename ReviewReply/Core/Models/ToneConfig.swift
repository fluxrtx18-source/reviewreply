import Foundation
import SwiftData

// MARK: - Tone Configuration

@Model
final class ToneConfig {
    var id: UUID
    var name: String
    var instruction: String   // Prompt instruction sent to Foundation Models
    var emoji: String
    var isEnabled: Bool
    var sortOrder: Int

    init(name: String, instruction: String, emoji: String, isEnabled: Bool = true, sortOrder: Int = 0) {
        self.id          = UUID()
        self.name        = name
        self.instruction = instruction
        self.emoji       = emoji
        self.isEnabled   = isEnabled
        self.sortOrder   = sortOrder
    }
}

// MARK: - Default Seed Data

extension ToneConfig {
    /// Plain-data tuples used to seed defaults on first launch.
    static let seedData: [(name: String, instruction: String, emoji: String, sortOrder: Int)] = [
        (
            name:        "Apologetic",
            instruction: "Write a sincere, empathetic apology that genuinely acknowledges the customer's frustration, takes responsibility where appropriate, and offers a path forward.",
            emoji:       "🙏",
            sortOrder:   0
        ),
        (
            name:        "Professional",
            instruction: "Respond calmly and professionally. Address the specific concern with facts, avoid defensiveness, and offer a clear resolution or next step.",
            emoji:       "💼",
            sortOrder:   1
        ),
        (
            name:        "Grateful",
            instruction: "Thank the reviewer warmly for their feedback. Acknowledge the issue, highlight what has been improved, and express genuine appreciation for helping the business grow.",
            emoji:       "🌟",
            sortOrder:   2
        )
    ]
}
