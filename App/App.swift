import Sparkle
import SwiftUI

@main
struct JustsayitApp: App {
    @State private var appSettings = AppSettings()
    private let updaterController: SPUStandardUpdaterController

    init() {
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
    }

    var body: some Scene {
        Window("main", id: "main") {
            ContentView()
                .environment(appSettings)
                .toolbar(removing: .title)
                .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
                .containerBackground(.regularMaterial, for: .window)
                .onAppear {
                    if let window = NSApp.windows.first(where: { $0.title == "main" }) {
                        // Hide window controls
                        window.standardWindowButton(.closeButton)?.isHidden = true
                        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
                        window.standardWindowButton(.zoomButton)?.isHidden = true
                    }
                }
                .presentedWindowStyle(.hiddenTitleBar)
        }
        .windowBackgroundDragBehavior(.enabled)
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)

        Settings {
            SettingsView()
                .environment(appSettings)
        }
    }
}
