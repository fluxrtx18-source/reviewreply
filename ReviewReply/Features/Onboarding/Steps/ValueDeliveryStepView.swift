import SwiftUI

/// Step 3 — Before/after proof cards. Mirrors QuizzerAI PersonalisedSolutionStepView.
struct ValueDeliveryStepView: View {

    let onContinue: () -> Void

    @State private var visibleItems: Set<Int> = []

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 8) {
                    Text("Here's how\nReviewReply works")
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color(.label))
                        .multilineTextAlignment(.center)

                    Text("Scroll through what changes for your business.")
                        .font(.system(size: 16))
                        .foregroundStyle(Color(.secondaryLabel))
                }
                .padding(.bottom, 36)

                // Value items
                VStack(spacing: 14) {
                    ForEach(Array(ValueItem.all.enumerated()), id: \.element.id) { idx, item in
                        ValueItemRow(item: item)
                            .opacity(visibleItems.contains(idx) ? 1 : 0)
                            .offset(y: visibleItems.contains(idx) ? 0 : 16)
                            .animation(.easeOut(duration: 0.4).delay(Double(idx) * 0.12), value: visibleItems)
                    }
                }
                .padding(.horizontal, 24)

                Spacer()
                Spacer()

                Button("See Pricing", action: onContinue)
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal, 24)
                    .padding(.bottom, 44)
            }
        }
        .onAppear {
            for i in 0..<ValueItem.all.count {
                visibleItems.insert(i)
            }
        }
    }
}

// MARK: - Value Row

private struct ValueItemRow: View {

    let item: ValueItem

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Theme.Colors.primary.opacity(0.1))
                    .frame(width: 42, height: 42)
                Image(systemName: item.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Theme.Colors.primary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.before)
                    .font(.system(size: 13))
                    .foregroundStyle(Color(.tertiaryLabel))
                    .strikethrough(true, color: Color(.tertiaryLabel))

                Text(item.after)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color(.label))
            }

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: Theme.Layout.cardCornerRadius)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

#Preview { ValueDeliveryStepView {} }
