# Final Architectural Blueprint

This document defines the application's software architecture, data models, and service abstractions.

## 1. High-Level Structure

The application will be built using a modern MVVM (Model-View-ViewModel) approach on SwiftUI, with a clear separation of concerns.

- **/Views**: SwiftUI views for each screen (`RecordingView`, `HistoryView`, etc.).
- **/ViewModels**: View-specific logic and state management (`RecordingViewModel`, `HistoryViewModel`, etc.).
- **/Models**: SwiftData models (`Preset`, `HistoryItem`) and temporary state structs (`ActivePreset`).
- **/Services**: Protocol-based services for external interactions (`TranscriptionService`, `AudioService`, etc.).
- **/Managers**: High-level coordinators for global features (`GlobalShortcutManager`).

## 2. Data Models

#### `Preset` (Stored in SwiftData)
This defines a reusable template for a complete workflow.

- **id**: `UUID`
- **name**: `String`
- **transcriptionProvider**: `String` (e.g., "OpenAI")
- **transcriptionModel**: `String` (e.g., "whisper-1")
- **isAiProcessingEnabled**: `Bool`
- **processingProvider**: `String?` (e.g., "OpenAI")
- **processingModel**: `String?` (e.g., "gpt-4o")
- **prompt**: `String?`
- **language**: `String` (e.g., "en")

#### `HistoryItem` (Stored in SwiftData)
This stores the results of a past recording.

- **id**: `UUID`
- **audioFilePath**: `String`
- **createdAt**: `Date`
- **rawTranscript**: `String?`
- **aiProcessedText**: `String?`
- **sourcePresetName**: `String`
- **sourceLanguage**: `String`

#### `ActivePreset` (In-Memory Struct)
A temporary, in-memory object for the live recording session.

- **sourcePreset**: `Preset`
- **language**: `String` (This can be overridden from the `sourcePreset`'s value)

## 3. Service Abstractions (Protocols)

- **`AudioService`**:
  - `startRecording() throws`
  - `stopRecording() -> URL` (returns file path)
- **`TranscriptionService`**:
  - `transcribe(audioFile: URL, config: ActivePreset) async throws -> String`
- **`AIProcessingService`**:
  - `process(text: String, config: ActivePreset) async throws -> String`

## 4. Core Logic Flow (Shortcut-Triggered)

1.  `GlobalShortcutManager` detects a key press.
2.  `AppCoordinator` shows the `RecordingView` and tells the `RecordingViewModel` to start.
3.  `RecordingViewModel` initializes an `ActivePreset` from a selected `Preset`.
4.  `RecordingViewModel` uses `AudioService` to start recording.
5.  On the second shortcut press, the `ViewModel` stops the audio service, gets the file URL, and sequentially calls `TranscriptionService` and `AIProcessingService`, updating the UI state (e.g., "Transcribing...").
6.  Upon completion, it triggers system events (sound, copy, paste) and hides the window.