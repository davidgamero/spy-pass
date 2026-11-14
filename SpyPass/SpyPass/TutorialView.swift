import SwiftUI

struct TutorialView: View {
    let onFinish: () -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var page: Int

    private let pageCount = 4

    init(initialPage: Int = 0, onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
        _page = State(initialValue: initialPage)
    }

    var body: some View {
        ZStack {
            AppTheme.ink.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Text("How to play")
                        .font(.headline)
                        .foregroundStyle(AppTheme.paper)
                    Spacer()
                    Button("Skip", action: finish)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(AppTheme.muted)
                        .frame(minWidth: 52, minHeight: 44)
                        .accessibilityIdentifier("tutorial-skip")
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                HStack(spacing: 8) {
                    ForEach(0..<pageCount, id: \.self) { index in
                        Capsule()
                            .fill(index <= page ? AppTheme.red : AppTheme.line)
                            .frame(height: 4)
                            .accessibilityHidden(true)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 8)

                ScrollView {
                    pageContent
                        .id(page)
                        .frame(maxWidth: 480)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 22)
                        .frame(maxWidth: .infinity)
                }

                HStack(spacing: 12) {
                    if page > 0 {
                        Button("Back") {
                            changePage(to: page - 1)
                        }
                        .buttonStyle(FilledButtonStyle(fill: AppTheme.panel, foreground: AppTheme.paper))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(AppTheme.line, lineWidth: 1)
                        }
                        .accessibilityIdentifier("tutorial-back")
                    }

                    Button(page == pageCount - 1 ? "Start playing" : "Next") {
                        if page == pageCount - 1 {
                            finish()
                        } else {
                            changePage(to: page + 1)
                        }
                    }
                    .buttonStyle(FilledButtonStyle(fill: AppTheme.red, foreground: .white))
                    .accessibilityIdentifier("tutorial-next")
                }
                .frame(maxWidth: 480)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(AppTheme.ink)
            }
        }
        .foregroundStyle(AppTheme.paper)
        .preferredColorScheme(.dark)
        .accessibilityIdentifier("tutorial-screen")
    }

    @ViewBuilder
    private var pageContent: some View {
        switch page {
        case 0:
            TutorialPage(
                title: "Know your role.",
                bodyText: "Most players see the same name. One player sees SPY. Keep your card private."
            ) {
                ViewThatFits {
                    HStack(spacing: 12) {
                        roleCard(label: "Most players", value: "SHERLOCK\nHOLMES", color: AppTheme.players[1].color)
                        roleCard(label: "One player", value: "SPY", color: AppTheme.players[4].color, isSpy: true)
                    }
                    VStack(spacing: 12) {
                        roleCard(label: "Most players", value: "SHERLOCK HOLMES", color: AppTheme.players[1].color)
                        roleCard(label: "One player", value: "SPY", color: AppTheme.players[4].color, isSpy: true)
                    }
                }
            }
        case 1:
            TutorialPage(
                title: "Give one short clue.",
                bodyText: "Show that you know the name without saying it or making the answer too easy for the spy."
            ) {
                VStack(spacing: 10) {
                    clueRow(symbol: "checkmark.circle.fill", label: "Useful", clue: "London", color: AppTheme.players[2].color)
                    clueRow(symbol: "exclamationmark.triangle.fill", label: "Too obvious", clue: "Detective", color: AppTheme.red)
                    clueRow(symbol: "questionmark.circle.fill", label: "Too vague", clue: "Person", color: AppTheme.muted)
                }
            }
        case 2:
            TutorialPage(
                title: "The spy listens.",
                bodyText: "If you see SPY, stay calm. Use everyone’s clues to work out the name and give a clue that fits."
            ) {
                VStack(spacing: 16) {
                    Text("SPY")
                        .displayTitle(size: 88, color: AppTheme.red)
                        .frame(maxWidth: .infinity, minHeight: 190)
                        .background(AppTheme.players[4].color)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    Text("Blend in · Avoid suspicion · Infer the name")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(AppTheme.muted)
                        .multilineTextAlignment(.center)
                }
            }
        default:
            TutorialPage(
                title: "Discuss and vote.",
                bodyText: "After everyone gives a clue, talk through the suspicious answers and vote for the spy. Voting happens in the room, not in the app."
            ) {
                VStack(spacing: 12) {
                    tutorialStep(symbol: "bubble.left.and.bubble.right.fill", text: "Compare the clues")
                    tutorialStep(symbol: "hand.raised.fill", text: "Vote at the same time")
                    tutorialStep(symbol: "eye.fill", text: "Reveal the answer")

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Optional house rule")
                            .font(.headline)
                            .foregroundStyle(AppTheme.paper)
                        Text("If the group catches the spy, give the spy one final guess at the name. A correct guess steals the win.")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.muted)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.panel)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
        }
    }

    private func roleCard(
        label: String,
        value: String,
        color: Color,
        isSpy: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(label.uppercased())
                .font(.caption.weight(.black))
                .tracking(1.2)
            Spacer(minLength: 8)
            Text(value)
                .font(.system(size: 30, weight: .black, design: .rounded).width(.condensed))
                .foregroundStyle(isSpy ? AppTheme.red : AppTheme.paperInk)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.65)
                .lineLimit(2)
                .frame(maxWidth: .infinity)
            Spacer(minLength: 8)
        }
        .foregroundStyle(AppTheme.paperInk)
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 190)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label): \(value.replacingOccurrences(of: "\n", with: " "))")
    }

    private func clueRow(symbol: String, label: String, clue: String, color: Color) -> some View {
        HStack(spacing: 14) {
            Image(systemName: symbol)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 30)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.muted)
                Text(clue)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(AppTheme.paper)
            }
            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 68)
        .background(AppTheme.panel)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    private func tutorialStep(symbol: String, text: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: symbol)
                .font(.title3)
                .foregroundStyle(AppTheme.red)
                .frame(width: 30)
            Text(text)
                .font(.body.weight(.semibold))
                .foregroundStyle(AppTheme.paper)
            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, minHeight: 58)
        .background(AppTheme.panel)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private func changePage(to newPage: Int) {
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.2)) {
            page = newPage
        }
    }

    private func finish() {
        onFinish()
        dismiss()
    }
}

private struct TutorialPage<Content: View>: View {
    let title: String
    let bodyText: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .displayTitle(size: 38)
                    .fixedSize(horizontal: false, vertical: true)
                Text(bodyText)
                    .font(.body)
                    .foregroundStyle(AppTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    TutorialView {}
}
