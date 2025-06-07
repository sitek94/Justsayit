# Requirements & Decisions Log

This document tracks the evolution of the project requirements from initial idea to a concrete plan.

## Initial Goal (v0.1)

- **Objective**: Build a macOS application to record audio, transcribe it, and process it with an AI model.
- **Core Components (from mockups)**:
  - A recording view with visualization, transcript, and AI results.
  - Mini and Advanced modes for the recording view.
  - Views for History, Presets, and Settings.
- **Initial Tech Decisions**:
  - SwiftData for database.
  - Sequential, blocking pipeline: Record -> Transcribe -> AI Process.
  - Support for multiple AI providers (OpenAI, Gemini, Anthropic).

---

## Q&A and Refinements (v0.2)

This section details the clarifying questions and the key decisions that shaped the architecture.

#### **Q1: Platform and Target User?**
- **A**: **macOS only**. The primary user is a **developer**.

#### **Q2: Transcription Service?**
- **A**: Start with the **OpenAI Whisper API**. The architecture must be extensible to support other cloud APIs and local models in the future.

#### **Q3: How should the main "Language" control and the "Language" in a Preset interact?**
- **A**: The main view's controls provide a **temporary override**. Selecting a Preset populates the UI, but any changes made in the main view (like switching the language) apply only to the current session and **do not** modify the saved Preset.

#### **Q4: What happens if the user closes the window during an operation?**
- **A**: The operation is immediately **canceled**. No confirmation is needed.

#### **Q5: How should History Items be named?**
- **A**: The **display title** will be the first few words of the transcript. The underlying **filename** will be a timestamp (e.g., `YYYY-MM-DD-HHmmss.wav`). Renaming items is not a required feature.

#### **Q6: What are the key shortcuts and preferences?**
- **A**: A **global "toggle recording" shortcut** is the most critical feature. This shortcut initiates a fully automated workflow:
  1. Press to show window & start recording.
  2. Press again to stop.
  3. The app then automatically transcribes, processes, plays a "finished" sound, copies the result to the clipboard, pastes it at the system cursor, and hides itself.
  4. All post-processing steps (copy, paste, hide) must be **configurable** in the preferences.

#### **Q7: What if the global shortcut is pressed when the window is already open?**
- **A**: It should simply **start a new recording** in the existing window.

#### **Q8: How should system permissions (e.g., Accessibility for pasting) be handled?**
- **A**: The app will check for permissions. If they are not granted, the corresponding feature will be disabled in the UI, and the user will be provided with instructions and a link to the relevant System Settings pane.