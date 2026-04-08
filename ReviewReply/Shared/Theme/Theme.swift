import SwiftUI

// MARK: - Design System

enum Theme {
    enum Colors {
        static let primary    = Color(hex: "#2B5CE6")
        static let secondary  = Color(hex: "#0EA5E9")
        static let success    = Color(hex: "#10B981")
        static let warning    = Color(hex: "#F59E0B")
        static let error      = Color(hex: "#EF4444")

        static let background         = Color(.systemBackground)
        static let surface            = Color(.secondarySystemBackground)
        static let surfaceElevated    = Color(.tertiarySystemBackground)
        static let onSurface          = Color(.label)
        static let onSurfaceVariant   = Color(.secondaryLabel)
        static let outline            = Color(.separator)
    }

    enum Gradients {
        static let primaryCTA = LinearGradient(
            colors: [Color(hex: "#2B5CE6"), Color(hex: "#0EA5E9")],
            startPoint: .leading, endPoint: .trailing
        )
        static let successCTA = LinearGradient(
            colors: [Color(hex: "#10B981"), Color(hex: "#34D399")],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
        static let aiGlow = LinearGradient(
            colors: [Color(hex: "#2B5CE6"), Color(hex: "#0EA5E9")],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    enum Layout {
        static let cardCornerRadius: CGFloat   = 16
        static let buttonCornerRadius: CGFloat = 14
        static let padding: CGFloat            = 20
        static let smallPadding: CGFloat       = 12
    }
}

// MARK: - Color Hex Init

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:  (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Primary Button Style

struct PrimaryButtonStyle: ButtonStyle {
    var isLoading: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                Group {
                    if isLoading || configuration.isPressed {
                        Theme.Gradients.primaryCTA.opacity(0.7)
                    } else {
                        Theme.Gradients.primaryCTA
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: Theme.Layout.buttonCornerRadius))
            .shadow(color: Theme.Colors.primary.opacity(0.25), radius: 20, y: 8)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.2), value: configuration.isPressed)
    }
}
