import Testing
@testable import SpyPass

@MainActor
struct SpyPassTests {
    @Test func parsesAndTrimsMultipleNames() {
        let model = GameModel()

        model.addNames("  Alice, Bob\n\nCharlie  ")

        #expect(model.state.names == ["Alice", "Bob", "Charlie"])
        #expect(model.canDeal)
    }

    @Test func limitsEveryNameToFortyCharacters() {
        let model = GameModel()
        let longName = String(repeating: "A", count: 60)

        model.addNames("\(longName), \(longName)")

        #expect(model.state.names.count == 2)
        #expect(model.state.names.allSatisfy { $0.count == GameModel.maxNameLength })
    }

    @Test func dealKeepsSecretAndSpyInBounds() {
        let model = GameModel()
        model.addNames("A, B, C, D")

        model.deal()

        #expect(model.state.phase == .deal)
        #expect(model.state.names.contains(model.state.secret))
        #expect(model.state.names.indices.contains(model.state.spyIndex))
        #expect(model.state.current == 0)
        #expect(!model.state.revealed)
    }

    @Test func quitKeepsNames() {
        let model = GameModel()
        model.addNames("A, B, C")
        model.deal()

        model.quit()

        #expect(model.state.phase == .setup)
        #expect(model.state.names == ["A", "B", "C"])
    }
}
