import SwiftUI
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let toggleRecording = Self("toggleRecording")
    static let cancelRecording = Self("cancelRecording")
    static let changeMode = Self("changeMode")
}

struct SettingsKeyboardShortcutsView: View {
    var body: some View {
        Form {
            Section {
                KeyboardShortcuts.Recorder("Toggle Recording", name: .toggleRecording)
                KeyboardShortcuts.Recorder("Cancel Recording", name: .cancelRecording)
                KeyboardShortcuts.Recorder("Change Mode", name: .changeMode)
            }
        }
        .formStyle(.grouped)
    }
}

#Preview {
    SettingsKeyboardShortcutsView()
}
