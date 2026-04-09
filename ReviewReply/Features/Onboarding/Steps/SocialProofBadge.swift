import SwiftUI

/// Bottom-of-screen social proof badge — contextual trust signal per onboarding step.
struct SocialProofBadge: View {

    let item: SocialProofItem

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: item.icon)
                .foregroundStyle(Theme.Colors.primary)
                .font(.system(size: 11, weight: .medium))
            Text(item.text)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color(.secondaryLabel))
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        if let item = SocialProofItem.forStep(.welcome) {
            SocialProofBadge(item: item)
        }
        if let item = SocialProofItem.forStep(.features) {
            SocialProofBadge(item: item)
        }
    }
}
