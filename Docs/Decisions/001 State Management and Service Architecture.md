# ADR 001: State Management and Service Architecture

## Status

Accepted

## Context

I need to decide on a primary architecture for managing UI state and background services. The architecture must support sharing state (e.g., recording status) across multiple UI components like the main window and a menu bar, while ensuring background tasks like audio recording are concurrency-safe.

## Alternatives

-   Multiple, interacting `@Observable` objects managed directly by the View.
-   A single, monolithic ViewModel containing all state and business logic.
-   A centralized `RecordingManager` (stateful coordinator) that orchestrates stateless, actor-based services.

## Decision

I will implement a centralized `RecordingManager` to act as a single source of truth for UI state, which will coordinate stateless, `actor`-based services for background logic.

## Consequences

-   Consistent state across all UI components (main window, menu bar).
-   Simplified logic for adding new UI features that rely on shared state.
-   Guaranteed concurrency safety for background services via `actor` isolation.
-   Improved testability due to a clear separation of architectural layers (UI, state management, services).
-   A well-defined project structure with distinct folders for each layer.
-   Use of SwiftUI's `@Environment` to provide the global `RecordingManager` instance to the UI.