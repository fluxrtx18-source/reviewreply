import SwiftUI

/// Root onboarding container — owns the 5-step state machine.
/// Writes `onboardingComplete = true` when the user subscribes or skips.
struct OnboardingContainerView: View {

    @AppStorage(UserDefaultsKeys.onboardingComplete) private var onboardingComplete = false

    @State private var step: OnboardingStep = .welcome
    @State private var selectedPlatforms: Set<String> = []

    var body: some View {
        ZStack {
            switch step {
            case .welcome:
                WelcomeStepView { advance(to: .features) }
                    .transition(welcomeTransition)

            case .features:
                CarouselStepView { advance(to: .platforms) }
                    .transition(slideTransition)

            case .platforms:
                PlatformPickerStepView(selected: $selectedPlatforms) { advance(to: .valueProof) }
                    .transition(slideTransition)

            case .valueProof:
                ValueDeliveryStepView { advance(to: .paywall) }
                    .transition(slideTransition)

            case .paywall:
                PaywallView(onDismiss: complete, isOnboarding: true)
                    .transition(slideTransition)
            }
        }
        // Animations are applied explicitly inside advance() for per-step control.
    }

    // MARK: - Transitions  (matches QuizzerAI pattern)

    private var welcomeTransition: AnyTransition {
        .asymmetric(
            insertion: .opacity,
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }

    private var slideTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing),
            removal:   .move(edge: .leading)
        )
    }

    // MARK: - Navigation

    private func advance(to next: OnboardingStep) {
        withAnimation(.easeInOut(duration: 0.38)) { step = next }
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
