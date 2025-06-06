import SwiftUI

enum SpeechState: Equatable {
    case idle
    case recording
    case transcribing
    case processing
    case outputting
    case error(String)
}

@MainActor @Observable
class SpeechViewModel {
    private let appSettings: AppSettings

    private let transcriptionService: TranscriptionService
    private let audioRecorderService = AudioRecorderService()
    private let fileService = AudioFileService()
    private let outputService = OutputService()
    private let aiProcessingService = AIProcessingService()

    init(_ settings: AppSettings) {
        appSettings = settings
        transcriptionService = OpenAITranscriptionService(apiKey: settings.openaiApiKey)
    }

    var state: SpeechState = .idle
    var recordingURL: URL?
    var transcription = ""
    var processedText = ""

    var buttonText: String {
        switch state {
        case .idle: "Start"
        case .recording: "Stop"
        default:
            "Processing..."
        }
    }

    var isButtonDisabled: Bool {
        switch state {
        case .idle, .recording, .error: false
        default: true
        }
    }

    // MARK: - Actions

    func bringToFront() {
        if let window = NSApp.windows.first(where: { $0.title == "main" }) {
            window.makeKeyAndOrderFront(nil)
        }
    }

    func bringToBack() {
        if let window = NSApp.windows.first(where: { $0.title == "main" }) {
            window.orderOut(nil)
        }
    }

    func toggleRecording() {
        switch state {
        case .idle, .error:
            Task { await startRecording() }
        case .recording:
            Task { await stopRecording() }
        default:
            break
        }
    }

    func startRecording() async {
        do {
            // TODO: Handle in permissions service maybe
            let isTrusted = AXIsProcessTrusted()
            if !isTrusted {
                NSWorkspace.shared.open(
                    URL(
                        string:
                        "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
                    )!
                )
            }

            let startedRecordingURL = await fileService.createRecordingURL()
            try await audioRecorderService.startRecording(to: startedRecordingURL)

            recordingURL = startedRecordingURL
            state = .recording

        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func stopRecording() async {
        do {
            try await audioRecorderService.stopRecording()

            guard let recordingURL else {
                throw AudioRecorderError.missingRecordingURL
            }

            state = .transcribing
            transcription = try await transcriptionService.transcribe(audioURL: recordingURL)

            state = .processing
            processedText = aiProcessingService.process(transcription)

            state = .outputting

            if appSettings.pasteResultText {
                try outputService.pasteToActiveApp(processedText)
            } else {
                outputService.copyToClipboard(processedText)
            }

            state = .idle
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}

// MARK: - ContentView

struct ContentView: View {
    @Environment(AppSettings.self) var appSettings

    @State private var isCompact = false
    @State private var viewModel = SpeechViewModel(AppSettings())

    var body: some View {
        VStack(spacing: 0) {
            // Audio visualization fills available height
            AudioVisualization(state: viewModel.state)
                .frame(maxHeight: .infinity)
                .gesture(WindowDragGesture())

            // Fixed-height button row
            HStack(spacing: 8) {
                Button(viewModel.buttonText) {
                    viewModel.toggleRecording()
                }
                .disabled(viewModel.isButtonDisabled)

                Spacer()

                Button(action: { isCompact.toggle() }) {
                    Image(systemName: "arrow.up.left.arrow.down.right.square")
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(NSColor.controlBackgroundColor))
        }
        .ignoresSafeArea(.all, edges: .top)
        .task {
            viewModel = SpeechViewModel(appSettings)
        }
        .onChange(of: appSettings.openaiApiKey) {
            viewModel = SpeechViewModel(appSettings)
        }
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

struct AudioVisualization: View {
    let state: SpeechState

    var body: some View {
        Rectangle()
            .fill(fillColor)
            .overlay {
                VStack(spacing: 4) {
                    Text(title)
                        .font(.title2)
                        .foregroundColor(.secondary)

                    if !description.isEmpty {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .animation(.easeInOut(duration: 0.3), value: state)
    }

    private var fillColor: Color {
        switch state {
        case .idle: .gray.opacity(0.2)
        case .recording: .red.opacity(0.3)
        case .transcribing: .blue.opacity(0.3)
        case .processing: .orange.opacity(0.3)
        case .outputting: .green.opacity(0.3)
        case .error: .red.opacity(0.5)
        }
    }

    private var title: String {
        switch state {
        case .idle: "Ready"
        case .recording: "🎤 Recording..."
        case .transcribing: "🧠 Transcribing..."
        case .processing, .outputting: "⚙️ Processing..."
        case .error: "❌ Error"
        }
    }

    private var description: String {
        switch state {
        case let .error(error): error
        default: ""
        }
    }
}

#Preview {
    ContentView()
        .frame(maxWidth: 400, maxHeight: 120)
        .environment(AppSettings())
        .toolbar(removing: .title)
        .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
        .containerBackground(.regularMaterial, for: .window)
        .onAppear {
            if let window = NSApp.windows.first(where: { $0.title == "main" }) {
                // Hide window controls
                window.standardWindowButton(.closeButton)?.isHidden = true
                window.standardWindowButton(.miniaturizeButton)?.isHidden = true
                window.standardWindowButton(.zoomButton)?.isHidden = true
            }
        }
        .presentedWindowStyle(.hiddenTitleBar)
}
