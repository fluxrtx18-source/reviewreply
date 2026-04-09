import SwiftUI

/// Root onboarding container — owns the 5-step state machine with cinematic transitions.
/// Writes `onboardingComplete = true` when the user subscribes or skips.
struct OnboardingContainerView: View {

    @AppStorage(UserDefaultsKeys.onboardingComplete) private var onboardingComplete = false

    @State private var step: OnboardingStep = .welcome
    @State private var selectedPlatforms: Set<String> = []
    @State private var contentOpacity: Double = 1

    var body: some View {
        ZStack {
            // ── Step Content ─────────────────────────────────────────────
            Group {
                switch step {
                case .welcome:
                    WelcomeStepView { advance(to: .features) }

                case .features:
                    CarouselStepView { advance(to: .platforms) }

                case .platforms:
                    PlatformPickerStepView(selected: $selectedPlatforms) { advance(to: .valueProof) }

                case .valueProof:
                    ValueDeliveryStepView { advance(to: .paywall) }

                case .paywall:
                    PaywallView(onDismiss: complete, isOnboarding: true)
                }
            }
            .opacity(contentOpacity)

            // ── Cinematic Progress Indicator (top overlay, hidden on paywall) ──
            if step != .paywall {
                VStack {
                    OnboardingProgressIndicator(currentStep: step)
                        .padding(.top, 16)
                    Spacer()
                }
            }
        }
    }

    // MARK: - Cinematic Navigation (fade-out → switch → fade-in)

    private func advance(to next: OnboardingStep) {
        withAnimation(.easeOut(duration: 0.25)) {
            contentOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            step = next
            withAnimation(.easeIn(duration: 0.3)) {
                contentOpacity = 1
            }
        }
    }

    private func complete() {
        if !selectedPlatforms.isEmpty {
            UserDefaults.standard.set(Array(selectedPlatforms), forKey: UserDefaultsKeys.managedPlatforms)
        }
        withAnimation(.easeOut(duration: 0.3)) { onboardingComplete = true }
    }
}

#Preview {
    OnboardingContainerView()
        .environment(StoreService.shared)
}
