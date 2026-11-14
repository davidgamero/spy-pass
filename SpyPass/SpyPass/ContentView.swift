import SwiftUI

struct ContentView: View {
    @StateObject private var model = GameModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            AppTheme.ink.ignoresSafeArea()

            switch model.state.phase {
            case .setup:
                SetupView(model: model)
            case .deal:
                DealView(model: model)
            case .done:
                DoneView(model: model)
            }
        }
        .foregroundStyle(AppTheme.paper)
        .preferredColorScheme(.dark)
        .onChange(of: scenePhase) { _, phase in
            if phase != .active {
                model.applicationDidEnterBackground()
            }
        }
    }
}

#Preview {
    ContentView()
}
