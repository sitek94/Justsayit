import SwiftUI

struct AppMenuBar: View {
    @Environment(\.openSettings) private var openSettings
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Button("Show Mini Recorder") {
            openWindow(id: AppWindow.recordingMini.id)
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
}

#Preview {
    AppMenuBar()
}
