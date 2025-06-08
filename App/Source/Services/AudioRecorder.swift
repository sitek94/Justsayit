import Foundation
import AVFoundation

private let logger = Logger.make(category: "AudioRecorder")

@MainActor
final class AudioRecorder: NSObject, ObservableObject {
    
    @Published private(set) var isRecording = false
    @Published private(set) var elapsedTime: TimeInterval = 0
    @Published private(set) var temporaryRecordingURL: URL?
    
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
    
    func startRecording() throws {
        // 1. Check if we are already recording
        guard !isRecording else {
            // Optional: throw an error here if needed
            logger.warning("Already recording. Ignoring request to start.")
            return
        }
        
        // 2. Create a URL for the temporary recording file
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("temporaryRecording.caf")
        self.temporaryRecordingURL = fileURL
        
        // 3. Setup and start the AVAudioRecorder
        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: audioSettings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            
            // 4. Update state and start the timer
            self.isRecording = true
            startTimer()
            logger.info("Recording started successfully.")
            
        } catch {
            logger.error("Failed to start recording: \(error.localizedDescription)")
            self.isRecording = false
            // Re-throw the error to let the caller know something went wrong
            throw error
        }
    }
    
    // 👇 This function is now async and returns the URL!
    func stopRecording() async throws -> URL? {
        guard isRecording else {
            logger.warning("Not recording. Ignoring request to stop.")
            return nil
        }
        
        logger.info("Stopping recording...")
        
        // This creates a pause point for our async function.
        // The code inside the `withCheckedThrowingContinuation` block runs immediately.
        // The whole function will "await" until `continuation.resume` is called.
        return try await withCheckedThrowingContinuation { continuation in
            // We store the continuation so the delegate can access it.
            self.stopContinuation = continuation
            // We trigger the stop. The delegate will now be called eventually.
            self.audioRecorder?.stop()
        }
    }
    
    // MARK: - Private Timer Methods
    
    private func startTimer() {
        stopTimer() // Ensure no other timers are running
        
        // A timer to update the elapsedTime property every 0.1 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            Task { @MainActor in
                self.elapsedTime = self.audioRecorder?.currentTime ?? 0
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        // Reset elapsedTime when the timer stops
        elapsedTime = 0
    }
}


// MARK: - Delegate Conformance
extension AudioRecorder: AVAudioRecorderDelegate {
    
    
     nonisolated func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        Task { @MainActor in
            self.isRecording = false
            self.stopTimer()
            
            if flag {
                logger.info("Recording finished successfully.")
                // ✅ Resume the paused function, returning the final URL.
                self.stopContinuation?.resume(returning: recorder.url)
            } else {
                logger.error("Recording failed to finish successfully.")
                // ❌ Resume the paused function, returning nil.
                self.stopContinuation?.resume(returning: nil)
            }
            // Clear the continuation.
            self.stopContinuation = nil
        }
    }
    
    // Called if an encoding error occurs.
    nonisolated func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        Task { @MainActor in
            self.isRecording = false
            self.stopTimer()
            logger.error("Audio recorder encoding error: \(error?.localizedDescription ?? "unknown error")")
        }
    }
}


