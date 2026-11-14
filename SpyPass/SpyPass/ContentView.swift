import SwiftUI

struct ContentView: View {
    @StateObject private var model = GameModel()
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("hasSeenTutorial") private var hasSeenTutorial = false
    @State private var showTutorial = false

    private var launchArguments: [String] { ProcessInfo.processInfo.arguments }
    private var isScreenshotMode: Bool { launchArguments.contains("--screenshot-state") }
    private var shouldForceTutorial: Bool { launchArguments.contains("--show-tutorial") }
    private var shouldSkipTutorial: Bool { launchArguments.contains("--skip-tutorial") }
    private var tutorialInitialPage: Int {
        guard let index = launchArguments.firstIndex(of: "--tutorial-page"),
              launchArguments.indices.contains(index + 1),
              let page = Int(launchArguments[index + 1]) else { return 0 }
        return min(max(page, 0), 3)
    }

    var body: some View {
        ZStack {
            AppTheme.ink.ignoresSafeArea()

            switch model.state.phase {
            case .setup:
                SetupView(model: model) {
                    showTutorial = true
                }
            case .deal:
                DealView(model: model)
            case .done:
                DoneView(model: model)
            }
        }
        .foregroundStyle(AppTheme.paper)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showTutorial) {
            TutorialView(initialPage: tutorialInitialPage) {
                hasSeenTutorial = true
                showTutorial = false
            }
            .presentationBackground(AppTheme.ink)
        }
        .onAppear {
            guard !isScreenshotMode, !shouldSkipTutorial else { return }
            if shouldForceTutorial || !hasSeenTutorial {
                showTutorial = true
            }
        }
        .onChange(of: showTutorial) { wasVisible, isVisible in
            if wasVisible && !isVisible {
                hasSeenTutorial = true
            }
        }
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
