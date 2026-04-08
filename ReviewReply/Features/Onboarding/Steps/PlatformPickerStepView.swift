import SwiftUI

/// Step 2 — Multi-select: which platforms does this business manage?
struct PlatformPickerStepView: View {

    @Binding var selected: Set<String>
    let onContinue: () -> Void

    private let platforms = ReviewPlatform.allCases

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 8) {
                    Text("Which platforms\ndo you manage?")
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color(.label))
                        .multilineTextAlignment(.center)

                    Text("We'll tailor the responses to each platform's tone and norms.")
                        .font(.system(size: 16))
                        .foregroundStyle(Color(.secondaryLabel))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(.bottom, 44)

                // Platform grid
                VStack(spacing: 14) {
                    ForEach(platforms) { platform in
                        PlatformRowButton(
                            platform: platform,
                            isSelected: selected.contains(platform.rawValue)
                        ) {
                            togglePlatform(platform)
                        }
                    }
                }
                .padding(.horizontal, 24)

                Spacer()
                Spacer()

                VStack(spacing: 12) {
                    Button(selected.isEmpty ? "Skip for Now" : "Continue") {
                        onContinue()
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    if !selected.isEmpty {
                        Text("\(selected.count) platform\(selected.count == 1 ? "" : "s") selected")
                            .font(.footnote)
                            .foregroundStyle(Color(.tertiaryLabel))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 44)
            }
        }
    }

    private func togglePlatform(_ platform: ReviewPlatform) {
        withAnimation(.spring(response: 0.25)) {
            if selected.contains(platform.rawValue) {
                selected.remove(platform.rawValue)
            } else {
                selected.insert(platform.rawValue)
            }
        }
    }
}

// MARK: - Row Button

private struct PlatformRowButton: View {

    let platform: ReviewPlatform
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? platform.color.opacity(0.15) : Color(.tertiarySystemBackground))
                        .frame(width: 44, height: 44)

                    Image(systemName: platform.icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(isSelected ? platform.color : Color(.secondaryLabel))
                }

                Text(platform.rawValue)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color(.label))

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected ? Theme.Colors.primary : Color(.systemFill))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: Theme.Layout.cardCornerRadius)
                    .fill(Color(.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.Layout.cardCornerRadius)
                            .strokeBorder(
                                isSelected ? Theme.Colors.primary.opacity(0.5) : Color.clear,
                                lineWidth: 1.5
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PlatformPickerStepView(selected: .constant(["Google"])) {}
}
