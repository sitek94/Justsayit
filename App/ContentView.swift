import SwiftUI

@MainActor
@Observable
class ContentViewModel {

    @Published var isRecording: Bool = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var statusMessage = "Ready to record."
    @Published var prompt = "Some test LLM prompt."

    private let storageService = RecordingStorageService()
    private let audioRecorderService = AudioRecorderService()
    private var timer: Timer?
    private var currentRecordingURL: URL?

    func toggleRecording(using recorder: AudioRecorder) {
        if isRecording {
            Task {
                do { try await stopAndProcessRecording(using: recorder) } catch {
                    statusMessage = "[ERROR]: whatever"
                }
                isRecording = false
            }
        } else {
            startRecording(using: recorder)
            isRecording = true
        }
    }

    private func startRecording(using recorder: AudioRecorder) {
        do {
            try recorder.startRecording()
        } catch {
            statusMessage = "[ERROR]: startRecording"
        }
    }

    private func stopAndProcessRecording(using recorder: AudioRecorder) async throws {
        guard let url = try await recorder.stopRecording() else {
            fatalError("TODO: failed to get URL from AudioRecorder")
        }

        let savedRecording = try await storageService.save(
            temporaryURL: url,
            duration: recorder.elapsedTime,
            prompt: prompt
        )
        print(savedRecording.audioFileURL)
        print("Start transcribing...")

        print("Saver rawResult to metadata")
        print("Start AI processing")
        print("Saver result to metadata")

        print("Copy result to clipboard")
        print("Paste result at cursor")
    }

 private func startTimer() {
        stopTimer() // Ensure no other timers are running
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            Task { @MainActor in
                self.elapsedTime = self.audioRecorderService.currentTime
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        stopTimer()
    }
}

struct ContentView: View {
    @StateObject private var audioRecorder = AudioRecorder()
    @StateObject private var viewModel = ContentViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text(String(format: "%.2f", audioRecorder.elapsedTime))
                .font(.system(size: 40, weight: .light, design: .monospaced))

            Button(action: { viewModel.toggleRecording(using: audioRecorder) }) {
                Text(audioRecorder.isRecording ? "Stop Recording" : "Start Recording")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 200)
                    .background(audioRecorder.isRecording ? Color.red : Color.blue)
                    .cornerRadius(12)
            }

            Text(viewModel.statusMessage)
                .font(.caption)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
