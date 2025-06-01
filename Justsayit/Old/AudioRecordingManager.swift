//import Foundation
//import AVFoundation
//import SwiftUI
//
//// MARK: - Audio Recording Model
//private struct AudioRecording {
//    let url: URL
//    let name: String
//    let date: Date
//    
//    var formattedDate: String {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .short
//        formatter.timeStyle = .short
//        return formatter.string(from: date)
//    }
//}
//
//// MARK: - Audio Recording Manager
//class AudioRecordingManager: NSObject, ObservableObject, @unchecked Sendable {
//    
//    // MARK: - Published Properties
//    @Published var isRecording = false
//    @Published var recordings: [AudioRecording] = []
//    @Published var recordingDuration: TimeInterval = 0
//    @Published var audioLevels: [Float] = Array(repeating: 0.0, count: 50)
//    @Published var permissionGranted = false
//    @Published var lastRecordingURL: URL?
//    
//    // MARK: - Private Properties
//    private var audioRecorder: AVAudioRecorder?
//    private var audioEngine: AVAudioEngine?
//    private var inputNode: AVAudioInputNode?
//    private var recordingTimer: Timer?
//    private var levelTimer: Timer?
//    
//    // MARK: - Audio Settings
//    private let audioSettings: [String: Any] = [
//        AVFormatIDKey: Int(kAudioFormatLinearPCM),
//        AVSampleRateKey: 44100.0,
//        AVNumberOfChannelsKey: 1,
//        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
//        AVLinearPCMBitDepthKey: 16,
//        AVLinearPCMIsBigEndianKey: false,
//        AVLinearPCMIsFloatKey: false
//    ]
//    
//    override init() {
//        super.init()
//        requestMicrophonePermission()
//        setupAudioEngine()
//        loadRecordings()
//    }
//    
//    // MARK: - Permission Management
//    private func requestMicrophonePermission() {
//        let status = AVCaptureDevice.authorizationStatus(for: .audio)
//        switch status {
//        case .authorized:
//            DispatchQueue.main.async {
//                self.permissionGranted = true
//            }
//        case .notDetermined:
//            AVCaptureDevice.requestAccess(for: .audio) { granted in
//                DispatchQueue.main.async {
//                    self.permissionGranted = granted
//                }
//            }
//        default:
//            DispatchQueue.main.async {
//                self.permissionGranted = false
//            }
//        }
//    }
//    
//    // MARK: - Recording Controls
//    func toggleRecording() {
//        if isRecording {
//            stopRecording()
//        } else {
//            startRecording()
//        }
//    }
//    
//    func startRecording() {
//        guard permissionGranted else {
//            print("Microphone permission not granted")
//            return
//        }
//        
//        guard !isRecording else { return }
//        
//        // Create recording URL
//        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        let fileName = "recording_\(Date().timeIntervalSince1970).wav"
//        lastRecordingURL = documentsPath.appendingPathComponent(fileName)
//        
//        do {
//            audioRecorder = try AVAudioRecorder(url: lastRecordingURL!, settings: audioSettings)
//            audioRecorder?.delegate = self
//            audioRecorder?.prepareToRecord()
//            audioRecorder?.record()
//            
//            isRecording = true
//            recordingDuration = 0
//            
//            // Start timers
//            startRecordingTimer()
//            startAudioVisualization()
//            
//        } catch {
//            print("Failed to start recording: \(error)")
//        }
//    }
//    
//    func stopRecording() {
//        guard isRecording else { return }
//        
//        audioRecorder?.stop()
//        audioRecorder = nil
//        
//        isRecording = false
//        stopTimers()
//        resetAudioLevels()
//        loadRecordings()
//        
//        print("Recording saved to: \(lastRecordingURL?.path ?? "Unknown")")
//    }
//    
//    // MARK: - Audio Visualization
//    private func setupAudioEngine() {
//        audioEngine = AVAudioEngine()
//        inputNode = audioEngine?.inputNode
//    }
//    
//    private func startAudioVisualization() {
//        guard let audioEngine = audioEngine,
//              let inputNode = inputNode else { return }
//        
//        let recordingFormat = inputNode.outputFormat(forBus: 0)
//        
//        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
//            self?.processAudioBuffer(buffer)
//        }
//        
//        do {
//            try audioEngine.start()
//        } catch {
//            print("Failed to start audio engine: \(error)")
//        }
//        
//        // Timer for updating visualization
//        levelTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
//            DispatchQueue.main.async {
//                self?.updateVisualizationLevels()
//            }
//        }
//    }
//    
//    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
//        guard let channelData = buffer.floatChannelData?[0] else { return }
//        
//        let frameLength = Int(buffer.frameLength)
//        var sum: Float = 0
//        
//        for i in 0..<frameLength {
//            sum += abs(channelData[i])
//        }
//        
//        let averageLevel = sum / Float(frameLength)
//        let scaledLevel = min(averageLevel * 10, 1.0) // Scale and clamp
//        
//        DispatchQueue.main.async {
//            // Shift array and add new level
//            self.audioLevels.removeFirst()
//            self.audioLevels.append(scaledLevel)
//        }
//    }
//    
//    private func updateVisualizationLevels() {
//        // Add some randomness for demo when not recording
//        if !isRecording {
//            for i in 0..<audioLevels.count {
//                audioLevels[i] = Float.random(in: 0...0.3)
//            }
//        }
//    }
//    
//    // MARK: - Timer Management
//    private func startRecordingTimer() {
//        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
//            DispatchQueue.main.async {
//                if let recorder = self?.audioRecorder {
//                    self?.recordingDuration = recorder.currentTime
//                }
//            }
//        }
//    }
//    
//    private func stopTimers() {
//        recordingTimer?.invalidate()
//        recordingTimer = nil
//        
//        levelTimer?.invalidate()
//        levelTimer = nil
//        
//        audioEngine?.inputNode.removeTap(onBus: 0)
//        audioEngine?.stop()
//    }
//    
//    private func resetAudioLevels() {
//        audioLevels = Array(repeating: 0.0, count: 50)
//    }
//    
//    // MARK: - File Management
//    func loadRecordings() {
//        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        
//        do {
//            let fileURLs = try FileManager.default.contentsOfDirectory(
//                at: documentsDirectory,
//                includingPropertiesForKeys: [.creationDateKey],
//                options: .skipsHiddenFiles
//            )
//            
//            let audioFiles = fileURLs.filter { url in
//                url.pathExtension.lowercased() == "wav"
//            }
//            
//            let newRecordings = audioFiles.compactMap { url in
//                do {
//                    let resourceValues = try url.resourceValues(forKeys: [.creationDateKey])
//                    let creationDate = resourceValues.creationDate ?? Date()
//                    let fileName = url.deletingPathExtension().lastPathComponent
//                    
//                    return AudioRecording(
//                        url: url,
//                        name: fileName.replacingOccurrences(of: "_", with: " ").capitalized,
//                        date: creationDate
//                    )
//                } catch {
//                    print("Error getting file attributes: \(error)")
//                    return nil
//                }
//            }.sorted { $0.date > $1.date } // Sort by newest first
//            
//            DispatchQueue.main.async {
//                self.recordings = newRecordings
//            }
//            
//        } catch {
//            print("Error loading recordings: \(error)")
//        }
//    }
//    
//    func deleteRecording(at offsets: IndexSet) {
//        for index in offsets {
//            let recording = recordings[index]
//            
//            do {
//                try FileManager.default.removeItem(at: recording.url)
//            } catch {
//                print("Error deleting recording: \(error)")
//            }
//        }
//        recordings.remove(atOffsets: offsets)
//    }
//    
//    // MARK: - Utilities
//    func formattedDuration() -> String {
//        let minutes = Int(recordingDuration) / 60
//        let seconds = Int(recordingDuration) % 60
//        let centiseconds = Int((recordingDuration.truncatingRemainder(dividingBy: 1)) * 100)
//        return String(format: "%02d:%02d.%02d", minutes, seconds, centiseconds)
//    }
//}
//
//// MARK: - AVAudioRecorderDelegate
//extension AudioRecordingManager: AVAudioRecorderDelegate {
//    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
//        if flag {
//            print("Recording finished successfully")
//        } else {
//            print("Recording failed")
//        }
//    }
//    
//    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
//        print("Audio recorder encode error: \(error?.localizedDescription ?? "Unknown error")")
//    }
//}
