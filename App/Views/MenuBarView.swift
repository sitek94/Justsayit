import SwiftUI

struct MenuBarView: View {
    @Environment(\.openSettings) private var openSettings
    @Environment(\.openWindow) private var openWindow
    @Environment(RecordingManager.self) var recordingManager

    var body: some View {
        Button(recordingManager.isRecording ? "Stop Recording" : "Start Recording") {
            Task { await recordingManager.toggleRecording() }
        }

        SettingsLink {
            Text("Settings")
        }
        .keyboardShortcut(",")

        Divider()

        Button("Debug") {
            openWindow(id: "debug")
        }

        Divider()

        Button("Quit") {
            NSApp.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}

#Preview {
    let recordingManager = RecordingManager()

    MenuBarView()
        .environment(recordingManager)
}
