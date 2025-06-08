import Foundation
import AVFoundation

private let logger = Logger.make(category: "AudioRecorder")


actor AudioRecorder {
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    private var stopContinuation: CheckedContinuation<URL?, Error>?
    
    private let audioSettings: [String: Any] = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC), // Using AAC is a good default for macOS
        AVSampleRateKey: 44100.0,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]
    
    // MARK: - Public Methods
    
    func startRecording() throws -> URL {
        
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("temporaryRecording.caf")
        
        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: audioSettings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            
            return fileURL
        } catch {
            logger.error("Failed to start recording: \(error.localizedDescription)")
            throw error
        }
    }
    
    func stopRecording() async throws -> URL? {
        guard let recorder = audioRecorder else {
            logger.warning("Not recording. Ignoring request to stop.")
            return nil
        }
        
        return try await withCheckedThrowingContinuation { continuation in
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
    
    // private func startTimer() {
    //     stopTimer() // Ensure no other timers are running
        
    //     // A timer to update the elapsedTime property every 0.1 seconds
    //     timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
    //         guard let self = self else { return }

    //         Task { @MainActor in
    //             self.elapsedTime = self.audioRecorder?.currentTime ?? 0
    //         }
    //     }
    // }
    
    // private func stopTimer() {
    //     timer?.invalidate()
    //     timer = nil
    //     // Reset elapsedTime when the timer stops
    //     elapsedTime = 0
    // }
}


// MARK: - Delegate Conformance
extension AudioRecorder: AVAudioRecorderDelegate {
    
    
     nonisolated func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        Task { @MainActor in
            
            if flag {
                logger.info("Recording finished successfully.")
                self.stopContinuation?.resume(returning: recorder.url)
            } else {
                logger.error("Recording failed to finish successfully.")
                self.stopContinuation?.resume(returning: nil)
            }
            self.stopContinuation = nil
        }
    }
    
    // Called if an encoding error occurs.
    nonisolated func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
            logger.error("Audio recorder encoding error: \(error?.localizedDescription ?? "unknown error")")
            stopContinuation?.resume(throwing: error ?? AudioRecorderError.encodingFailed)
    }
}


enum AudioRecorderError: Error {
    case encodingFailed
}