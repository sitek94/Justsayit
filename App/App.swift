import KeyboardShortcuts
import Sparkle
import SwiftData
import SwiftUI

@main
struct JustsayitApp: App {
    @State private var updaterService = UpdaterService()

    var body: some Scene {
        MenuBarExtra(AppWindow.menuBar.title, systemImage: "mic") {
            AppMenuBar()
        }
        .menuBarExtraStyle(.menu)

        Window(AppWindow.recordingMini.title, id: AppWindow.recordingMini.id) {
            RecordingMiniView()
                .modelContainer(for: Preset.self)
                .toolbar(removing: .title)
                .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
                .containerBackground(.regularMaterial, for: .window)
                .onAppear {
                    if let window = NSApp.windows.first(where: { $0.title == AppWindow.recordingMini.title }) {
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
        .windowLevel(.floating)

        Window(AppWindow.presets.title, id: AppWindow.presets.id) {
            PresetsView()
                .modelContainer(for: Preset.self)
                .toolbar(removing: .title)
                .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
                .containerBackground(.regularMaterial, for: .window)
        }
        .windowResizability(.contentSize)

        Settings {
            SettingsView()
                .environment(updaterService)
                .toolbar(removing: .title)
                .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
                .containerBackground(.regularMaterial, for: .window)
        }
    }
}
