import Foundation
import Observation

@MainActor
@Observable
final class RecordingManager {
    private(set) var isRecording: Bool = false
    private(set) var elapsedTime: TimeInterval = 0

    private let audioRecorderService = AudioRecorderService()
    private let storageService = RecordingStorageService()
    private let transcriptionService: TranscriptionService = OpenAITranscriptionService()
    private var timer: Timer?

    func toggleRecording() async {
        do {
        if isRecording {
            try await stopAndProcessRecording()
        } else {
            try await startRecording()
        }
        } catch {
            fatalError("handle me")
        }
    }

    private func startRecording() async throws {
        let url = try await audioRecorderService.startRecording()
        print(url)
        isRecording = true
        startTimer()
    }

    private func stopAndProcessRecording() async throws {
        stopTimer()
        isRecording = false

        let url = try await audioRecorderService.stopRecording()
        let savedRecording = try await storageService.save(temporaryURL: url, duration: elapsedTime, prompt: "")
        print("Saved recording")
        
        let rawResult = try await transcriptionService.transcribe(audioURL: savedRecording.audioFileURL)
        print("Transcription successful: \(rawResult)")

        
        
//        print("Start AI processing")
//        print("Saver result to metadata")
//
//        print("Copy result to clipboard")
//        print("Paste result at cursor")
    }

    private func startTimer() {
        stopTimer() // Ensure no other timers are running
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.elapsedTime = await self?.audioRecorderService.currentTime ?? 0
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.elapsedTime = 0
        }
    }
}
