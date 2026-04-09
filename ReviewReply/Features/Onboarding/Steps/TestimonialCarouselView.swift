import SwiftUI

/// Rotating testimonial carousel — cinematic social proof for the welcome step.
/// Adapted from Adam Lyttle's OnboardingTestimonialView pattern, using initials
/// instead of avatar images (no external assets required).
struct TestimonialCarouselView: View {

    private let testimonials = Testimonial.all
    @State private var currentIndex = 0
    @State private var opacity: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            if !testimonials.isEmpty {
                testimonialCard(testimonials[currentIndex])
                    .opacity(opacity)
                    .scaleEffect(opacity == 1 ? 1 : 0.95)
                    .animation(.easeInOut(duration: 0.4), value: opacity)
            }
        }
        .onAppear { startCycle() }
    }

    // MARK: - Card

    private func testimonialCard(_ testimonial: Testimonial) -> some View {
        VStack(spacing: 16) {

            // Avatar + stars
            HStack(spacing: 14) {
                // Initials circle
                ZStack {
                    Circle()
                        .fill(Theme.Colors.primary.opacity(0.12))
                        .frame(width: 48, height: 48)
                    Text(testimonial.initials)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Theme.Colors.primary)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(testimonial.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color(.label))
                    Text(testimonial.role)
                        .font(.system(size: 12))
                        .foregroundStyle(Color(.secondaryLabel))
                }

                Spacer()

                // Stars
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= testimonial.stars ? "star.fill" : "star")
                            .font(.system(size: 11))
                            .foregroundStyle(star <= testimonial.stars ? Theme.Colors.warning : Color(.systemFill))
                    }
                }
            }

            // Quote
            Text("\"\(testimonial.quote)\"")
                .font(.system(size: 15, design: .serif))
                .italic()
                .foregroundStyle(Color(.label))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: Theme.Layout.cardCornerRadius)
                .fill(Color(.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Layout.cardCornerRadius)
                        .strokeBorder(Theme.Colors.outline.opacity(0.15), lineWidth: 1)
                )
        )
        .padding(.horizontal, 24)
    }

    // MARK: - Auto-Rotate

    private func startCycle() {
        opacity = 1
        guard testimonials.count > 1 else { return }

        Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(3.5))
                // Fade out
                withAnimation { opacity = 0 }
                try? await Task.sleep(for: .milliseconds(400))
                // Advance and fade in
                currentIndex = (currentIndex + 1) % testimonials.count
                withAnimation { opacity = 1 }
            }
        }
    }
}

#Preview {
    TestimonialCarouselView()
}
