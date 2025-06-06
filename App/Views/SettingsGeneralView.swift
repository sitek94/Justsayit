import SwiftUI

struct SettingsGeneralView: View {
    @Environment(AppSettings.self) private var appSettings

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
                        // Action for checking updates
                    }
                }
                HStack {
                    Toggle(isOn: $settings.automaticallyCheckForUpdates) {
                        Text("Automatically check for updates")
                    }
                    .controlSize(.large)
                    Spacer()
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(.gray)
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
    SettingsGeneralView().environment(previewSettings)
}
