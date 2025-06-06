import SwiftUI

struct SettingsKeyboardShortcutsView: View {
    var body: some View {
        Form {
            Section {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Toggle Recording")
                        Text("Starts and stops recordings")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    KeyboardShortcutDisplay("arrow.counterclockwise", systemImage: true)
                    KeyboardShortcutDisplay("B")
                }
                HStack {
                    VStack(alignment: .leading) {
                        Text("Cancel Recording")
                        Text("Discards the active recording")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    KeyboardShortcutDisplay("arrow.counterclockwise", systemImage: true)
                    KeyboardShortcutDisplay("Esc")
                }
                HStack {
                    VStack(alignment: .leading) {
                        Text("Change mode")
                        Text("Activates the mode switcher")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    KeyboardShortcutDisplay("arrow.counterclockwise", systemImage: true)
                    KeyboardShortcutDisplay("Z")
                }
            }
        }
        .formStyle(.grouped)
    }
}

#Preview {
    SettingsKeyboardShortcutsView()
}
