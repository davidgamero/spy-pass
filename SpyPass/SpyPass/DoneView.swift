import SwiftUI

struct DoneView: View {
    @ObservedObject var model: GameModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Start talking.")
                        .displayTitle(size: 48)
                    Text("Take turns giving clues about the name without saying it. Find the spy before the spy works out the name.")
                        .font(.body)
                        .foregroundStyle(AppTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }

                namesInPlay

                if model.state.showAnswer {
                    answerPanel
                        .transition(.opacity.combined(with: .move(edge: .top)))
                } else {
                    Button("Reveal the answer") {
                        withAnimation { model.revealAnswer() }
                    }
                    .buttonStyle(FilledButtonStyle(fill: AppTheme.paper, foreground: AppTheme.paperInk))
                }

                VStack(spacing: 12) {
                    Button("Deal again with the same names", action: model.deal)
                        .buttonStyle(FilledButtonStyle(fill: AppTheme.red, foreground: .white))
                    Button("Change names", action: model.changeNames)
                        .buttonStyle(FilledButtonStyle(fill: AppTheme.panel, foreground: AppTheme.paper))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(AppTheme.line, lineWidth: 1)
                        }
                }
            }
            .frame(maxWidth: 480)
            .padding(.horizontal, 20)
            .padding(.vertical, 30)
            .frame(maxWidth: .infinity)
        }
    }

    private var namesInPlay: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Names in play")
                .font(.headline)
                .foregroundStyle(AppTheme.paper)

            VStack(spacing: 1) {
                ForEach(Array(model.state.names.indices), id: \.self) { index in
                    HStack(spacing: 14) {
                        Text(String(format: "%02d", index + 1))
                            .font(.caption.weight(.bold).monospaced())
                            .foregroundStyle(AppTheme.muted)
                        Text(model.state.names[index])
                            .font(.body.weight(.semibold))
                            .foregroundStyle(AppTheme.paper)
                            .multilineTextAlignment(.leading)
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
                    .background(AppTheme.panel)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Name \(index + 1), \(model.state.names[index])")
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }

    private var answerPanel: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 5) {
                Text("The spy was")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(AppTheme.muted)
                Text("Player \(model.state.spyIndex + 1)")
                    .displayTitle(size: 35)
            }
            Divider().overlay(AppTheme.line)
            VStack(alignment: .leading, spacing: 5) {
                Text("The name was")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(AppTheme.muted)
                Text(model.state.secret)
                    .displayTitle(size: 35)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.panel)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(AppTheme.line, lineWidth: 1)
        }
    }
}
