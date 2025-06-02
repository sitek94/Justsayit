import SwiftUI

enum SpeechError: Error, LocalizedError {
    case microphonePermissionRequired
    case noRecordingURL

    var errorDescription: String? {
        switch self {
        case .microphonePermissionRequired:
            "Microphone permission required"
        case .noRecordingURL:
            "No recording URL found"
        }
    }
}

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
    private let transcriptionService: TranscriptionService

    private let audioRecorderService = AudioRecorderService()
    private let fileService = AudioFileService()
    private let outputService = OutputService()
    private let aiProcessingService = AIProcessingService()

    init(apiKey: String) {
        transcriptionService = OpenAITranscriptionService(apiKey: apiKey)
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

    private func startRecording() async {
        do {
            let hasPermission = await audioRecorderService.checkPermission()
            guard hasPermission else {
                throw SpeechError.microphonePermissionRequired
            }

            let startedRecordingURL = await fileService.createRecordingURL()
            try await audioRecorderService.startRecording(to: startedRecordingURL)

            recordingURL = startedRecordingURL
            state = .recording

        } catch {
            state = .error(error.localizedDescription)
        }
    }

    private func stopRecording() async {
        do {
            try await audioRecorderService.stopRecording()
            guard let recordingURL else {
                throw SpeechError.noRecordingURL
            }

            state = .transcribing
            transcription = try await transcriptionService.transcribe(audioURL: recordingURL)

            state = .processing
            processedText = aiProcessingService.process(transcription)

            state = .outputting
            try await outputService.copyToClipboard(transcription)

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
    @State private var viewModel = SpeechViewModel(apiKey: "")

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
            viewModel = SpeechViewModel(apiKey: appSettings.openaiApiKey)
        }
        .onChange(of: appSettings.openaiApiKey) {
            viewModel = SpeechViewModel(apiKey: appSettings.openaiApiKey)
        }
    }
}

struct AudioVisualization: View {
    let state: SpeechState

    var body: some View {
        Rectangle()
            .fill(fillColor)
            .overlay {
                Text(displayText)
                    .font(.title2)
                    .foregroundColor(.secondary)
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

    private var displayText: String {
        switch state {
        case .idle: "Ready"
        case .recording: "🎤 Recording..."
        case .transcribing: "🧠 Transcribing..."
        case .processing, .outputting: "⚙️ Processing..."
        case .error: "❌ Error"
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
