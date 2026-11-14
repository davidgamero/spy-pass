import SwiftUI

struct SetupView: View {
    @ObservedObject var model: GameModel
    @State private var input = ""
    @FocusState private var inputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 26) {
                        intro
                        namesList
                    }
                    .frame(maxWidth: 480)
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 28)
                    .frame(maxWidth: .infinity)
                }
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: model.playerCount) { _, count in
                    guard count > 0 else { return }
                    withAnimation { proxy.scrollTo("names-bottom", anchor: .bottom) }
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                entryField
                dealButton
            }
                .frame(maxWidth: 480)
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 10)
                .background(AppTheme.ink)
        }
    }

    private var intro: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Spy Pass.")
                .displayTitle(size: 48)
                .lineSpacing(-5)
            Text("Each player types one name, then passes the phone on. Everyone but the spy sees the picked name.")
                .font(.body)
                .foregroundStyle(AppTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var entryField: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text("Add the name of someone the whole group knows")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.muted)
            HStack(spacing: 10) {
                TextField("Type a name", text: $input)
                    .font(.body.weight(.medium))
                    .foregroundStyle(AppTheme.paper)
                    .focused($inputFocused)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.done)
                    .onSubmit(addInput)
                    .onChange(of: input) { _, newValue in
                        if !newValue.contains(",") && !newValue.contains("\n") && newValue.count > GameModel.maxNameLength {
                            input = String(newValue.prefix(GameModel.maxNameLength))
                        }
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 58)
                    .background(AppTheme.panel)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(AppTheme.line, lineWidth: 1)
                    }

                Button("Add", action: addInput)
                    .buttonStyle(FilledButtonStyle(fill: AppTheme.paper, foreground: AppTheme.paperInk, height: 58))
                    .frame(width: 82)
                    .disabled(!hasValidInput)
            }
        }
    }

    private var namesList: some View {
        VStack(spacing: 0) {
            HStack {
                Text("\(model.playerCount) \(model.playerCount == 1 ? "player" : "players")")
                    .font(.headline)
                    .foregroundStyle(AppTheme.paper)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 2)

            if model.state.names.isEmpty {
                Text("No names yet. Pass the phone to the first player.")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.muted)
                    .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
                    .padding(.horizontal, 16)
                    .background(AppTheme.panel)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            } else {
                LazyVStack(spacing: 1) {
                    ForEach(Array(model.state.names.indices), id: \.self) { index in
                        nameRow(index: index)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            Color.clear.frame(height: 1).id("names-bottom")
        }
    }

    private func nameRow(index: Int) -> some View {
        HStack(spacing: 14) {
            Text(String(format: "%02d", index + 1))
                .font(.caption.weight(.bold).monospaced())
                .foregroundStyle(AppTheme.muted)
            Text(model.state.names[index])
                .font(.body.weight(.semibold))
                .foregroundStyle(AppTheme.paper)
                .lineLimit(1)
            Spacer()
            Button {
                withAnimation { model.removeName(at: index) }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .foregroundStyle(AppTheme.muted)
            .accessibilityLabel("Remove player \(index + 1)")
        }
        .padding(.leading, 16)
        .padding(.trailing, 4)
        .frame(minHeight: 58)
        .background(AppTheme.panel)
    }

    private var dealButton: some View {
        Button(action: model.deal) {
            Text(model.canDeal ? "Deal to \(model.playerCount) players" : "Need 3 players to start")
        }
        .buttonStyle(FilledButtonStyle(fill: AppTheme.red, foreground: .white))
        .disabled(!model.canDeal)
    }

    private var hasValidInput: Bool {
        input
            .components(separatedBy: CharacterSet(charactersIn: ",\n\r"))
            .contains { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    private func addInput() {
        let oldCount = model.playerCount
        model.addNames(input)
        guard model.playerCount > oldCount else { return }
        input = ""
        inputFocused = true
    }
}
