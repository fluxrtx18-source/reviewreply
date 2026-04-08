import SwiftUI
import SwiftData

struct ComposeView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(StoreService.self) private var store

    @State private var viewModel: ComposeViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let vm = viewModel {
                    ComposeFormView(viewModel: vm)
                        .navigationDestination(isPresented: Binding(
                            get: { vm.navigateToResponses },
                            set: { if !$0 { vm.navigateToResponses = false } }
                        )) {
                            ResponsesView(viewModel: vm)
                        }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Compose")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            if viewModel == nil {
                viewModel = ComposeViewModel(modelContext: modelContext)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .reviewReplyDidReceiveSharedText)) { note in
            guard let text = note.object as? String else { return }
            viewModel?.reviewText = text
        }
        .sheet(isPresented: Binding(
            get: { viewModel?.showPaywall ?? false },
            set: { viewModel?.showPaywall = $0 }
        )) {
            PaywallView(onDismiss: { viewModel?.showPaywall = false }, isOnboarding: false)
        }
    }
}

// MARK: - Form

private struct ComposeFormView: View {

    @Bindable var viewModel: ComposeViewModel
    @Environment(StoreService.self) private var store
    @FocusState private var reviewFieldFocused: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // ── Platform Picker ──────────────────────────────────────
                VStack(alignment: .leading, spacing: 10) {
                    SectionLabel("Platform")

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(ReviewPlatform.allCases) { platform in
                                PlatformPill(
                                    platform: platform,
                                    isSelected: viewModel.selectedPlatform == platform
                                ) {
                                    withAnimation(.spring(response: 0.3)) {
                                        viewModel.selectedPlatform = platform
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 1)
                    }

                    if viewModel.selectedPlatform == .other {
                        TextField("Platform name (e.g. Trustpilot)", text: $viewModel.customPlatformName)
                            .textFieldStyle(.roundedBorder)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }

                // ── Star Rating ──────────────────────────────────────────
                VStack(alignment: .leading, spacing: 10) {
                    SectionLabel("Star Rating (optional)")
                    StarRatingPicker(rating: $viewModel.starRating)
                }

                // ── Review Text ──────────────────────────────────────────
                VStack(alignment: .leading, spacing: 10) {
                    SectionLabel("Review Text")

                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: Theme.Layout.cardCornerRadius)
                            .fill(Color(.secondarySystemBackground))
                            .frame(minHeight: 140)

                        TextEditor(text: $viewModel.reviewText)
                            .focused($reviewFieldFocused)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 120)
                            .padding(10)

                        if viewModel.reviewText.isEmpty {
                            Text("Paste the customer review here…")
                                .foregroundStyle(Color(.placeholderText))
                                .font(.body)
                                .padding(.top, 18)
                                .padding(.leading, 14)
                                .allowsHitTesting(false)
                        }
                    }

                    if !viewModel.reviewText.isEmpty {
                        HStack {
                            Spacer()
                            Button("Clear") {
                                viewModel.reviewText = ""
                                reviewFieldFocused = false
                            }
                            .font(.footnote)
                            .foregroundStyle(Color(.secondaryLabel))
                        }
                    }
                }

                // ── Usage Banner ─────────────────────────────────────────
                if !store.isPremium && !UsageLimiter.canUseForFree {
                    UsageLimitBanner()
                }

                // ── Error ────────────────────────────────────────────────
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(Theme.Colors.error)
                        .padding(.horizontal, 4)
                }

                // ── Generate Button ──────────────────────────────────────
                Button {
                    reviewFieldFocused = false
                    Task { await viewModel.generate(store: store) }
                } label: {
                    HStack(spacing: 8) {
                        if viewModel.isGenerating {
                            ProgressView().tint(.white).scaleEffect(0.85)
                        } else {
                            Image(systemName: "wand.and.stars")
                        }
                        Text(viewModel.isGenerating ? "Generating…" : "Generate Replies")
                    }
                }
                .buttonStyle(PrimaryButtonStyle(isLoading: viewModel.isGenerating))
                .disabled(!viewModel.canGenerate)
            }
            .padding(Theme.Layout.padding)
            .animation(.easeInOut(duration: 0.2), value: viewModel.selectedPlatform)
        }
        .scrollDismissesKeyboard(.interactively)
    }
}

// MARK: - Supporting Views

private struct SectionLabel: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(Color(.secondaryLabel))
            .textCase(.uppercase)
            .tracking(0.8)
    }
}

private struct PlatformPill: View {

    let platform: ReviewPlatform
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: platform.icon)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(isSelected ? .white : platform.color)
                Text(platform.rawValue)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(isSelected ? .white : Color(.label))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Theme.Colors.primary : Color(.secondarySystemBackground))
            )
        }
        .buttonStyle(.plain)
    }
}

private struct StarRatingPicker: View {

    @Binding var rating: Int?

    var body: some View {
        HStack(spacing: 6) {
            ForEach(1...5, id: \.self) { star in
                Button {
                    withAnimation(.spring(response: 0.25)) {
                        rating = rating == star ? nil : star
                    }
                } label: {
                    Image(systemName: (rating ?? 0) >= star ? "star.fill" : "star")
                        .font(.system(size: 28))
                        .foregroundStyle((rating ?? 0) >= star ? Theme.Colors.warning : Color(.systemFill))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(star) star\(star == 1 ? "" : "s")")
                .accessibilityAddTraits((rating ?? 0) >= star ? .isSelected : [])
            }
            if rating != nil {
                Button { withAnimation { rating = nil } } label: {
                    Text("Clear")
                        .font(.footnote)
                        .foregroundStyle(Color(.secondaryLabel))
                }
                .padding(.leading, 4)
            }
        }
    }
}

private struct UsageLimitBanner: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "clock.badge.exclamationmark")
                .foregroundStyle(Theme.Colors.warning)
                .font(.title3)
            VStack(alignment: .leading, spacing: 2) {
                Text("Free reply used for today")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color(.label))
                Text(UsageLimiter.resetCountdown)
                    .font(.caption)
                    .foregroundStyle(Color(.secondaryLabel))
            }
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Theme.Colors.warning.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Theme.Colors.warning.opacity(0.3), lineWidth: 1)
                )
        )
    }
}
