# Changelog

## 0.0.5

### Improvements

- Migrated API key storage from environment variables to the system Keychain for enhanced security.
  - Implemented a `KeychainManager` to handle all secure storage operations.
- Centralized settings management by introducing a `SettingsService`.
- Replaced string-based API key identifiers with a type-safe `APIKeyAccount` enum to improve code safety and maintainability.
- The API Keys settings view is now dynamically generated, simplifying the addition of new services in the future.

## 0.0.4

### Added

- Handle automatic updates using Sparkle.

## 0.0.3

### Added

- Menu bar icon for app access, providing options to open the main window, settings, or quit.
- Global keyboard shortcuts using the `KeyboardShortcuts` library to start/stop recording from any application.
  - The main window automatically shows on recording start and hides after transcription is finished.

### Changed

- Refactored the settings view into a `NavigationSplitView`, organizing settings into General, API Keys, and Keyboard Shortcuts for a cleaner structure.

## 0.0.2

Improved the settings view significantly - styled it and got it close to the final design. Most features are mocks for now, but the visual direction is clear.

Added paste-at-cursor functionality. When you stop recording, the transcription automatically pastes at your cursor position in other applications.

Cleaned up permissions after struggling with paste-at-cursor implementation. Initially tried Apple Events/AppleScript but it was flaky. Switched to CGEvent which works reliably. Removed all unnecessary permissions from info.plist and entitlements - this version has the minimum required, including app sandbox support.

## 0.0.1

Initial release with basic [Superwhisper](https://superwhisper.com)-like functionality:
- Press start to record audio (saves to app documents)
- Sends audio to OpenAI for transcription
- Passes through AI processing service (currently just a stub)
- Copies result to clipboard

Set up automatic GitHub releases pipeline. Not fully working in the app yet due to private repository, but should "just work" once the repository is public, because everything is set up.
