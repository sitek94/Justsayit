import AppKit
@preconcurrency import ApplicationServices
import CoreGraphics
import Foundation

// MARK: - Output Error Types

enum OutputError: Error, LocalizedError {
    case clipboardFailed
    case pasteFailed(String)
    case permissionDenied

    var errorDescription: String? {
        switch self {
        case .clipboardFailed:
            "Failed to copy to clipboard"
        case let .pasteFailed(reason):
            "Failed to paste: \(reason)"
        case .permissionDenied:
            "Permission denied for automation"
        }
    }
}

actor OutputService {
    @MainActor
    func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }

    @MainActor
    func pasteToActiveApp(_ text: String) throws {
        copyToClipboard(text)

        guard hasAccessibilityPermissions() else {
            throw OutputError.permissionDenied
        }

        simulatePasteInActiveApp()
    }

    @MainActor
    private func simulatePasteInActiveApp() {
        // 1. Get the previously active app (using NSWorkspace)
        // 2. Activate your app, set clipboard
        // 3. Reactivate previous app
        // 4. Simulate Cmd+V:
        let src = CGEventSource(stateID: .combinedSessionState)
        let cmdDown = CGEvent(
            keyboardEventSource: src, virtualKey: 0x37, keyDown: true
        ) // Cmd
        let vDown = CGEvent(
            keyboardEventSource: src, virtualKey: 0x09, keyDown: true
        ) // V
        let vUp = CGEvent(
            keyboardEventSource: src, virtualKey: 0x09, keyDown: false
        )
        let cmdUp = CGEvent(
            keyboardEventSource: src, virtualKey: 0x37, keyDown: false
        )
        cmdDown?.flags = .maskCommand
        vDown?.flags = .maskCommand
        vDown?.post(tap: .cgAnnotatedSessionEventTap)
        vUp?.post(tap: .cgAnnotatedSessionEventTap)
        cmdUp?.post(tap: .cgAnnotatedSessionEventTap)
    }

    @MainActor
    private func hasAccessibilityPermissions() -> Bool {
        let checkOptPrompt =
            kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        let options = [checkOptPrompt: false]
        return AXIsProcessTrustedWithOptions(options as CFDictionary)
    }
}
