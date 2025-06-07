import Foundation

enum RecordingError: Error, Equatable {
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
            case let .configurationError(message):
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
            "Microphone permission was denied. Please grant it in System Settings."
        case let .recordingFailed(reason):
            "Recording failed: \(reason)"
        case let .transcriptionFailed(reason):
            "Transcription failed: \(reason)"
        case let .outputFailed(reason):
            "Output failed: \(reason)"
        case let .unknown(reason):
            "An unknown error occurred: \(reason)"
        }
    }
}
