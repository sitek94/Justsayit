import SwiftUI

struct SettingsAPIKeysView: View {
    @Environment(AppSettings.self) private var appSettings

    var body: some View {
        @Bindable var settings = appSettings
        Form {
            Section {
                SecureField("Open AI", text: $settings.openaiApiKey)
                SecureField("Groq", text: $settings.groqApiKey)
                SecureField("Gemini", text: $settings.geminiApiKey)
                SecureField("Anthropic", text: $settings.anthropicApiKey)
            }
        }
        .formStyle(.grouped)
    }
}

// TODO: Maybe use in the future for now just textfield yolo
func maskedKey(_ key: String) -> String {
    let prefix = key.prefix(4)
    let mask = String(repeating: "*", count: max(0, key.count - 4))
    return "\(prefix)\(mask)"
}

#Preview {
    @State @Previewable var previewSettings = AppSettings()
    SettingsAPIKeysView().environment(previewSettings)
}
