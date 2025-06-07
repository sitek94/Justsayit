import Foundation
import KeyboardShortcuts

enum AppWindow: String, CaseIterable {
    case menuBar
    case recording
    case recordingMini
    case settings
    case presets

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .menuBar:
            "Justsayit"
        case .recording:
            "Recording"
        case .recordingMini:
            "Recording Mini"
        case .settings:
            "Settings"
        case .presets:
            "Presets"
        }
    }
}

extension KeyboardShortcuts.Name {
//    static let showAppWindow = Self("showAppWindow", default: .init(.m, modifiers: .command))
//    static let openSettings = Self("openSettings", default: .init(._comma, modifiers: .command))
//    static let quitApp = Self("quitApp", default: .init(.q, modifiers: .command))

    // MARK: - Global Shortcuts

    static let toggleRecording = Self("toggleRecording")
    static let cancelRecording = Self("cancelRecording")
    static let changeMode = Self("changeMode")
}
