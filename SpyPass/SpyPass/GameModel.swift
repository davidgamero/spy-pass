import Foundation
import Combine

#if canImport(UIKit)
import UIKit
#endif

enum Phase: Equatable {
    case setup
    case deal
    case done
}

struct GameState: Equatable {
    var phase: Phase = .setup
    var names: [String] = []
    var secret = ""
    var spyIndex = 0
    var current = 0
    var revealed = false
    var showAnswer = false
}

@MainActor
final class GameModel: ObservableObject {
    static let revealDuration = 3.5
    static let handoffLock = 0.7
    static let minPlayers = 3
    static let maxNameLength = 40

    @Published private(set) var state = GameState()

    private var revealTask: Task<Void, Never>?
    private var revealLockedUntil = Date.distantPast

    init() {
        #if DEBUG
        configureScreenshotState()
        #endif
    }

    var canDeal: Bool { state.names.count >= Self.minPlayers }
    var playerCount: Int { state.names.count }

    func addNames(_ input: String) {
        let separators = CharacterSet(charactersIn: ",\n\r")
        let additions = input
            .components(separatedBy: separators)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { String($0.prefix(Self.maxNameLength)) }

        guard !additions.isEmpty else { return }
        state.names.append(contentsOf: additions)
    }

    func removeName(at index: Int) {
        guard state.phase == .setup, state.names.indices.contains(index) else { return }
        state.names.remove(at: index)
    }

    func deal() {
        guard canDeal else { return }
        revealTask?.cancel()
        var generator = SystemRandomNumberGenerator()
        state.secret = state.names.randomElement(using: &generator) ?? ""
        state.spyIndex = Int.random(in: state.names.indices, using: &generator)
        state.current = 0
        state.revealed = false
        state.showAnswer = false
        state.phase = .deal
        revealLockedUntil = .distantPast
    }

    func showCard() {
        guard state.phase == .deal,
              !state.revealed,
              Date() >= revealLockedUntil else { return }

        state.revealed = true
        revealTask?.cancel()
        revealFeedback()

        revealTask = Task { [weak self] in
            do {
                try await Task.sleep(for: .seconds(Self.revealDuration))
                guard !Task.isCancelled else { return }
                self?.advance()
            } catch {
                // Cancellation is expected whenever a card is hidden manually.
            }
        }
    }

    func advance() {
        guard state.phase == .deal, state.revealed else { return }
        revealTask?.cancel()
        revealTask = nil
        state.revealed = false
        revealLockedUntil = Date().addingTimeInterval(Self.handoffLock)
        hideFeedback()

        if state.current < state.names.count - 1 {
            state.current += 1
        } else {
            state.phase = .done
        }
    }

    func quit() {
        revealTask?.cancel()
        revealTask = nil
        state.revealed = false
        state.phase = .setup
    }

    func revealAnswer() {
        guard state.phase == .done else { return }
        state.showAnswer = true
    }

    func changeNames() {
        revealTask?.cancel()
        revealTask = nil
        state.revealed = false
        state.showAnswer = false
        state.phase = .setup
    }

    func applicationDidEnterBackground() {
        // A visible secret must never be restored from the app switcher.
        if state.phase == .deal, state.revealed {
            advance()
        }
    }

    private func revealFeedback() {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
    }

    private func hideFeedback() {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        #endif
    }

    #if DEBUG
    private func configureScreenshotState() {
        let arguments = ProcessInfo.processInfo.arguments
        guard let flagIndex = arguments.firstIndex(of: "--screenshot-state"),
              arguments.indices.contains(flagIndex + 1) else { return }

        state.names = [
            "Sherlock Holmes",
            "Cleopatra",
            "Albert Einstein",
            "Marie Curie",
            "Robin Hood"
        ]
        state.secret = "Sherlock Holmes"
        state.spyIndex = 4
        state.current = 0
        state.revealed = false
        state.showAnswer = false

        switch arguments[flagIndex + 1] {
        case "setup":
            state.phase = .setup
        case "hidden":
            state.phase = .deal
        case "secret":
            state.phase = .deal
            state.current = 1
            state.revealed = true
        case "spy":
            state.phase = .deal
            state.current = state.spyIndex
            state.revealed = true
        case "discussion":
            state.phase = .done
        default:
            state = GameState()
        }
    }
    #endif
}
