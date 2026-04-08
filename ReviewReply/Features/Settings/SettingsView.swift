import SwiftUI
import SwiftData

struct SettingsView: View {

    @Environment(StoreService.self) private var store
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            List {

                // ── Tones ─────────────────────────────────────────────────
                Section {
                    NavigationLink {
                        ToneEditorView()
                    } label: {
                        Label("Response Tones", systemImage: "slider.horizontal.3")
                    }
                } header: {
                    Text("Customise")
                }

                // ── Subscription ──────────────────────────────────────────
                Section {
                    if store.isPremium {
                        HStack {
                            Label("ReviewReply Pro", systemImage: "checkmark.seal.fill")
                                .foregroundStyle(Theme.Colors.primary)
                            Spacer()
                            Text("Active")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(Theme.Colors.success)
                        }
                    } else {
                        Button {
                            showPaywall = true
                        } label: {
                            HStack {
                                Label("Upgrade to Pro", systemImage: "sparkles")
                                    .foregroundStyle(Theme.Colors.primary)
                                Spacer()
                                Text("Unlimited replies")
                                    .font(.footnote)
                                    .foregroundStyle(Color(.tertiaryLabel))
                            }
                        }

                        // Free tier info
                        HStack {
                            Label("Free Tier", systemImage: "gift")
                            Spacer()
                            Text(UsageLimiter.canUseForFree ? "1 reply available today" : UsageLimiter.resetCountdown)
                                .font(.footnote)
                                .foregroundStyle(
                                    UsageLimiter.canUseForFree ? Theme.Colors.success : Color(.tertiaryLabel)
                                )
                        }
                    }

                    Button {
                        Task { try? await store.restorePurchases() }
                    } label: {
                        Label("Restore Purchases", systemImage: "arrow.clockwise")
                    }
                } header: {
                    Text("Subscription")
                }

                // ── About ─────────────────────────────────────────────────
                Section {
                    HStack {
                        Label("Version", systemImage: "info.circle")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundStyle(Color(.secondaryLabel))
                    }
                    Label("On-Device AI · Private by Design", systemImage: "lock.shield")
                        .foregroundStyle(Color(.secondaryLabel))
                        .font(.footnote)
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showPaywall) {
                PaywallView(onDismiss: { showPaywall = false }, isOnboarding: false)
            }
        }
    }
}
