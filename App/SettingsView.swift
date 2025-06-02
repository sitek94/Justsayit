import Observation
import SwiftUI

struct SettingsView: View {
    @Environment(AppSettings.self) private var appSettings

    var body: some View {
        @Bindable var settings = appSettings

        Form {
            Section("API Keys") {
                SecureField("OpenAI", text: $settings.openaiApiKey)
                    .textFieldStyle(.roundedBorder)
                SecureField("TODO: Groq", text: $settings.groqApiKey)
                    .textFieldStyle(.roundedBorder)
                SecureField("TODO: Gemini", text: $settings.geminiApiKey)
                    .textFieldStyle(.roundedBorder)
            }
        }
        .padding()
    }
}

#Preview {
    @State @Previewable var previewSettings = AppSettings()

    SettingsView()
        .environment(previewSettings)
        .frame(maxWidth: 400, maxHeight: 200)
}
