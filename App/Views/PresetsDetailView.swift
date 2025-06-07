import SwiftData
import SwiftUI

struct PresetsDetailView: View {
    @Bindable var preset: Preset

    var body: some View {
        Form {
            TextField("Name:", text: $preset.name)
            TextField("Model:", text: $preset.model)
            TextField("Provider:", text: $preset.provider)

            Section {
                TextEditor(text: $preset.prompt)
                    .font(.body)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                    )
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: preset) {
            preset.lastModified = .now
        }
    }
}

#Preview {
    @State @Previewable var preset = Preset(name: "Test", prompt: "Test prompt", model: "gpt-4o", provider: "OpenAI")
    PresetsDetailView(preset: preset)
}
