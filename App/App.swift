import KeyboardShortcuts
import Sparkle
import SwiftUI

@main
struct JustsayitApp: App {
    @Environment(\.openSettings) private var openSettings
    @Environment(\.openWindow) private var openWindow

    @State private var appSettings = AppSettings()
    @State private var settingsService = SettingsService()
    @State private var updaterService = UpdaterService()

    var body: some Scene {
        MenuBarExtra("Justsayit", systemImage: "mic") {
            Button("Show Main Window") {
                openWindow(id: "main")
            }
            .keyboardShortcut("m")

            Divider()

            Button("Settings") {
                openSettings()
            }
            .keyboardShortcut(",")

            Button("Quit") {
                NSApp.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        .menuBarExtraStyle(.menu)

        Window("main", id: "main") {
            ContentView()
                .environment(appSettings)
                .environment(settingsService)
                .environment(updaterService)
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
        .windowLevel(.floating)

        Settings {
            SettingsView()
                .environment(appSettings)
                .environment(settingsService)
                .environment(updaterService)
                .toolbar(removing: .title)
                .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
                .containerBackground(.regularMaterial, for: .window)
        }
    }
}
