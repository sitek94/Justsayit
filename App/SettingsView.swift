import Observation
import SwiftUI

@Observable
class AppSettings {
    var appName: String = "Justsayit"
    var openaiApiKey: String = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
    var groqApiKey: String = ProcessInfo.processInfo.environment["GROQ_API_KEY"] ?? ""
    var geminiApiKey: String = ProcessInfo.processInfo.environment["GEMINI_API_KEY"] ?? ""
    var anthropicApiKey: String = ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"] ?? ""

    var pasteResultText: Bool = true

    // TODO: For now these are just mocks
    var pushToTalkEnabled: Bool = false
    var automaticallyCheckForUpdates: Bool = true
    var launchOnLogin: Bool = true
    var errorLoggingEnabled: Bool = false
}

struct KeyboardShortcutDisplay: View {
    let keyName: String
    let isSystemImage: Bool

    init(_ name: String, systemImage: Bool = false) {
        keyName = name
        isSystemImage = systemImage
    }

    var body: some View {
        if isSystemImage {
            Image(systemName: keyName)
                .frame(minWidth: 20)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(4)
        } else {
            Text(keyName)
                .frame(minWidth: 20)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(4)
                .font(.system(size: 12, weight: .medium))
        }
    }
}

struct SettingsView: View {
    @Environment(AppSettings.self) private var appSettings

    var body: some View {
        @Bindable var settings = appSettings

        Form {
            Section("General") {
                HStack {
                    Toggle(isOn: $settings.pasteResultText) {
                        Text("Paste result text")
                    }
                    .controlSize(.large)
                    Spacer()
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(.white)
                }
            }

            Section("Keyboard Shortcuts") {
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

            Section {
                Toggle(isOn: $settings.pushToTalkEnabled) {
                    VStack(alignment: .leading) {
                        Text("Push to Talk")
                        Text("Hold to record, release when done")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
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
                    Spacer()
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(.gray)
                }
                HStack {
                    Toggle(isOn: $settings.launchOnLogin) {
                        Text("Launch on login")
                    }
                    Spacer()
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(.gray)
                }
                HStack {
                    Toggle(isOn: $settings.errorLoggingEnabled) {
                        Text("Error logging")
                    }
                    Spacer()
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(.gray)
                }
            }

            Section("API Keys") {
                SecureField("OpenAI API Key", text: $settings.openaiApiKey)
                SecureField("Groq API Key", text: $settings.groqApiKey)
                SecureField("Gemini API Key", text: $settings.geminiApiKey)
                SecureField(
                    "Anthropic API Key", text: $settings.anthropicApiKey
                )
            }
        }
        .formStyle(.grouped)
        .padding()
        .frame(
            minWidth: 500, idealWidth: 600, maxWidth: 700,
            minHeight: 500, idealHeight: 740, maxHeight: 800
        )
        .fixedSize()
    }
}

#Preview {
    @State @Previewable var previewSettings = AppSettings()

    SettingsView()
        .environment(previewSettings)
}
