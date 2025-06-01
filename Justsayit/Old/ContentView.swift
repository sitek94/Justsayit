//import SwiftUI
//
//struct OldContentView: View {
//    @EnvironmentObject private var audioManager: AudioRecordingManager
//    @ObservedObject var whisperClient: WhisperAPIClient
//    @State private var showingSettings = false
//    @State private var showingTranscriptionHistory = false
//    @State private var showingError = false
//    @State private var errorMessage = ""
//    
//    var body: some View {
//        VStack(spacing: 0) {
//            // Audio Visualization Section
//            audioVisualizationSection
//            
//            // Controls Section
//            controlsSection
//            
//            // Transcription Section
//            transcriptionSection
//        }
//        .background(Color(NSColor.windowBackgroundColor))
//        .alert("Error", isPresented: $showingError) {
//            Button("OK") { }
//        } message: {
//            Text(errorMessage)
//        }
//        .sheet(isPresented: $showingSettings) {
//            SettingsView(whisperClient: whisperClient)
//        }
//        .sheet(isPresented: $showingTranscriptionHistory) {
//            TranscriptionHistoryView(whisperClient: whisperClient)
//        }
//    }
//    
//    // MARK: - Audio Visualization Section
//    private var audioVisualizationSection: some View {
//        VStack(spacing: 16) {
//            // Status indicator
//            HStack {
//                Circle()
//                    .fill(audioManager.isRecording ? Color.red : Color.gray)
//                    .frame(width: 12, height: 12)
//                    .scaleEffect(audioManager.isRecording ? 1.2 : 1.0)
//                    .animation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true), 
//                              value: audioManager.isRecording)
//                
//                Text(audioManager.isRecording ? "Recording..." : "Ready")
//                    .font(.headline)
//                    .foregroundColor(audioManager.isRecording ? .red : .primary)
//                
//                if audioManager.isRecording {
//                    Text(audioManager.formattedDuration())
//                        .font(.system(.body, design: .monospaced))
//                        .foregroundColor(.secondary)
//                }
//                
//                Spacer()
//            }
//            .padding(.horizontal)
//            
//            // Audio visualization
//            AudioVisualizationView(audioManager: audioManager)
//                .frame(height: 120)
//        }
//        .padding(.top)
//        .background(Color(NSColor.controlBackgroundColor))
//    }
//    
//    // MARK: - Controls Section
//    private var controlsSection: some View {
//        HStack(spacing: 20) {
//            // Start/Stop Recording Button
//            Button(action: {
//                if audioManager.permissionGranted {
//                    audioManager.toggleRecording()
//                    
//                    // If we just stopped recording, transcribe automatically
//                    if !audioManager.isRecording, let url = audioManager.lastRecordingURL {
//                        Task {
//                            await transcribeLastRecording()
//                        }
//                    }
//                } else {
//                    showPermissionError()
//                }
//            }) {
//                HStack {
//                    Image(systemName: audioManager.isRecording ? "stop.fill" : "record.circle.fill")
//                        .font(.title2)
//                    Text(audioManager.isRecording ? "Stop" : "Start")
//                        .font(.headline)
//                }
//                .frame(width: 120, height: 40)
//                .background(audioManager.isRecording ? Color.red : Color.blue)
//                .foregroundColor(.white)
//                .clipShape(RoundedRectangle(cornerRadius: 8))
//            }
//            .keyboardShortcut(.space, modifiers: [.command])
//            .disabled(!audioManager.permissionGranted)
//            
//            Spacer()
//            
//            // Additional controls
//            HStack(spacing: 12) {
//                // Copy to clipboard button
//                Button(action: {
//                    whisperClient.copyLastTranscriptionToClipboard()
//                }) {
//                    Image(systemName: "doc.on.clipboard")
//                        .font(.title2)
//                }
//                .help("Copy transcription to clipboard")
//                .disabled(whisperClient.lastTranscription.isEmpty)
//                
//                // Transcription history button
//                Button(action: {
//                    showingTranscriptionHistory = true
//                }) {
//                    Image(systemName: "clock.arrow.circlepath")
//                        .font(.title2)
//                }
//                .help("View transcription history")
//                
//                // Settings button
//                Button(action: {
//                    showingSettings = true
//                }) {
//                    Image(systemName: "gear")
//                        .font(.title2)
//                }
//                .help("Settings")
//                
//                // Close window button
//                Button(action: {
//                    NSApplication.shared.keyWindow?.close()
//                }) {
//                    Image(systemName: "xmark.circle.fill")
//                        .font(.title2)
//                        .foregroundColor(.red)
//                }
//                .help("Close window")
//            }
//        }
//        .padding()
//        .background(Color(NSColor.controlBackgroundColor))
//    }
//    
//    // MARK: - Transcription Section
//    private var transcriptionSection: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            HStack {
//                Text("Transcription")
//                    .font(.headline)
//                
//                if whisperClient.isTranscribing {
//                    ProgressView()
//                        .scaleEffect(0.7)
//                    Text("Transcribing...")
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                }
//                
//                Spacer()
//                
//                if !whisperClient.lastTranscription.isEmpty {
//                    Text("\(whisperClient.lastTranscription.count) characters")
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                }
//            }
//            
//            ScrollView {
//                Text(whisperClient.lastTranscription.isEmpty ? 
//                     "Transcription will appear here..." : 
//                     whisperClient.lastTranscription)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding()
//                    .background(Color(NSColor.textBackgroundColor))
//                    .clipShape(RoundedRectangle(cornerRadius: 8))
//                    .foregroundColor(whisperClient.lastTranscription.isEmpty ? .secondary : .primary)
//            }
//            .frame(minHeight: 100, maxHeight: 200)
//        }
//        .padding()
//    }
//    
//    // MARK: - Actions
//    private func transcribeLastRecording() async {
//        guard let url = audioManager.lastRecordingURL else {
//            showError("No recording found to transcribe")
//            return
//        }
//        
//        do {
//            _ = try await whisperClient.transcribeAudio(from: url)
//        } catch {
//            showError("Transcription failed: \(error.localizedDescription)")
//        }
//    }
//    
//    private func showPermissionError() {
//        showError("Microphone permission is required. Please grant permission in System Settings > Privacy & Security > Microphone.")
//    }
//    
//    private func showError(_ message: String) {
//        errorMessage = message
//        showingError = true
//    }
//}
//
//// MARK: - Settings View
//struct SettingsView: View {
//    @ObservedObject var whisperClient: WhisperAPIClient
//    @Environment(\.dismiss) private var dismiss
//    @State private var apiKey = ""
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            Text("Settings")
//                .font(.title2)
//                .bold()
//            
//            Divider()
//            
//            VStack(alignment: .leading, spacing: 8) {
//                Text("OpenAI API Key")
//                    .font(.headline)
//                
//                SecureField("Enter your OpenAI API key", text: $apiKey)
//                    .textFieldStyle(.roundedBorder)
//                
//                Text("You can get your API key from openai.com")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//            }
//            
//            Spacer()
//            
//            HStack {
//                Button("Cancel") {
//                    dismiss()
//                }
//                
//                Spacer()
//                
//                Button("Save") {
//                    whisperClient.setAPIKey(apiKey)
//                    dismiss()
//                }
//                .buttonStyle(.borderedProminent)
//                .disabled(apiKey.isEmpty)
//            }
//        }
//        .padding()
//        .frame(width: 400, height: 200)
//    }
//}
//
//// MARK: - Transcription History View
//struct TranscriptionHistoryView: View {
//    @ObservedObject var whisperClient: WhisperAPIClient
//    @Environment(\.dismiss) private var dismiss
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            HStack {
//                Text("Transcription History")
//                    .font(.title2)
//                    .bold()
//                
//                Spacer()
//                
//                Button("Clear All") {
//                    whisperClient.clearHistory()
//                }
//                .disabled(whisperClient.transcriptionHistory.isEmpty)
//            }
//            
//            Divider()
//            
//            if whisperClient.transcriptionHistory.isEmpty {
//                VStack {
//                    Spacer()
//                    Text("No transcriptions yet")
//                        .foregroundColor(.secondary)
//                    Spacer()
//                }
//            } else {
//                List(whisperClient.transcriptionHistory) { result in
//                    VStack(alignment: .leading, spacing: 4) {
//                        HStack {
//                            Text(result.audioFileName)
//                                .font(.caption)
//                                .foregroundColor(.secondary)
//                            
//                            Spacer()
//                            
//                            Text(result.formattedTimestamp)
//                                .font(.caption)
//                                .foregroundColor(.secondary)
//                        }
//                        
//                        Text(result.transcription)
//                            .lineLimit(3)
//                    }
//                    .padding(.vertical, 4)
//                }
//            }
//            
//            HStack {
//                Spacer()
//                Button("Close") {
//                    dismiss()
//                }
//            }
//        }
//        .padding()
//        .frame(width: 500, height: 400)
//    }
//}
//
//#Preview {
//    OldContentView(whisperClient: WhisperAPIClient.preview)
//        .environmentObject(AudioRecordingManager())
//        .frame(width: 400, height: 500)
//}
