import KeyboardShortcuts
import Sparkle
import SwiftUI

@main
struct JustsayitApp: App {
    private let recordingManager = RecordingManager()

    var body: some Scene {
        WindowGroup {
            RecordingView()
                .environment(recordingManager)
                .frame(minWidth: 400, minHeight: 400)
        }

        MenuBarExtra("Justsayit", systemImage: "mic") {
            MenuBarView()
                .environment(recordingManager)
        }

        Window("Debug", id: "debug") {
            DebugView()
                .frame(minWidth: 400, minHeight: 400)
        }
    }
}
