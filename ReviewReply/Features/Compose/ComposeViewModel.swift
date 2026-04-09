import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class ComposeViewModel {

    // MARK: - Input State

    var reviewText: String       = ""
    var selectedPlatform         = ReviewPlatform.google
    var customPlatformName: String = ""
    var starRating: Int?         = nil

    // MARK: - Output State

    var generatedResponses: [AIReviewResponse] = []
    var isGenerating: Bool       = false
    var errorMessage: String?    = nil
    var showPaywall: Bool        = false
    var navigateToResponses: Bool = false

    // MARK: - Dependencies

    private let modelContext: ModelContext
    private(set) var activeTones: [ToneConfig] = []
    private var currentSession: ReviewSession?

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadTones()
    }

    // MARK: - Tone Loading

    private func loadTones() {
        let descriptor = FetchDescriptor<ToneConfig>(
            sortBy: [SortDescriptor(\.sortOrder)]
        )
        activeTones = (try? modelContext.fetch(descriptor)) ?? []
    }

    func reloadTones() { loadTones() }

    // MARK: - Generate

    func generate(store: StoreService) async {
        let trimmed = reviewText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // Check quota
        if !store.isPremium && !UsageLimiter.canUseForFree {
            showPaywall = true
            return
        }

        // Record usage BEFORE async work to prevent double-tap bypass
        let shouldTrackUsage = !store.isPremium
        if shouldTrackUsage { UsageLimiter.recordUsage() }

        isGenerating = true
        errorMessage = nil

        do {
            let toneSnapshots = activeTones
                .filter(\.isEnabled)
                .sorted { $0.sortOrder < $1.sortOrder }
                .map { ToneSnapshot(name: $0.name, emoji: $0.emoji, instruction: $0.instruction) }
            let platformDisplay = selectedPlatform == .other
                ? (customPlatformName.isEmpty ? "customer review" : customPlatformName)
                : selectedPlatform.contextHint
            let rating = starRating

            generatedResponses = try await ReviewAIService.generateResponses(
                reviewText: trimmed,
                platform: platformDisplay,
                starRating: rating,
                tones: toneSnapshots
            )

            if !generatedResponses.isEmpty {
                let session = createSession()
                currentSession = session
                saveResponses(to: session)
                navigateToResponses = true
            }
        } catch {
            // Undo usage on failure so user isn't penalised for errors
            if shouldTrackUsage { UsageLimiter.undoUsage() }
            errorMessage = "Couldn't generate responses. Please check your connection and try again."
        }

        isGenerating = false
    }

    // MARK: - Session Persistence

    private func createSession() -> ReviewSession {
        let session = ReviewSession(
            platform: selectedPlatform,
            reviewText: reviewText.trimmingCharacters(in: .whitespacesAndNewlines),
            starRating: starRating,
            customPlatformName: selectedPlatform == .other ? customPlatformName : nil
        )
        modelContext.insert(session)
        return session
    }

    private func saveResponses(to session: ReviewSession) {
        // Map tone emoji from active tones list
        let emojiMap = Dictionary(uniqueKeysWithValues: activeTones.map { ($0.name, $0.emoji) })

        for r in generatedResponses {
            let saved = SavedResponse(
                tone: r.tone,
                toneEmoji: emojiMap[r.tone] ?? "💬",
                responseText: r.response,
                keyPoints: r.keyPoints
            )
            session.responses.append(saved)
        }
        try? modelContext.save()
    }

    // MARK: - Helpers

    func reset() {
        reviewText        = ""
        selectedPlatform  = .google
        customPlatformName = ""
        starRating        = nil
        generatedResponses = []
        errorMessage      = nil
        navigateToResponses = false
        currentSession    = nil
    }

    var platformDisplayName: String {
        selectedPlatform == .other
            ? (customPlatformName.isEmpty ? "Other" : customPlatformName)
            : selectedPlatform.rawValue
    }

    var canGenerate: Bool {
        !reviewText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isGenerating
    }

    /// Whether to show the usage limit banner (checked via view model, not in view body).
    func shouldShowUsageBanner(isPremium: Bool) -> Bool {
        !isPremium && !UsageLimiter.canUseForFree
    }
}
