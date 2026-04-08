import SwiftUI

/// Step 0 — Animated orb hero + headline.
/// Derived from Project_Carter animated orb pattern.
struct WelcomeStepView: View {

    let onContinue: () -> Void

    @State private var isAnimating = false
    @State private var pulseScale: CGFloat = 0.95

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            // Ambient background glow
            Circle()
                .fill(Theme.Colors.primary.opacity(0.08))
                .frame(width: 320, height: 320)
                .blur(radius: 120)
                .offset(x: -100, y: -250)

            Circle()
                .fill(Theme.Colors.success.opacity(0.06))
                .frame(width: 250, height: 250)
                .blur(radius: 100)
                .offset(x: 120, y: 280)

            VStack(spacing: 0) {
                Spacer()

                // ── Orb ──────────────────────────────────────────────────
                ZStack {
                    Circle()
                        .fill(RadialGradient(
                            colors: [Theme.Colors.primary.opacity(0.15), .clear],
                            center: .center,
                            startRadius: 40, endRadius: 140
                        ))
                        .frame(width: 280, height: 280)
                        .scaleEffect(pulseScale)

                    Circle()
                        .fill(Color(.secondarySystemBackground))
                        .frame(width: 120, height: 120)
                        .overlay(
                            Circle()
                                .strokeBorder(Theme.Colors.outline.opacity(0.12), lineWidth: 1)
                        )
                        .shadow(color: Theme.Colors.primary.opacity(0.2), radius: 40, y: 20)

                    Image(systemName: "star.bubble.fill")
                        .font(.system(size: 40, weight: .light))
                        .foregroundStyle(Theme.Gradients.aiGlow)
                        .scaleEffect(isAnimating ? 1.0 : 0.5)
                        .opacity(isAnimating ? 1.0 : 0.0)

                    // Floating decorators (matches Project_Carter style)
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.tertiarySystemBackground).opacity(0.8))
                        .frame(width: 38, height: 38)
                        .overlay(
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(Theme.Colors.success)
                        )
                        .offset(x: 88, y: -82)
                        .opacity(isAnimating ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(0.3), value: isAnimating)

                    Circle()
                        .fill(Color(.tertiarySystemBackground).opacity(0.8))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: "wand.and.stars")
                                .font(.system(size: 17))
                                .foregroundStyle(Theme.Colors.secondary)
                        )
                        .offset(x: -85, y: 65)
                        .opacity(isAnimating ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(0.4), value: isAnimating)
                }
                .padding(.bottom, 44)

                // ── Headline ──────────────────────────────────────────────
                VStack(spacing: 14) {
                    Text("Turn bad reviews\ninto \(Text("business wins").foregroundStyle(Theme.Colors.primary))")
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color(.label))
                        .multilineTextAlignment(.center)

                    Text("ReviewReply writes professional responses to your customer reviews in seconds — 100% on your iPhone, no cloud.")
                        .font(.system(size: 17))
                        .foregroundStyle(Color(.secondaryLabel))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 32)
                }
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.15), value: isAnimating)

                Spacer()
                Spacer()

                // ── CTA ───────────────────────────────────────────────────
                Button("Get Started", action: onContinue)
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)

                // Trust badge
                HStack(spacing: 8) {
                    Rectangle().fill(Theme.Colors.outline.opacity(0.4)).frame(width: 24, height: 1)
                    Text("PRIVATE · ON-DEVICE AI · NO CLOUD")
                        .font(.system(size: 9, weight: .medium)).tracking(1.5)
                        .foregroundStyle(Color(.tertiaryLabel))
                    Rectangle().fill(Theme.Colors.outline.opacity(0.4)).frame(width: 24, height: 1)
                }
                .padding(.bottom, 44)
            }
        }
        .onAppear {
            isAnimating = true
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                pulseScale = 1.05
            }
        }
    }
}

#Preview { WelcomeStepView {} }
