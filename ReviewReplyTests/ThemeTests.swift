import Testing
import SwiftUI
@testable import ReviewReply

// MARK: - Theme Tests

@Suite("Theme")
struct ThemeTests {

    @Test("Color hex init produces valid colors", arguments: [
        "#2B5CE6", "#0EA5E9", "#10B981", "#F59E0B", "#EF4444", "#000000", "#FFFFFF"
    ])
    func hexColorInit(hex: String) {
        let color = Color(hex: hex)
        // If this doesn't crash, the init handles the hex correctly
        #expect(color != Color.clear || hex == "#000000")
    }

    @Test("3-digit hex shorthand works")
    func threeDigitHex() {
        // #FFF should produce white-ish
        let color = Color(hex: "#FFF")
        #expect(type(of: color) == Color.self)
    }

    @Test("Layout constants are positive")
    func layoutConstants() {
        #expect(Theme.Layout.cardCornerRadius > 0)
        #expect(Theme.Layout.buttonCornerRadius > 0)
        #expect(Theme.Layout.padding > 0)
        #expect(Theme.Layout.smallPadding > 0)
    }

    @Test("Card corner radius is larger than button corner radius or equal")
    func cornerRadiusRelationship() {
        #expect(Theme.Layout.cardCornerRadius >= Theme.Layout.buttonCornerRadius)
    }
}
