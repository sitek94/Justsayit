import SwiftUI

struct RecordingMiniView: View {
    @State private var viewModel = RecordingViewModel()

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
    }
}

#Preview {
    RecordingMiniView()
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
