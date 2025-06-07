# Implementation Plan

This document outlines a practical, step-by-step plan for implementing the application based on the architectural blueprint.

## Phase 1: Project Setup & Foundations

1.  **Create Project**: Create a new macOS SwiftUI application in Xcode.
2.  **Establish Folder Structure**: Create the top-level folders: `Views`, `ViewModels`, `Models`, `Services`, and `Managers`.
3.  **Define SwiftData Models**:
    - Create the `Preset.swift` and `HistoryItem.swift` files.
    - Write the code for the `@Model` classes exactly as defined in the architectural blueprint.
    - Set up a default, hardcoded `Preset` to be created on first launch.
4.  **Define Protocols**:
    - Create the `.swift` files for `AudioService`, `TranscriptionService`, and `AIProcessingService` and add the protocol definitions.

## Phase 2: Core Functionality

1.  **Build the `AudioService`**:
    - Create an implementation (`AVFoundationAudioService`) that uses `AVFoundation`.
    - Implement the `startRecording` and `stopRecording` methods to handle microphone input and save a `.wav` or `.m4a` file to a temporary directory.
2.  **Build the `GlobalShortcutManager`**:
    - Research and implement the code to register and listen for a system-wide hotkey. This will likely involve using `NSEvent.addGlobalMonitorForEvents`.
    - This manager should broadcast notifications or use callbacks when the shortcut is pressed.
3.  **Basic `RecordingViewModel`**:
    - Create the `RecordingViewModel`.
    - It should be able to create an `ActivePreset`.
    - Implement the logic to interact with the `AudioService`. Create methods like `toggleRecording()`.

## Phase 3: UI & API Integration

1.  **Build `RecordingView`**:
    - Create the basic UI with "Start/Stop", "Pick Preset", and "Language" buttons.
    - Connect the UI controls to the `RecordingViewModel` to trigger actions and display state.
2.  **Implement `TranscriptionService`**:
    - Create an `OpenAITranscriptionService` that conforms to the protocol.
    - This class will handle making the `URLRequest` to the OpenAI Whisper API endpoint, including setting the auth headers and multipart form data for the audio file.
3.  **Connect the Pipeline**:
    - Extend the `RecordingViewModel` to call the `TranscriptionService` after the `AudioService` finishes.
    - Ensure the UI properly reflects the state changes (e.g., showing a progress indicator).

## Phase 4: Full Feature Set

1.  **Build History & Preset Views**: Flesh out the UI for managing history and presets using SwiftData.
2.  **Implement AI Processing**: Build the `AIProcessingService` and integrate it into the `RecordingViewModel`'s pipeline.
3.  **Refine Shortcut Flow**: Implement the final steps of the automated workflow (sound, copy, paste, hide) and add the corresponding toggles in the `SettingsView`.