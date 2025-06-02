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
    func copyToClipboard(_ text: String) async throws {
        await MainActor.run {
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(text, forType: .string)
        }
    }

    @MainActor
    func pasteToActiveApp(_ text: String) async throws {
        try await copyToClipboard(text)

        guard hasAccessibilityPermissions() else {
            throw OutputError.permissionDenied
        }

        try await simulateCommandV()
    }

    private func simulateCommandV() throws {
        let cmdKeyDown = CGEvent(keyboardEventSource: nil, virtualKey: 0x37, keyDown: true)
        let vKeyDown = CGEvent(keyboardEventSource: nil, virtualKey: 0x09, keyDown: true)
        let vKeyUp = CGEvent(keyboardEventSource: nil, virtualKey: 0x09, keyDown: false)
        let cmdKeyUp = CGEvent(keyboardEventSource: nil, virtualKey: 0x37, keyDown: false)

        guard let cmdDown = cmdKeyDown,
              let vDown = vKeyDown,
              let vUp = vKeyUp,
              let cmdUp = cmdKeyUp
        else {
            throw OutputError.pasteFailed("Failed to create key events")
        }

        // Set command modifier for V key events
        vDown.flags = .maskCommand
        vUp.flags = .maskCommand

        // Post events with small delays
        cmdDown.post(tap: .cghidEventTap)
        usleep(1000) // 1ms
        vDown.post(tap: .cghidEventTap)
        usleep(1000)
        vUp.post(tap: .cghidEventTap)
        usleep(1000)
        cmdUp.post(tap: .cghidEventTap)
    }

    @MainActor
    private func hasAccessibilityPermissions() -> Bool {
        let checkOptPrompt = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        let options = [checkOptPrompt: false]
        return AXIsProcessTrustedWithOptions(options as CFDictionary)
    }
}
