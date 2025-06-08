import Foundation
import Observation

@MainActor
@Observable
final class RecordingManager {
    private(set) var isRecording: Bool = false
    private(set) var elapsedTime: TimeInterval = 0
    private var timer: Timer?

    private let audioRecorderService: AudioRecorderService
    private let storageService: RecordingStorageService
    private let transcriptionService: TranscriptionService
    private let processingService: ProcessingService
    private let clipboardService: ClipboardService
    
    init(audioRecorderService: AudioRecorderService, storageService: RecordingStorageService, transcriptionService: TranscriptionService, processingService: ProcessingService, clipboardService: ClipboardService) {
        self.audioRecorderService = audioRecorderService
        self.storageService = storageService
        self.transcriptionService = transcriptionService
        self.processingService = processingService
        self.clipboardService = clipboardService
    }

    convenience init() {
        let apiKeysService = ApiKeysService()
        let transcriptionService = OpenAITranscriptionService(apiKeysService: apiKeysService)
        let processingService = OpenAIProcessingService(apiKeysService: apiKeysService)
        self.init(audioRecorderService: AudioRecorderService(), storageService: RecordingStorageService(), transcriptionService: transcriptionService, processingService: processingService, clipboardService: AppClipboardService())
    }


    func toggleRecording() async {
        do {
        if isRecording {
            try await stopAndProcessRecording()
        } else {
            try await startRecording()
        }
        } catch {
            // TODO: Handle it better
            print("Error: \(error)")
            print("Error details: \(error.localizedDescription)")
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
        print("Saving recording...")
        let savedRecording = try await storageService.save(temporaryURL: url, duration: elapsedTime, prompt: "")
        print("Saved recording: \(savedRecording)")
        
        print("Start transcription...")
        let rawResult = try await transcriptionService.transcribe(audioURL: savedRecording.audioFileURL)
        print("Transcription successful: \(rawResult)")

        print("Start AI processing...")
        let processedResult = try await processingService.process(text: rawResult)
        print("Processing successful: \(processedResult)")
        
        print("Pasting result at cursor...")
        try clipboardService.pasteAtCursor(processedResult)

        print("Done")
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
