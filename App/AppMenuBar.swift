import SwiftUI

struct AppMenuBar: View {
    @Environment(\.openSettings) private var openSettings
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Button("Record") {
            openWindow(id: AppWindow.recordingMini.id)
        }
        Button("Presets") {
            openWindow(id: AppWindow.presets.id)
        }
        Button("History") {
            openWindow(id: AppWindow.history.id)
        }
        SettingsLink {
            Text("Settings")
        }
        .keyboardShortcut(",")

        Button("Quit") {
            NSApp.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}

#Preview {
    AppMenuBar()
}
