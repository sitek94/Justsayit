import AVFoundation
import Foundation

// MARK: - Audio Recorder Error Types

enum AudioRecorderError: Error, LocalizedError {
    case setupFailed(String)
    case recordingFailed(String)
    case missingRecordingURL
    case alreadyRecording
    case notRecording

    var errorDescription: String? {
        switch self {
        case let .setupFailed(reason):
            "Recorder setup failed: \(reason)"
        case let .recordingFailed(reason):
            "Recording failed: \(reason)"
        case .missingRecordingURL:
            "Missing recording URL"
        case .alreadyRecording:
            "Already recording"
        case .notRecording:
            "Not currently recording"
        }
    }
}

// MARK: - Audio Recorder Service

actor AudioRecorderService {
    private var audioRecorder: AVAudioRecorder?
    private var isCurrentlyRecording = false
    private let permissionService = PermissionService()

    private let audioSettings: [String: Any] = [
        AVFormatIDKey: Int(kAudioFormatLinearPCM),
        AVSampleRateKey: 44100.0,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        AVLinearPCMBitDepthKey: 16,
        AVLinearPCMIsBigEndianKey: false,
        AVLinearPCMIsFloatKey: false,
    ]

    // MARK: - Recording Control

    func startRecording(to url: URL) async throws {
        try await permissionService.requestMicrophonePermission()

        guard !isCurrentlyRecording else {
            throw AudioRecorderError.alreadyRecording
        }

        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: audioSettings)

            guard let recorder = audioRecorder else {
                throw AudioRecorderError.setupFailed("Failed to create recorder")
            }

            guard recorder.prepareToRecord() else {
                throw AudioRecorderError.setupFailed("Failed to prepare recorder")
            }

            guard recorder.record() else {
                throw AudioRecorderError.setupFailed("Failed to start recording")
            }

            isCurrentlyRecording = true

        } catch let error as AudioRecorderError {
            throw error
        } catch {
            throw AudioRecorderError.recordingFailed(error.localizedDescription)
        }
    }

    func stopRecording() async throws {
        guard isCurrentlyRecording else {
            throw AudioRecorderError.notRecording
        }

        audioRecorder?.stop()
        audioRecorder = nil
        isCurrentlyRecording = false
    }

    func cancelRecording() async {
        if isCurrentlyRecording {
            audioRecorder?.stop()
            audioRecorder = nil
            isCurrentlyRecording = false
        }
    }

    // MARK: - State Queries

    func getRecordingStatus() -> Bool {
        isCurrentlyRecording
    }

    func getCurrentRecordingTime() -> TimeInterval {
        guard isCurrentlyRecording, let recorder = audioRecorder else {
            return 0
        }
        return recorder.currentTime
    }
}
