import Foundation

enum SpeechError: Error, Equatable {
    case permissionDenied
    case recordingFailed(String)
    case transcriptionFailed(String)
    case outputFailed(String)
    case unknown(String)

    init(from error: Error) {
        switch error {
        case let permissionError as PermissionValidationError:
            switch permissionError {
            case .microphonePermissionDenied, .microphonePermissionRestricted:
                self = .permissionDenied
            case .configurationError(let message):
                self = .recordingFailed("Configuration Error: \(message)")
            }
        case let recorderError as AudioRecorderError:
            self = .recordingFailed(recorderError.localizedDescription)
        case let transcriptionError as TranscriptionError:
            self = .transcriptionFailed(transcriptionError.localizedDescription)
        case let outputError as OutputError:
            self = .outputFailed(outputError.localizedDescription)
        default:
            self = .unknown(error.localizedDescription)
        }
    }

    var localizedDescription: String {
        switch self {
        case .permissionDenied:
            return "Microphone permission was denied. Please grant it in System Settings."
        case .recordingFailed(let reason):
            return "Recording failed: \(reason)"
        case .transcriptionFailed(let reason):
            return "Transcription failed: \(reason)"
        case .outputFailed(let reason):
            return "Output failed: \(reason)"
        case .unknown(let reason):
            return "An unknown error occurred: \(reason)"
        }
    }
} 