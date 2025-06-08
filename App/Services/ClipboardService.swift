import AppKit
import Foundation

// MARK: - Clipboard Error Types

enum ClipboardError: Error, LocalizedError {
    case permissionDenied

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            "Accessibility Permissions are required to paste text. Please grant them in System Settings."
        }
    }
}

// MARK: - Clipboard Service Protocol

@MainActor
protocol ClipboardService {
    func copy(_ text: String)
    func pasteAtCursor(_ text: String) throws
}

// MARK: - Main Implementation

@MainActor
final class DefaultClipboardService: ClipboardService {
    func copy(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }

    func pasteAtCursor(_ text: String) throws {
        copy(text)

        guard hasAccessibilityPermissions() else {
            throw ClipboardError.permissionDenied
        }

        simulateCommandV()
    }

    // MARK: - Private Helpers

    private func hasAccessibilityPermissions() -> Bool {
        AXIsProcessTrusted()
        // TODO: When implementing more graceful redirection to System Settings use the following:
        // @preconcurrency import ApplicationServices
        // let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false]
        // return AXIsProcessTrustedWithOptions(options as CFDictionary)
    }

    private func simulateCommandV() {
        let source = CGEventSource(stateID: .hidSystemState)

        let cmdDown = CGEvent(keyboardEventSource: source, virtualKey: 0x37, keyDown: true)
        let vDown = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true)
        let vUp = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
        let cmdUp = CGEvent(keyboardEventSource: source, virtualKey: 0x37, keyDown: false)

        cmdDown?.flags = .maskCommand
        vDown?.flags = .maskCommand
        vUp?.flags = .maskCommand

        cmdDown?.post(tap: .cghidEventTap)
        vDown?.post(tap: .cghidEventTap)
        vUp?.post(tap: .cghidEventTap)
        cmdUp?.post(tap: .cghidEventTap)
    }
}
