import SwiftUI

struct SettingsGeneralView: View {
    @Environment(AppSettings.self) private var appSettings
    @Environment(UpdaterService.self) private var updaterService

    var body: some View {
        @Bindable var settings = appSettings
        Form {
            Section {
                HStack {
                    Toggle(isOn: $settings.pasteResultText) {
                        Text("Paste result text")
                    }
                    .controlSize(.large)
                    Spacer()
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(.white)
                }

                HStack {
                    Toggle(isOn: $settings.pushToTalkEnabled) {
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
                    Toggle(isOn: $settings.launchOnLogin) {
                        Text("Launch on login")
                    }
                    .controlSize(.large)
                    Spacer()
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(.gray)
                }
                HStack {
                    Toggle(isOn: $settings.errorLoggingEnabled) {
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
    @State @Previewable var previewSettings = AppSettings()
    @State @Previewable var updaterService = UpdaterService()
    SettingsGeneralView().environment(previewSettings)
        .environment(updaterService)
}
