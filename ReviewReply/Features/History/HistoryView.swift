import SwiftUI
import SwiftData

struct HistoryView: View {

    @Environment(\.modelContext) private var modelContext

    @Query(sort: \ReviewSession.createdAt, order: .reverse)
    private var sessions: [ReviewSession]

    @State private var searchText = ""
    @State private var expandedSession: UUID?

    private var filtered: [ReviewSession] {
        guard !searchText.isEmpty else { return sessions }
        return sessions.filter {
            $0.reviewText.localizedCaseInsensitiveContains(searchText) ||
            $0.displayPlatform.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if sessions.isEmpty {
                    HistoryEmptyState()
                } else {
                    List {
                        ForEach(filtered) { session in
                            HistorySessionRow(
                                session: session,
                                isExpanded: expandedSession == session.id
                            ) {
                                withAnimation(.spring(response: 0.35)) {
                                    expandedSession = expandedSession == session.id ? nil : session.id
                                }
                            }
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                        .onDelete(perform: deleteSessions)
                    }
                    .listStyle(.plain)
                    .searchable(text: $searchText, prompt: "Search reviews…")
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private func deleteSessions(at offsets: IndexSet) {
        for i in offsets {
            modelContext.delete(filtered[i])
        }
        try? modelContext.save()
    }
}

// MARK: - Session Row

private struct HistorySessionRow: View {

    let session: ReviewSession
    let isExpanded: Bool
    let onToggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Summary ──────────────────────────────────────────────────
            Button(action: onToggle) {
                HStack(spacing: 12) {
                    // Platform icon badge
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(session.platform.color.opacity(0.12))
                            .frame(width: 40, height: 40)
                        Image(systemName: session.platform.icon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(session.platform.color)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(session.displayPlatform)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color(.secondaryLabel))
                            if let stars = session.starRating {
                                Text("· \(stars)★")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Theme.Colors.warning)
                            }
                            Spacer()
                            Text(session.createdAt.formatted(.relative(presentation: .named)))
                                .font(.caption)
                                .foregroundStyle(Color(.tertiaryLabel))
                        }

                        Text(session.reviewText)
                            .font(.system(size: 14))
                            .foregroundStyle(Color(.label))
                            .lineLimit(isExpanded ? nil : 2)
                            .lineSpacing(3)
                    }

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color(.tertiaryLabel))
                        .padding(.leading, 4)
                }
                .padding(14)
            }
            .buttonStyle(.plain)

            // ── Expanded Responses ────────────────────────────────────────
            if isExpanded && !session.responses.isEmpty {
                Divider().padding(.horizontal, 14)

                VStack(spacing: 12) {
                    ForEach(session.responses.sorted { $0.createdAt < $1.createdAt }) { saved in
                        ResponseCard(response: saved)
                    }
                }
                .padding(14)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: Theme.Layout.cardCornerRadius)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

// MARK: - Empty State

private struct HistoryEmptyState: View {
    var body: some View {
        ContentUnavailableView {
            Label("No Replies Yet", systemImage: "clock")
        } description: {
            Text("Your generated review replies will appear here once you start composing.")
        }
    }
}
