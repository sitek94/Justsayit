import Observation
import SwiftUI

enum SettingsSection: String, CaseIterable, Identifiable, Codable {
    case general = "General"
    case apiKeys = "API Keys"
    case keyboardShortcuts = "Shortcuts"
    case presets = "Presets"

    var id: String { rawValue }
}

struct SettingsView: View {
    @State private var selection: SettingsSection? = .general
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        NavigationSplitView {
            List(SettingsSection.allCases, selection: $selection) { section in
                if section == .presets {
                    Button {
                        openWindow(id: AppWindow.presets.id)
                    } label: {
                        HStack {
                            Text(section.rawValue)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                } else {
                    NavigationLink(value: section) {
                        Text(section.rawValue)
                    }
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
                    SettingsApiKeysView()
                case .keyboardShortcuts:
                    SettingsKeyboardShortcutsView()
                case .presets:
                    Text("The presets are managed in a separate window now.")
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
    @State @Previewable var updaterService = UpdaterService()

    SettingsView()
        .environment(updaterService)
}
