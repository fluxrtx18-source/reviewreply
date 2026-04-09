import SwiftUI

/// Step 1 — Feature carousel with 3 cards. Matches QuizzerAI CarouselStepView pattern.
struct CarouselStepView: View {

    let onContinue: () -> Void

    @State private var currentCard = 0

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip
                HStack {
                    Spacer()
                    Button("Skip") { onContinue() }
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color(.secondaryLabel))
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                }
                .frame(height: 50)

                // Cards
                TabView(selection: $currentCard) {
                    ForEach(Array(OnboardingFeatureCard.all.enumerated()), id: \.element.id) { index, card in
                        FeatureCardView(card: card)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Page dots
                HStack(spacing: 8) {
                    ForEach(0..<OnboardingFeatureCard.all.count, id: \.self) { i in
                        Capsule()
                            .fill(i == currentCard
                                ? AnyShapeStyle(Theme.Gradients.aiGlow)
                                : AnyShapeStyle(Color(.systemFill)))
                            .frame(width: i == currentCard ? 28 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: currentCard)
                    }
                }
                .padding(.bottom, 36)

                // CTA
                VStack(spacing: 12) {
                    Button(currentCard < OnboardingFeatureCard.all.count - 1 ? "Continue" : "Next") {
                        if currentCard < OnboardingFeatureCard.all.count - 1 {
                            withAnimation(.spring(response: 0.4)) { currentCard += 1 }
                        } else {
                            onContinue()
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    if let proof = SocialProofItem.forStep(.features) {
                        SocialProofBadge(item: proof)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 44)
            }
        }
    }
}

// MARK: - Single Card

private struct FeatureCardView: View {

    let card: OnboardingFeatureCard
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color(hex: card.accentHex).opacity(0.1))
                    .frame(width: 200, height: 200)
                    .blur(radius: 40)

                Circle()
                    .fill(Color(.secondarySystemBackground))
                    .frame(width: 110, height: 110)
                    .shadow(color: Color(hex: card.accentHex).opacity(0.2), radius: 30, y: 12)

                Image(systemName: card.icon)
                    .font(.system(size: 36, weight: .light))
                    .foregroundStyle(Color(hex: card.accentHex))
                    .scaleEffect(isAnimating ? 1 : 0.5)
                    .opacity(isAnimating ? 1 : 0)
            }
            .padding(.bottom, 40)

            Text(card.headline)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(Color(.label))
                .multilineTextAlignment(.center)

            Text(card.body)
                .font(.system(size: 16))
                .foregroundStyle(Color(.secondaryLabel))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 40)
                .padding(.top, 12)

            Spacer()
            Spacer()
        }
        .onAppear { withAnimation(.easeOut(duration: 0.5)) { isAnimating = true } }
        .onDisappear { isAnimating = false }
    }
}

#Preview { CarouselStepView {} }
