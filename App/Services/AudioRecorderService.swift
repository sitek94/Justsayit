import AVFoundation
import Foundation

// MARK: - Audio Recorder Service
actor AudioRecorderService {
    private var audioRecorder: AVAudioRecorder?
    private var isCurrentlyRecording = false

    private let audioSettings: [String: Any] = [
        AVFormatIDKey: Int(kAudioFormatLinearPCM),
        AVSampleRateKey: 44100.0,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        AVLinearPCMBitDepthKey: 16,
        AVLinearPCMIsBigEndianKey: false,
        AVLinearPCMIsFloatKey: false,
    ]

    // MARK: - Permission Management
    func checkPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            let status = AVCaptureDevice.authorizationStatus(for: .audio)
            switch status {
            case .authorized:
                continuation.resume(returning: true)
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .audio) { granted in
                    continuation.resume(returning: granted)
                }
            default:
                continuation.resume(returning: false)
            }
        }
    }

    func requestPermission() async throws {
        guard await checkPermission() else {
            throw AudioRecorderError.permissionDenied
        }
    }

    // MARK: - Recording Control
    func startRecording(to url: URL) async throws {
        try await requestPermission()

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
        return isCurrentlyRecording
    }

    func getCurrentRecordingTime() -> TimeInterval {
        guard isCurrentlyRecording, let recorder = audioRecorder else {
            return 0
        }
        return recorder.currentTime
    }
}

// MARK: - Audio Recorder Error Types
enum AudioRecorderError: Error, LocalizedError {
    case permissionDenied
    case setupFailed(String)
    case recordingFailed(String)
    case alreadyRecording
    case notRecording

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Microphone permission required"
        case .setupFailed(let reason):
            return "Recorder setup failed: \(reason)"
        case .recordingFailed(let reason):
            return "Recording failed: \(reason)"
        case .alreadyRecording:
            return "Already recording"
        case .notRecording:
            return "Not currently recording"
        }
    }
}
