```swift
import SwiftUI

// MARK: - State Machine Error
enum SpeechStateError: Error, LocalizedError {
    case invalidTransition(from: SpeechState, to: String)

    var errorDescription: String? {
        switch self {
        case .invalidTransition(let from, let to):
            return "Invalid state transition from \(from) to \(to)"
        }
    }
}

// MARK: - Speech State with Transition Methods
enum SpeechState: Equatable, CustomStringConvertible {
    case idle
    case recording(recordingURL: URL)
    case transcribing(recordingURL: URL)
    case processing(recordingURL: URL, transcription: String)
    case outputting(recordingURL: URL, transcription: String)
    case error(String)

    // MARK: - State Transition Methods
    func startedRecording(url: URL) -> SpeechState {
        return .recording(recordingURL: url)
    }

    func stoppedRecording() -> SpeechState {
        guard case .recording(let url) = self else {
            fatalError("Invalid state transition from \(self) to transcribing")
        }
        return .transcribing(recordingURL: url)
    }

    func finishedTranscribing(transcription: String) -> SpeechState {
        guard case .transcribing(let url) = self else {
            fatalError("Invalid state transition from \(self) to processing")
        }
        return .processing(recordingURL: url, transcription: transcription)
    }

    // Can
    func finishedProcessing() -> SpeechState {
        guard case .processing(let url, let transcription) = self else {
            fatalError("Invalid state transition from \(self) to outputting")
        }
        return .outputting(recordingURL: url, transcription: transcription)
    }

    func finishedOutputting() -> SpeechState {
        guard case .outputting = self else {
            fatalError("Invalid state transition from \(self) to idle")
        }
        return .idle
    }

    func failed(with message: String) -> SpeechState {
        return .error(message)
    }

    // MARK: - CustomStringConvertible
    var description: String {
        switch self {
        case .idle: return "idle"
        case .recording: return "recording"
        case .transcribing: return "transcribing"
        case .processing: return "processing"
        case .outputting: return "outputting"
        case .error(let message): return "error(\(message))"
        }
    }

    // MARK: - Computed Properties for UI
    var buttonText: String {
        switch self {
        case .idle: return "Start"
        case .recording: return "Stop"
        case .transcribing, .processing, .outputting: return "Processing..."
        case .error: return "Retry"
        }
    }

    var isButtonDisabled: Bool {
        switch self {
        case .transcribing, .processing, .outputting: return true
        default: return false
        }
    }

    var errorMessage: String? {
        switch self {
        case .error(let message): return message
        default: return nil
        }
    }

    // MARK: - Helper Properties
    var recordingURL: URL {
        switch self {
        case .recording(let url),
            .transcribing(let url),
            .processing(let url, _),
            .outputting(let url, _):
            return url
        default:
            fatalError("You should access it only if you're sure it's there")
        }
    }

    var canStartRecording: Bool {
        switch self {
        case .idle, .error: return true
        default: return false
        }
    }

    var canStopRecording: Bool {
        switch self {
        case .recording: return true
        default: return false
        }
    }
}
// MARK: - Clean View Model
@MainActor @Observable
class SpeechViewModel {

    // Direct service dependencies
    private let audioRecorderService = AudioRecorderService()
    private let fileService = AudioFileService()
    private let transcriptionService = TranscriptionService()
    private let outputService = OutputService()
    private let aiProcessingService = AIProcessingService()

    // Single source of truth
    var state: SpeechState = .idle

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

    // MARK: - Clean Implementation with Throwing State Methods
    private func startRecording() async {
        do {
            let hasPermission = await audioRecorderService.checkPermission()
            guard hasPermission else {
                state = state.failed(with: "Microphone permission required")
                return
            }

            let recordingURL = await fileService.createRecordingURL()
            try await audioRecorderService.startRecording(to: recordingURL)

            // Clean transition using enum method
            state = state.startedRecording(url: recordingURL)

        } catch {
            state = state.failed(with: "Failed to start recording: \(error.localizedDescription)")
        }
    }

    private func stopRecording() async {
        do {
            try await audioRecorderService.stopRecording()
            state = state.stoppedRecording()

            print(state.recordingURL)
            
            let transcription = try await transcriptionService.transcribe(audioURL: state.recordingURL)
            state = state.finishedTranscribing(transcription: transcription)
            
            let processedText = aiProcessingService.process(transcription)
            print(processedText)
            state = state.finishedProcessing()
            
            try await outputService.copyToClipboard(transcription)
            state = state.finishedOutputting()
            
        } catch {
            state = state.failed(with: "Failed: \(error.localizedDescription)")
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
                Button(viewModel.state.buttonText) {
                    viewModel.toggleRecording()
                }
                .disabled(viewModel.state.isButtonDisabled)

                if let error = viewModel.state.errorMessage {
                    Text(error)
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

```