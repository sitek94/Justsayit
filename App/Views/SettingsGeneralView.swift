import SwiftUI

struct SettingsGeneralView: View {
    @Environment(UpdaterService.self) private var updaterService

    @AppStorage(SettingsKey.pasteResultText) private var pasteResultText = true
    @AppStorage(SettingsKey.pushToTalkEnabled) private var pushToTalkEnabled = false
    @AppStorage(SettingsKey.launchOnLogin) private var launchOnLogin = false
    @AppStorage(SettingsKey.errorLoggingEnabled) private var errorLoggingEnabled = false

    var body: some View {
        Form {
            Section {
                HStack {
                    Toggle(isOn: $pasteResultText) {
                        Text("Paste result text")
                    }
                    .controlSize(.large)
                    Spacer()
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(.white)
                }

                HStack {
                    Toggle(isOn: $pushToTalkEnabled) {
                        Text("Push to Talk")
                    }
                    .controlSize(.large)
                    Spacer()
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(.white)
                }
            }

            Section("Application") {
                HStack {
                    Text("Update application")
                    Spacer()
                    Button("Check for Updates...") {
                        updaterService.checkForUpdates()
                    }
                    .disabled(!updaterService.canCheckForUpdates)
                }
                HStack {
                    Toggle(isOn: $launchOnLogin) {
                        Text("Launch on login")
                    }
                    .controlSize(.large)
                    Spacer()
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(.gray)
                }
                HStack {
                    Toggle(isOn: $errorLoggingEnabled) {
                        Text("Error logging")
                    }
                    .controlSize(.large)
                    Spacer()
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(.gray)
                }
            }
        }
        .formStyle(.grouped)
    }
}

#Preview {
    @State @Previewable var updaterService = UpdaterService()

    SettingsGeneralView().environment(updaterService)
}
