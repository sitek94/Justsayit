import SwiftData
import SwiftUI

struct RecordingMiniView: View {
    @Query(sort: \Preset.name) private var presets: [Preset]

    @State private var viewModel = RecordingViewModel(presets: [])

    var body: some View {
        VStack(spacing: 0) {
            // Audio visualization fills available height
            RecordingVisualizer(state: viewModel.state)
                .frame(maxHeight: .infinity)
                .gesture(WindowDragGesture())

            // Fixed-height button row
            HStack(spacing: 8) {
                Button(viewModel.buttonText) {
                    viewModel.toggleRecording()
                }
                .disabled(viewModel.isButtonDisabled)

                Spacer()

                if !viewModel.presets.isEmpty {
                    Picker("Preset", selection: $viewModel.selectedPresetId) {
                        ForEach(viewModel.presets) { preset in
                            Text(preset.name).tag(preset.id.uuidString as String?)
                        }
                    }
                    .frame(width: 120)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(NSColor.controlBackgroundColor))
        }
        .ignoresSafeArea(.all, edges: .top)
        .onGlobalKeyboardShortcut(.toggleRecording, type: .keyDown) {
            Task {
                let isRecording = viewModel.state == .recording
                if isRecording {
                    await viewModel.stopRecording()
                    viewModel.bringToBack()
                } else {
                    viewModel.bringToFront()
                    await viewModel.startRecording()
                }
            }
        }
        .onAppear {
            viewModel.presets = presets
        }
        .onChange(of: presets) {
            viewModel.presets = presets
        }
    }
}

#Preview {
    RecordingMiniView()
        .modelContainer(for: Preset.self, inMemory: true)
        .frame(maxWidth: 400, maxHeight: 120)
        .toolbar(removing: .title)
        .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
        .containerBackground(.regularMaterial, for: .window)
        .onAppear {
            if let window = NSApp.windows.first(where: { $0.title == "recording-mini" }) {
                // Hide window controls
                window.standardWindowButton(.closeButton)?.isHidden = true
                window.standardWindowButton(.miniaturizeButton)?.isHidden = true
                window.standardWindowButton(.zoomButton)?.isHidden = true
            }
        }
        .presentedWindowStyle(.hiddenTitleBar)
}
