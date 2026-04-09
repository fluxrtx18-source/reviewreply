import SwiftUI

/// Cinematic step progress indicator — connected circles with icons.
/// Adapted from Adam Lyttle's OnboardingCinematicView pattern.
struct OnboardingProgressIndicator: View {

    let currentStep: OnboardingStep

    /// Only show progress for the first 4 steps (paywall is full-screen).
    private let visibleSteps: [OnboardingStep] = [.welcome, .features, .platforms, .valueProof]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(visibleSteps.enumerated()), id: \.element) { index, step in

                if index > 0 {
                    // Connecting line
                    Rectangle()
                        .fill(currentStep.rawValue >= step.rawValue
                              ? Theme.Colors.primary
                              : Color(.systemFill).opacity(0.3))
                        .frame(height: 2)
                        .padding(.horizontal, 4)
                }

                // Step circle
                ZStack {
                    Circle()
                        .fill(currentStep.rawValue >= step.rawValue
                              ? Theme.Colors.primary
                              : Color(.systemFill).opacity(0.3))
                        .frame(width: 32, height: 32)

                    Image(systemName: step.icon)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(currentStep.rawValue >= step.rawValue ? .white : Color(.secondaryLabel))
                }
                .scaleEffect(currentStep == step ? 1.15 : 0.85)
                .animation(.spring(response: 0.35), value: currentStep)
            }
        }
        .padding(.horizontal, 44)
    }
}

#Preview {
    VStack(spacing: 40) {
        OnboardingProgressIndicator(currentStep: .welcome)
        OnboardingProgressIndicator(currentStep: .features)
        OnboardingProgressIndicator(currentStep: .platforms)
        OnboardingProgressIndicator(currentStep: .valueProof)
    }
}
