import AVFoundation
import Foundation

// MARK: - Permission Validation Errors

enum PermissionValidationError: LocalizedError {
    case microphonePermissionDenied
    case microphonePermissionRestricted
    case configurationError(String)

    var errorDescription: String? {
        switch self {
        case .microphonePermissionDenied:
            "Microphone access was denied. Please enable microphone access in System Preferences > Security & Privacy > Microphone."
        case .microphonePermissionRestricted:
            "Microphone access is restricted on this device."
        case let .configurationError(message):
            "Configuration error: \(message)"
        }
    }
}

// MARK: - Permission Service

actor PermissionService {
    // MARK: - Validation Methods

    func getCurrentMicrophonePermissionStatus() -> AVAuthorizationStatus {
        AVCaptureDevice.authorizationStatus(for: .audio)
    }

    func requestMicrophonePermission() async throws {
        let currentStatus = getCurrentMicrophonePermissionStatus()

        switch currentStatus {
        case .authorized:
            return // Already authorized

        case .notDetermined:
            // Request permission
            let granted = await withCheckedContinuation { continuation in
                AVCaptureDevice.requestAccess(for: .audio) { granted in
                    continuation.resume(returning: granted)
                }
            }

            if !granted {
                throw PermissionValidationError.microphonePermissionDenied
            }

        case .denied:
            throw PermissionValidationError.microphonePermissionDenied

        case .restricted:
            throw PermissionValidationError.microphonePermissionRestricted

        @unknown default:
            throw PermissionValidationError.configurationError("Unknown permission status")
        }
    }
}
