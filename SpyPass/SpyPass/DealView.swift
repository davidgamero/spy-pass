import SwiftUI

struct DealView: View {
    @ObservedObject var model: GameModel

    private var playerNumber: Int { model.state.current + 1 }
    private var player: (name: String, color: Color) { AppTheme.player(at: model.state.current) }
    private var isSpy: Bool { model.state.current == model.state.spyIndex }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Eyebrow(text: "Player \(playerNumber) of \(model.playerCount)", color: AppTheme.paper)
                Spacer()
                Button("Quit", action: model.quit)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(AppTheme.muted)
                    .frame(minWidth: 54, minHeight: 44)
            }
            .frame(maxWidth: 480)
            .padding(.horizontal, 20)
            .padding(.top, 8)

            ScrollView {
                VStack(spacing: 22) {
                    if model.state.revealed {
                        revealedContent
                    } else {
                        waitingContent
                    }
                }
                .frame(maxWidth: 480)
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 28)
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var waitingContent: some View {
        Group {
            Text(playerNumber == 1 ? "Player 1 starts." : "Pass the phone to\nthe next person.")
                .displayTitle(size: 35)
                .multilineTextAlignment(.center)
                .lineSpacing(-2)

            Button(action: model.showCard) {
                HiddenCardView(playerNumber: playerNumber, playerName: player.name, color: player.color)
            }
                .buttonStyle(.plain)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Show my card")

            Button(action: model.showCard) {
                VStack(spacing: 4) {
                    Text("Show my card")
                        .font(.title3.weight(.bold))
                    Text("Player \(playerNumber) · \(player.name) has not seen it yet")
                        .font(.caption.weight(.bold))
                        .opacity(0.7)
                }
            }
            .buttonStyle(FilledButtonStyle(fill: player.color, foreground: AppTheme.paperInk, height: 72))
            .accessibilityLabel("Show my card")

            Text("Only player \(playerNumber) should look at the screen.")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppTheme.muted)
                .multilineTextAlignment(.center)
        }
    }

    private var revealedContent: some View {
        Group {
            if isSpy {
                Text("You are the \(Text("spy.").foregroundStyle(AppTheme.red))")
                    .displayTitle(size: 35)
                    .multilineTextAlignment(.center)
            } else {
                Text("Remember this.")
                    .displayTitle(size: 35)
            }

            Button(action: model.advance) {
                RevealedCardView(
                    playerNumber: playerNumber,
                    playerName: player.name,
                    color: player.color,
                    secret: model.state.secret,
                    isSpy: isSpy
                )
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(isSpy ? "You are the spy" : "The secret name is \(model.state.secret)")
            .accessibilityHint("Hides automatically. Activate to hide now.")

            Text("Hides by itself. Tap the card to hide it now.")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppTheme.muted)
                .multilineTextAlignment(.center)
        }
    }
}

private struct HiddenCardView: View {
    let playerNumber: Int
    let playerName: String
    let color: Color

    var body: some View {
        VStack(spacing: 0) {
            cardTag("Player \(playerNumber) · \(playerName) · Not seen yet")
            Spacer()
            VStack(spacing: 0) {
                Text("Player")
                    .font(.caption.weight(.black))
                    .tracking(4)
                Text("\(playerNumber)")
                    .displayTitle(size: 116, color: AppTheme.paperInk)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
            }
            Text("Card hidden")
                .font(.caption.weight(.black))
                .tracking(2)
                .textCase(.uppercase)
                .foregroundStyle(AppTheme.paper)
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .background(AppTheme.paperInk)
                .padding(.horizontal, 28)
            Spacer()
            cardTag("Shows for 3.5 seconds")
        }
        .foregroundStyle(AppTheme.paperInk)
        .padding(18)
        .frame(maxWidth: 380)
        .aspectRatio(4 / 5, contentMode: .fit)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func cardTag(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.caption2.weight(.black))
            .tracking(1.1)
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineLimit(2)
    }
}

private struct RevealedCardView: View {
    let playerNumber: Int
    let playerName: String
    let color: Color
    let secret: String
    let isSpy: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var countdown: CGFloat = 1

    private var secretSize: CGFloat {
        switch secret.count {
        case 0...8: 66
        case 9...16: 54
        case 17...26: 44
        default: 36
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Text("\(isSpy ? "Your role" : "Secret name") · Player \(playerNumber) · \(playerName)".uppercased())
                .font(.caption2.weight(.black))
                .tracking(1.1)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            if isSpy {
                Text("SPY")
                    .displayTitle(size: 100, color: AppTheme.red)
                    .foregroundStyle(AppTheme.red)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            } else {
                Text(secret.uppercased())
                    .displayTitle(size: secretSize, color: AppTheme.paperInk)
                    .tracking(-1)
                    .multilineTextAlignment(.center)
                    .lineLimit(4)
                    .minimumScaleFactor(0.5)
                    .frame(maxWidth: .infinity)
            }
            Spacer()
            GeometryReader { geometry in
                Capsule()
                    .fill(AppTheme.paperInk.opacity(0.18))
                    .overlay(alignment: .leading) {
                        Capsule()
                            .fill(AppTheme.paperInk)
                            .frame(width: geometry.size.width * countdown)
                    }
            }
            .frame(height: 5)
            .accessibilityHidden(true)
        }
        .foregroundStyle(AppTheme.paperInk)
        .padding(18)
        .frame(maxWidth: 380)
        .aspectRatio(4 / 5, contentMode: .fit)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .onAppear {
            countdown = 1
            if !reduceMotion {
                withAnimation(.linear(duration: GameModel.revealDuration)) {
                    countdown = 0
                }
            }
        }
    }
}
