import AVFoundation
import Foundation

private let logger = Logger.make(category: "AudioRecorder")

enum AudioRecorderError: Error {
    case encodingFailed
    case missingURL
}

actor AudioRecorderService {
    private var audioRecorder: AVAudioRecorder?
    private var delegate: Delegate?
    private var stopContinuation: CheckedContinuation<URL, Error>?

    private var timer: Timer?
    private let audioSettings: [String: Any] = [
        AVFormatIDKey: Int(kAudioFormatLinearPCM),
        AVSampleRateKey: 44100.0,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
    ]

    // MARK: - Public Methods

    // This is an actor method, so it's safely isolated.
    func startRecording() throws -> URL {
        // Lazy initialize delegate the first time `startRecording` runs
        if delegate == nil {
            delegate = Delegate(owner: self)
        }

        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("temporaryRecording.caf")

        let recorder = try AVAudioRecorder(url: fileURL, settings: audioSettings)
        recorder.delegate = delegate // Use our helper class as the delegate
        recorder.record()

        audioRecorder = recorder
        return fileURL
    }

    // This is also isolated. No two calls can race.
    func stopRecording() async throws -> URL {
        // This is a beautiful, modern way to handle delegate callbacks.
        try await withCheckedThrowingContinuation { continuation in
            guard let recorder = self.audioRecorder else {
                // If there's no recorder, there's nothing to stop.
                // You could throw an error or handle it as needed.
                continuation.resume(throwing: AudioRecorderError.missingURL)
                return
            }
            self.stopContinuation = continuation
            recorder.stop()
        }
    }

    var currentTime: TimeInterval {
        audioRecorder?.currentTime ?? 0
    }

    var isRecording: Bool {
        audioRecorder?.isRecording ?? false
    }

    // MARK: - Private Timer Methods

    // This method will be safely called by our delegate.
    private func recordingFinished(url: URL) {
        // We resume the paused stopRecording() function, returning the URL.
        stopContinuation?.resume(returning: url)
        stopContinuation = nil
    }

    private func recordingFailed(error: Error) {
        stopContinuation?.resume(throwing: error)
        stopContinuation = nil
    }

    // --- The Delegate Helper Class ---
    // This is a private class that can be an NSObject and handle the delegate protocol.
    private final class Delegate: NSObject, AVAudioRecorderDelegate {
        let owner: AudioRecorderService

        init(owner: AudioRecorderService) {
            self.owner = owner
        }

        func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
            if flag {
                // We safely call back to the actor.
                Task { await owner.recordingFinished(url: recorder.url) }
            } else {
                let error = AudioRecorderError.encodingFailed // Or some other error
                Task { await owner.recordingFailed(error: error) }
            }
        }

        func audioRecorderEncodeErrorDidOccur(_: AVAudioRecorder, error: Error?) {
            let errorToThrow = error ?? AudioRecorderError.encodingFailed
            Task { await owner.recordingFailed(error: errorToThrow) }
        }
    }
}
