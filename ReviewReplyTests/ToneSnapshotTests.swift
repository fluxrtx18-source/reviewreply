import Testing
@testable import ReviewReply

// MARK: - ToneSnapshot Tests

@Suite("ToneSnapshot")
struct ToneSnapshotTests {

    @Test("ToneSnapshot is Sendable and retains values")
    func snapshotRetainsValues() {
        let snapshot = ToneSnapshot(
            name: "Empathetic",
            emoji: "💜",
            instruction: "Show deep understanding"
        )
        #expect(snapshot.name == "Empathetic")
        #expect(snapshot.emoji == "💜")
        #expect(snapshot.instruction == "Show deep understanding")
    }

    @Test("Snapshot can be sent across isolation boundaries")
    func sendableAcrossBoundaries() async {
        let snapshot = ToneSnapshot(name: "Firm", emoji: "💪", instruction: "Be assertive")

        let result: String = await Task.detached {
            return snapshot.name
        }.value

        #expect(result == "Firm")
    }
}
