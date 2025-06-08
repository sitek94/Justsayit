import Foundation
import Observation

@MainActor
@Observable
final class RecordingManager {
    
    private(set) var isRecording: Bool = false
    private(set) var elapsedTime: TimeInterval = 0
    
    private let audioRecorderService = AudioRecorderService()
    private var timer: Timer?
    
    func toggleRecording() async {
        if isRecording {
            await stopAndProcessRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        do {
            try audioRecorderService.startRecording()
            self.isRecording = true
            startTimer()
        } catch {
            // Handle error
        }
    }
    
    private func stopAndProcessRecording() async {
        stopTimer()
        self.isRecording = false
        // Reset elapsed time after a short delay so the UI can update
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.elapsedTime = 0
        }
        
        do {
            guard let url = try await audioRecorderService.stopRecording() else { return }
            // Now you can pass this URL to other services
            // await transcriptionService.transcribe(url)
        } catch {
            // Handle error
        }
    }
    
    private func startTimer() {
        stopTimer() // Ensure no other timers are running
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.elapsedTime = self?.audioRecorderService.currentTime ?? 0
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}