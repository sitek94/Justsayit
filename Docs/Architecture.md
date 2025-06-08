# Application Architecture

This document outlines the architectural patterns and principles used in this application. The goal is to create a codebase that is scalable, maintainable, testable, and safe.

## High-Level Overview

The application follows a **Centralized State Management** pattern (also known as the "Manager Pattern") combined with a decoupled **Service Layer**.

The core principles of this architecture are:
* **Single Source of Truth:** For any given domain of state (e.g., recording), there is one and only one object that owns and manages that state.
* **Separation of Concerns:** Each architectural layer has a distinct and well-defined responsibility.
* **Concurrency Safety:** Asynchronous operations and access to shared resources are handled in a way that prevents data races.

## The Architectural Layers

The application is divided into several distinct layers, each housed in its own folder.

### Views (The UI Layer)
* **Responsibility:** To present the UI and delegate user actions. Views are lightweight and reactive.
* **Implementation:** Standard SwiftUI `View` structs.
* **Behavior:** They observe a `Manager` for state changes and call methods on it in response to user input (e.g., button taps). They access the shared manager via the `@Environment` property wrapper.

### Managers (The State Management Layer)
* **Responsibility:** To act as the "brain" and single source of truth for a specific feature or domain. They manage all the UI state for that domain and coordinate the services.
* **Implementation:** `@Observable` classes.
* **Behavior:** A single instance of a manager (e.g., `RecordingManager`) is created at the root of the application and shared with the entire view hierarchy.

### Services (The Business Logic Layer)
* **Responsibility:** To perform specific, single-purpose tasks like recording audio, accessing storage, or calling an API. They are stateless from the UI's perspective.
* **Implementation:** Services that manage mutable resources or perform concurrent background work are implemented as `actor`s to ensure thread safety. Simpler, stateless utilities can be `struct`s or `enum`s with static methods.
* **Behavior:** Services are owned and called by a `Manager`.

### Models (The Data Layer)
* **Responsibility:** To define the data structures of the application.
* **Implementation:** Simple `struct` or `class` types, often conforming to `Codable` or `Identifiable`.

### Utils (The Utility Layer)
* **Responsibility:** To provide shared, reusable helper functions or types that don't belong to a specific layer (e.g., `Logger`, `PathProvider`).

## Data & Control Flow

A typical user interaction follows this sequence:
1.  A user interacts with a component in a SwiftUI `View` (e.g., taps the "Start Recording" button).
2.  The `View` calls the corresponding method on the shared `Manager` instance (e.g., `await recordingManager.toggleRecording()`).
3.  The `Manager` immediately updates its internal state (e.g., sets `isRecording = true`). This change is automatically published, and the UI updates reactively.
4.  The `Manager` then calls one or more `Service`s to perform the required background work (e.g., `try await audioRecorderService.startRecording()`).
5.  When the background task is complete, the `Service` returns a result (or throws an error) back to the `Manager`.
6.  The `Manager` processes this result and updates its state again, which may trigger a final UI update (e.g., setting `isRecording = false`).

## Project Folder Structure

To enforce the separation of concerns, the project follows this folder structure:

```
./App/
├── App.swift               // App entry point & root view definitions
├── Managers/
│   └── RecordingManager.swift
├── Models/
│   └── Recording.swift
├── Services/
│   ├── AudioRecorderService.swift
│   └── RecordingStorageService.swift
├── Views/
│   ├── RecordingView.swift
│   └── MenuBarView.swift
└── Utils/
    ├── Logger.swift
    └── PathProvider.swift
```