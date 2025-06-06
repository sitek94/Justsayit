import Observation
import SwiftUI

@Observable
class AppSettings {
    var appName: String = "Justsayit"
    var openaiApiKey: String = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
    var groqApiKey: String = ProcessInfo.processInfo.environment["GROQ_API_KEY"] ?? ""
    var geminiApiKey: String = ProcessInfo.processInfo.environment["GEMINI_API_KEY"] ?? ""
    var anthropicApiKey: String = ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"] ?? ""

    var pasteResultText: Bool = true

    // TODO: For now these are just mocks
    var pushToTalkEnabled: Bool = false
    var automaticallyCheckForUpdates: Bool = true
    var launchOnLogin: Bool = true
    var errorLoggingEnabled: Bool = false
}

struct KeyboardShortcutDisplay: View {
    let keyName: String
    let isSystemImage: Bool

    init(_ name: String, systemImage: Bool = false) {
        keyName = name
        isSystemImage = systemImage
    }

    var body: some View {
        if isSystemImage {
            Image(systemName: keyName)
                .frame(minWidth: 20)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(4)
        } else {
            Text(keyName)
                .frame(minWidth: 20)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(4)
                .font(.system(size: 12, weight: .medium))
        }
    }
}

enum SettingsSection: String, CaseIterable, Identifiable, Codable {
    case general = "General"
    case apiKeys = "API Keys"
    case keyboardShortcuts = "Shortcuts"

    var id: String { rawValue }
}

struct SettingsView: View {
    @Environment(SettingsService.self) private var settingsService

    @State private var selection: SettingsSection? = .general

    var body: some View {
        NavigationSplitView {
            List(SettingsSection.allCases, selection: $selection) { section in
                NavigationLink(value: section) {
                    Text(section.rawValue)
                }
            }.listStyle(.sidebar)
                .toolbar(removing: .sidebarToggle)
                .listStyle(SidebarListStyle())
                .navigationSplitViewColumnWidth(200)
        } detail: {
            Group {
                switch selection {
                case .general:
                    SettingsGeneralView()
                case .apiKeys:
                    SettingsAPIKeysView(settingsService: settingsService)
                case .keyboardShortcuts:
                    SettingsKeyboardShortcutsView()
                case .none:
                    Text("Select a section")
                }
            }
            .background(.black)
        }
        .frame(minWidth: 600, idealWidth: 600, maxWidth: 700, minHeight: 400, idealHeight: 450, maxHeight: 500)
        .fixedSize()
    }
}

#Preview {
    @State @Previewable var appSettings = AppSettings()
    @State @Previewable var settingsService = SettingsService()
    @State @Previewable var updaterService = UpdaterService()

    SettingsView().environment(appSettings)
        .environment(settingsService)
        .environment(updaterService)
}
