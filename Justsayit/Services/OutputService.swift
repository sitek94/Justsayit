import AppKit
import Foundation

// MARK: - Output Error Types
enum OutputError: Error, LocalizedError {
    case clipboardFailed
    case pasteFailed(String)
    case permissionDenied

    var errorDescription: String? {
        switch self {
        case .clipboardFailed:
            return "Failed to copy to clipboard"
        case .pasteFailed(let reason):
            return "Failed to paste: \(reason)"
        case .permissionDenied:
            return "Permission denied for automation"
        }
    }
}

actor OutputService {
    func copyToClipboard(_ text: String) async throws {
        // TODO: Implement actual clipboard functionality
        await MainActor.run {
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(text, forType: .string)
        }
    }

    func pasteToActiveApp(_ text: String) async throws {
        // TODO: Implement auto-paste functionality
        // This will require accessibility permissions and CGEvent simulation

        throw OutputError.pasteFailed("Auto-paste not implemented yet")
    }
}
