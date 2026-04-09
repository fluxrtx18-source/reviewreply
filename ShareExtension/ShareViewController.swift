import UIKit
import SwiftUI
import Social
import FoundationModels

// MARK: - Share Extension Entry Point
// Receives text shared from Google Maps, Yelp, App Store Connect, etc.
// Shows a mini-compose UI: preview the review → generate one quick reply → copy → done.

final class ShareViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        Task { @MainActor in
            let text = await extractSharedText()
            showShareSheet(reviewText: text ?? "")
        }
    }

    // MARK: - Text Extraction

    private func extractSharedText() async -> String? {
        guard let extensionItems = extensionContext?.inputItems as? [NSExtensionItem] else {
            return nil
        }

        for item in extensionItems {
            for provider in (item.attachments ?? []) {
                if provider.hasItemConformingToTypeIdentifier("public.plain-text") {
                    let data = try? await provider.loadItem(forTypeIdentifier: "public.plain-text")
                    return data as? String
                }
                if provider.hasItemConformingToTypeIdentifier("public.url") {
                    let data = try? await provider.loadItem(forTypeIdentifier: "public.url")
                    return (data as? URL)?.absoluteString
                }
            }
            if let text = item.attributedContentText?.string, !text.isEmpty {
                return text
            }
        }
        return nil
    }

    // MARK: - Show SwiftUI Sheet

    private func showShareSheet(reviewText: String) {
        let shareView = ShareComposeView(
            reviewText: reviewText,
            onDone: { [weak self] in
                self?.extensionContext?.completeRequest(returningItems: nil)
            },
            onCancel: { [weak self] in
                self?.extensionContext?.cancelRequest(withError: NSError(domain: "ReviewReply", code: 0))
            }
        )

        let host = UIHostingController(rootView: shareView)
        host.view.backgroundColor = .clear
        addChild(host)
        view.addSubview(host.view)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        host.didMove(toParent: self)
    }
}

// MARK: - SwiftUI Compose View (inside extension)

private struct ShareComposeView: View {

    let reviewText: String
    let onDone: () -> Void
    let onCancel: () -> Void

    @State private var generatedReply: String = ""
    @State private var isGenerating = false
    @State private var copied = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Review preview
                VStack(alignment: .leading, spacing: 8) {
                    Text("Review")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color(.secondaryLabel))
                        .textCase(.uppercase)
                        .tracking(0.8)

                    ScrollView {
                        Text(reviewText.isEmpty ? "(No text detected)" : reviewText)
                            .font(.system(size: 14))
                            .foregroundStyle(reviewText.isEmpty ? Color(.tertiaryLabel) : Color(.label))
                            .lineSpacing(4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxHeight: 100)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.secondarySystemBackground))
                    )
                }

                // Generated reply
                if !generatedReply.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Professional Reply")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color(.secondaryLabel))
                            .textCase(.uppercase)
                            .tracking(0.8)

                        Text(generatedReply)
                            .font(.system(size: 14))
                            .lineSpacing(4)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.secondarySystemBackground))
                            )

                        Button {
                            UIPasteboard.general.string = generatedReply
                            SharedResponseStore.append(generatedReply)
                            copied = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { onDone() }
                        } label: {
                            Label(copied ? "Copied! Closing…" : "Copy & Close", systemImage: copied ? "checkmark" : "doc.on.doc")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(copied ? Color(hex: "#10B981") : Color(hex: "#2B5CE6"))
                                )
                        }
                        .buttonStyle(.plain)
                        .animation(.spring(response: 0.3), value: copied)
                    }
                } else {
                    if let err = errorMessage {
                        Text(err).font(.footnote).foregroundStyle(Color(hex: "#EF4444"))
                    }

                    Button {
                        Task { await generateReply() }
                    } label: {
                        HStack(spacing: 8) {
                            if isGenerating { ProgressView().tint(.white).scaleEffect(0.85) }
                            else { Image(systemName: "wand.and.stars") }
                            Text(isGenerating ? "Generating…" : "Generate Professional Reply")
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(isGenerating ? Color(hex: "#2B5CE6").opacity(0.7) : Color(hex: "#2B5CE6"))
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(isGenerating || reviewText.isEmpty)
                }

                Spacer()
            }
            .padding(20)
            .navigationTitle("ReviewReply")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", action: onCancel)
                }
            }
        }
    }

    // MARK: - Quota Check (mirrors UsageLimiter using shared group defaults)

    private var isPremium: Bool {
        let defaults = UserDefaults(suiteName: "group.com.reviewreply.shared")
        return defaults?.bool(forKey: "com.reviewreply.isPremium") ?? false
    }

    private var canUseForFree: Bool {
        let defaults = UserDefaults(suiteName: "group.com.reviewreply.shared") ?? .standard
        guard let last = defaults.object(forKey: "com.reviewreply.lastFreeReplyDate") as? Date else { return true }
        return !Calendar.current.isDateInToday(last)
    }

    private func recordUsage() {
        let defaults = UserDefaults(suiteName: "group.com.reviewreply.shared")
        defaults?.set(Date(), forKey: "com.reviewreply.lastFreeReplyDate")
    }

    private func generateReply() async {
        guard isPremium || canUseForFree else {
            errorMessage = "Free reply used for today. Open ReviewReply to upgrade or wait until tomorrow."
            return
        }

        let shouldTrackUsage = !isPremium
        if shouldTrackUsage { recordUsage() }

        isGenerating = true
        errorMessage = nil
        do {
            let session = LanguageModelSession(
                instructions: "You are a customer service expert. Write a professional, empathetic reply to a customer review in 2-3 sentences. Do not use placeholder text."
            )
            let result = try await session.respond(
                to: "Write a professional reply to this review: \"\(reviewText)\""
            )
            generatedReply = result.content
        } catch {
            // Undo usage on failure so user isn't penalised
            if shouldTrackUsage {
                let defaults = UserDefaults(suiteName: "group.com.reviewreply.shared")
                defaults?.removeObject(forKey: "com.reviewreply.lastFreeReplyDate")
            }
            errorMessage = "Couldn't generate a reply. Please try in the main app."
        }
        isGenerating = false
    }
}

// Shared store accessible from extension (same app group)
private enum SharedResponseStore {
    static func append(_ text: String) {
        let defaults = UserDefaults(suiteName: "group.com.reviewreply.shared")
        var existing = defaults?.stringArray(forKey: "com.reviewreply.recentResponses") ?? []
        existing.removeAll { $0 == text }
        existing.insert(text, at: 0)
        defaults?.set(Array(existing.prefix(10)), forKey: "com.reviewreply.recentResponses")
    }
}

// Hex color convenience (duplicated here — extensions can't import main module)
private extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
