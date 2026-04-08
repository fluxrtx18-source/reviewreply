import SwiftUI

struct ResponsesView: View {

    @Bindable var viewModel: ComposeViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(StoreService.self) private var store

    @State private var showRegenerateConfirm = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                // ── Platform + Review Summary ─────────────────────────────
                ReviewSummaryHeader(viewModel: viewModel)

                // ── Response Cards ────────────────────────────────────────
                ForEach(Array(viewModel.generatedResponses.enumerated()), id: \.offset) { _, response in
                    // Wrap in a preview card since these are transient AIReviewResponse,
                    // not yet-persisted SavedResponse objects at this stage.
                    TransientResponseCard(response: response)
                }

                // ── Regenerate ────────────────────────────────────────────
                Button {
                    showRegenerateConfirm = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.clockwise")
                        Text("Regenerate")
                    }
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color(.secondaryLabel))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.secondarySystemBackground))
                    )
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
            .padding(Theme.Layout.padding)
        }
        .navigationTitle("Replies")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    viewModel.reset()
                    dismiss()
                }
                .fontWeight(.semibold)
            }
        }
        .confirmationDialog("Regenerate Replies?", isPresented: $showRegenerateConfirm, titleVisibility: .visible) {
            Button("Regenerate") {
                Task {
                    viewModel.generatedResponses = []
                    await viewModel.generate(store: store)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will use another free reply if you haven't subscribed.")
        }
    }
}

// MARK: - Review Summary Header

private struct ReviewSummaryHeader: View {
    let viewModel: ComposeViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: viewModel.selectedPlatform.icon)
                    .foregroundStyle(viewModel.selectedPlatform.color)
                Text(viewModel.platformDisplayName)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color(.secondaryLabel))

                if let stars = viewModel.starRating {
                    Spacer()
                    HStack(spacing: 2) {
                        ForEach(1...5, id: \.self) { i in
                            Image(systemName: i <= stars ? "star.fill" : "star")
                                .font(.system(size: 10))
                                .foregroundStyle(i <= stars ? Theme.Colors.warning : Color(.systemFill))
                        }
                    }
                }
            }

            Text(viewModel.reviewText)
                .font(.system(size: 14))
                .foregroundStyle(Color(.secondaryLabel))
                .lineLimit(3)
                .lineSpacing(3)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Theme.Layout.cardCornerRadius)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

// MARK: - Transient Response Card (for AIReviewResponse, not yet @Model)

private struct TransientResponseCard: View {

    let response: AIReviewResponse
    @State private var copied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            // Header
            HStack(spacing: 6) {
                Text(response.tone)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.Colors.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule().fill(Theme.Colors.primary.opacity(0.1))
                    )
                Spacer()
            }

            // Body
            Text(response.response)
                .font(.system(size: 15))
                .foregroundStyle(Color(.label))
                .lineSpacing(4)

            // Key Points
            if !response.keyPoints.isEmpty {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(response.keyPoints, id: \.self) { point in
                        HStack(alignment: .top, spacing: 6) {
                            Circle().fill(Theme.Colors.primary.opacity(0.5))
                                .frame(width: 5, height: 5).padding(.top, 5)
                            Text(point).font(.caption).foregroundStyle(Color(.secondaryLabel))
                        }
                    }
                }
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color(.tertiarySystemBackground)))
            }

            // Copy
            Button {
                UIPasteboard.general.string = response.response
                SharedResponseStore.append(response.response)
                withAnimation { copied = true }
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                Task {
                    try? await Task.sleep(for: .seconds(2))
                    await MainActor.run { withAnimation { copied = false } }
                }
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
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: Theme.Layout.cardCornerRadius)
                .fill(Color(.secondarySystemBackground))
        )
    }
}
