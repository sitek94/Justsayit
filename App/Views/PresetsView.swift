import SwiftData
import SwiftUI

struct PresetsView: View {
    @Query(sort: \Preset.name) private var presets: [Preset]
    @Environment(\.modelContext) private var modelContext
    @State private var selectedPresetId: Preset.ID?

    var body: some View {
        NavigationSplitView {
            VStack {
                List(selection: $selectedPresetId) {
                    ForEach(presets) { preset in
                        Text(preset.name).tag(preset.id)
                    }
                }
                .listStyle(.sidebar)

                HStack {
                    Button(action: addPreset) {
                        Image(systemName: "plus")
                    }
//                    Button(action: removeSelectedPreset) {
//                        Image(systemName: "minus")
//                    }
//                    .disabled(selectedPresetId == nil)
                    Spacer()
                }
                .padding()
            }
            .navigationSplitViewColumnWidth(200)

        } detail: {
            if let selectedPreset = presets.first(where: { $0.id == selectedPresetId }) {
                PresetsDetailView(preset: selectedPreset)
            } else {
                Text("Select a preset to edit, or add a new one.")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(minWidth: 600, idealWidth: 600, maxWidth: 700, minHeight: 400, idealHeight: 450, maxHeight: 500)
        .fixedSize()
    }

    private func addPreset() {
        let newPreset = Preset(name: "New Preset", prompt: "", model: "", provider: "")
        modelContext.insert(newPreset)
        selectedPresetId = newPreset.id
    }

//    private func removeSelectedPreset() {
//        if let selectedPresetId {
//            presets.removeAll { $0.id == selectedPresetId }
//            self.selectedPresetId = nil
//        }
//    }
}

#Preview {
    PresetsView()
        .modelContainer(for: Preset.self, inMemory: true)
}
