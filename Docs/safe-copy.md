```swift
import SwiftUI

enum SpeechError: Error, LocalizedError {
    case microphonePermissionRequired
    case noRecordingURL

    var errorDescription: String? {
        switch self {
        case .microphonePermissionRequired:
            return "Microphone permission required"
        case .noRecordingURL:
            return "No recording URL found"
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
    //    let apiKey: String
    private let transcriptionService: TranscriptionService

    private let audioRecorderService = AudioRecorderService()
    private let fileService = AudioFileService()
    private let outputService = OutputService()
    private let aiProcessingService = AIProcessingService()

    init(apiKey: String) {
        self.transcriptionService = OpenAITranscriptionService(apiKey: apiKey)
    }

    var state: SpeechState = .idle
    var recordingURL: URL?
    var transcription = ""
    var processedText = ""

    var buttonText: String {
        switch state {
        case .idle: return "Start"
        case .recording: return "Stop"
        default:
            return "Processing..."
        }
    }

    var isButtonDisabled: Bool {
        switch state {
        case .idle, .recording, .error: return false
        default: return true
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
            guard let recordingURL = recordingURL else {
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
        VStack {
            AdaptiveHeightSheet()
//            AudioVisualization(state: viewModel.state)
//                //                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .cornerRadius(8)
//                .gesture(WindowDragGesture())
//                .frame(maxHeight: .infinity)
//                .edgesIgnoringSafeArea(.top)

            HStack(spacing: 8) {

                Button(viewModel.buttonText) {
                    viewModel.toggleRecording()
                }
                .disabled(viewModel.isButtonDisabled)

                Spacer()

                Button(action: { isCompact.toggle() }) {
                    Image(systemName: "arrow.up.left.arrow.down.right.square")
                }

                // TODO: error in alert? or overlay on vis
                //                if case let .error(errorMessage) = viewModel.state {
                //                    Text(errorMessage)
                //                        .font(.caption)
                //                        .foregroundColor(.red)
                //                }
            }
        }

        .task {
            viewModel = SpeechViewModel(apiKey: appSettings.openaiApiKey)
        }
        .onChange(of: appSettings.openaiApiKey) {
            viewModel = SpeechViewModel(apiKey: appSettings.openaiApiKey)
        }
        .padding(8)

        .ignoresSafeArea(.all, edges: .top)
        //        .fixedSize()
    }
}

struct AudioVisualization: View {
    @State private var height: CGFloat = 0

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
        case .idle: return .gray.opacity(0.2)
        case .recording: return .red.opacity(0.3)
        case .transcribing: return .blue.opacity(0.3)
        case .processing: return .orange.opacity(0.3)
        case .outputting: return .green.opacity(0.3)
        case .error: return .red.opacity(0.5)
        }
    }

    private var displayText: String {
        switch state {
        case .idle: return "Ready"
        case .recording: return "🎤 Recording..."
        case .transcribing: return "🧠 Transcribing..."
        case .processing: return "⚙️ Processing..."
        case .outputting: return "📋 Copying..."
        case .error: return "❌ Error"
        }
    }
}


struct AdaptiveHeightSheet: View {
    @State private var contentHeight: CGFloat = 300 // initial fallback

    var body: some View {
        VStack(spacing: 0) {
            // This container fills the available height
            Color.blue
                .frame(maxHeight: .infinity)
                .overlay(Text("Audio Visualization").foregroundColor(.white))
            // Fixed-height button row
            HStack {
                Button("A") { }
                Button("B") { }
            }
            .frame(height: 56)
            .background(Color.gray.opacity(0.2))
        }
        .background(
            GeometryReader { proxy in
                Color.clear
                    .task {
                        contentHeight = proxy.size.height
                    }
            }
        )
        .presentationDetents([.height(contentHeight)])
        .id(contentHeight) // Helps avoid jitter on updates[2]
    }
}


#Preview {
    ContentView()
        //        .frame(maxWidth: 400, maxHeight: 120)
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

                //                        // Set initial window size
                //                window.setContentSize(NSSize(width: 200, height: 100))
            }
        }
        .presentedWindowStyle(.hiddenTitleBar)
    //        .ignoresSafeArea(.all)
}

```