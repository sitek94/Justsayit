import SwiftUI

enum RecordingState: Equatable {
    case idle
    case recording
    case transcribing
    case processing
    case outputting
    case error(RecordingError)
}

@MainActor @Observable
class RecordingViewModel {
    private let transcriptionService = OpenAITranscriptionService()
    private let audioRecorderService = AudioRecorderService()
    private let fileService = AudioFileService()
    private let outputService = OutputService()
    private let aiProcessingService = AIProcessingService()

    var state: RecordingState = .idle
    var recordingURL: URL?
    var transcription = ""
    var processedText = ""
    var isRecording: Bool { state == .recording }

    var pasteResultText: Bool {
        UserDefaults.standard.bool(forKey: SettingsKey.pasteResultText)
    }

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
            let recordingError = RecordingError(from: error)
            Logger.error(recordingError, category: "RecordingViewModel")
            state = .error(recordingError)
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

            if pasteResultText {
                try outputService.pasteToActiveApp(processedText)
            } else {
                outputService.copyToClipboard(processedText)
            }

            state = .idle
        } catch {
            let recordingError = RecordingError(from: error)
            Logger.error(recordingError, category: "RecordingViewModel")
            state = .error(recordingError)
        }
    }
}
