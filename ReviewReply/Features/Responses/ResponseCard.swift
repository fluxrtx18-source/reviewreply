import SwiftUI

// MARK: - Response Card (used in both ResponsesView and HistoryView)

struct ResponseCard: View {

    let response: SavedResponse
    var onCopy: ((String) -> Void)? = nil

    @State private var copied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            // ── Header ───────────────────────────────────────────────────
            HStack(spacing: 8) {
                Text(response.toneEmoji)
                    .font(.system(size: 18))
                Text(response.tone)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.Colors.primary)
                Spacer()
                FavoriteButton(isFavorited: response.isFavorited) {
                    response.isFavorited.toggle()
                }
            }

            // ── Response Text ─────────────────────────────────────────────
            Text(response.responseText)
                .font(.system(size: 15))
                .foregroundStyle(Color(.label))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            // ── Key Points ────────────────────────────────────────────────
            if !response.keyPoints.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Addresses")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color(.tertiaryLabel))
                        .textCase(.uppercase)
                        .tracking(0.6)

                    ForEach(response.keyPoints, id: \.self) { point in
                        HStack(alignment: .top, spacing: 6) {
                            Circle()
                                .fill(Theme.Colors.primary.opacity(0.5))
                                .frame(width: 5, height: 5)
                                .padding(.top, 5)
                            Text(point)
                                .font(.caption)
                                .foregroundStyle(Color(.secondaryLabel))
                        }
                    }
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.tertiarySystemBackground))
                )
            }

            // ── Copy Button ───────────────────────────────────────────────
            Button {
                copyResponse()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: copied ? "checkmark" : "doc.on.doc")
                        .font(.system(size: 13, weight: .semibold))
                    Text(copied ? "Copied!" : "Copy Response")
                        .font(.system(size: 14, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(copied ? Theme.Colors.success.opacity(0.15) : Theme.Colors.primary.opacity(0.1))
                )
                .foregroundStyle(copied ? Theme.Colors.success : Theme.Colors.primary)
            }
            .buttonStyle(.plain)
            .animation(.spring(response: 0.3), value: copied)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: Theme.Layout.cardCornerRadius)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func copyResponse() {
        UIPasteboard.general.string = response.responseText
        response.copiedCount += 1

        // Persist copied response to shared group for keyboard extension
        SharedResponseStore.append(response.responseText)

        onCopy?(response.responseText)

        withAnimation { copied = true }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        Task {
            try? await Task.sleep(for: .seconds(2))
            await MainActor.run { withAnimation { copied = false } }
        }
    }
}

// MARK: - Favorite Button

struct FavoriteButton: View {
    let isFavorited: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: isFavorited ? "heart.fill" : "heart")
                .font(.system(size: 16))
                .foregroundStyle(isFavorited ? Theme.Colors.error : Color(.secondaryLabel))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isFavorited ? "Remove from favorites" : "Add to favorites")
        .sensoryFeedback(.selection, trigger: isFavorited)
    }
}

// MARK: - Shared Response Store  (keyboard extension bridge)

enum SharedResponseStore {
    private static let maxCount = 10

    static func append(_ text: String) {
        var existing = load()
        existing.removeAll { $0 == text }
        existing.insert(text, at: 0)
        if existing.count > maxCount { existing = Array(existing.prefix(maxCount)) }
        let defaults = UserDefaults(suiteName: UserDefaultsKeys.sharedGroupID)
        defaults?.set(existing, forKey: UserDefaultsKeys.recentResponsesKey)
    }

    static func load() -> [String] {
        let defaults = UserDefaults(suiteName: UserDefaultsKeys.sharedGroupID)
        return defaults?.stringArray(forKey: UserDefaultsKeys.recentResponsesKey) ?? []
    }
}
