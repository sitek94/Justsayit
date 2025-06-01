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

    private let audioRecorderService = AudioRecorderService()
    private let fileService = AudioFileService()
    private let transcriptionService: TranscriptionService = OpenAITranscriptionService(
        apiKey: ProcessInfo.processInfo.environment["OPENAI_API_KEY"]!)
    private let outputService = OutputService()
    private let aiProcessingService = AIProcessingService()

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

// MARK: - ContentView (unchanged)
struct ContentView: View {
    @State private var viewModel = SpeechViewModel()

    var body: some View {
        VStack(spacing: 16) {
            AudioVisualization(state: viewModel.state)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack(spacing: 8) {
                Button(viewModel.buttonText) {
                    viewModel.toggleRecording()
                }
                .disabled(viewModel.isButtonDisabled)

                if case let .error(errorMessage) = viewModel.state {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(8)
    }
}

struct AudioVisualization: View {
    let state: SpeechState

    var body: some View {
        Rectangle()
            .fill(fillColor)
            .overlay {
                VStack {
                    Text(displayText)
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
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
#Preview {
    ContentView()
        .frame(maxHeight: 200)
}
