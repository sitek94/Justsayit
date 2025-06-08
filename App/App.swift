import KeyboardShortcuts
import Sparkle
import SwiftUI

@main
struct JustsayitApp: App {
    @State private var updaterService = UpdaterService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 400, minHeight: 400)
        }
        
//        MenuBarExtra(AppWindow.menuBar.title, systemImage: "mic") {
//            AppMenuBar()
//        }
//        .menuBarExtraStyle(.menu)

//        Window(AppWindow.recordingMini.title, id: AppWindow.recordingMini.id) {
//            RecordingMiniView()
//                .modelContainer(sharedModelContainer)
//                .toolbar(removing: .title)
//                .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
//                .containerBackground(.regularMaterial, for: .window)
//                .onAppear {
//                    if let window = NSApp.windows.first(where: { $0.title == AppWindow.recordingMini.title }) {
//                        // Hide window controls
//                        window.standardWindowButton(.closeButton)?.isHidden = true
//                        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
//                        window.standardWindowButton(.zoomButton)?.isHidden = true
//                    }
//                }
//                .presentedWindowStyle(.hiddenTitleBar)
//        }
//        .windowBackgroundDragBehavior(.enabled)
//        .windowStyle(.hiddenTitleBar)
//        .windowResizability(.contentSize)
//        .windowLevel(.floating)
//
//        Window(AppWindow.presets.title, id: AppWindow.presets.id) {
//            PresetsView()
//                .modelContainer(sharedModelContainer)
//                .toolbar(removing: .title)
//                .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
//                .containerBackground(.regularMaterial, for: .window)
//        }
//        .windowResizability(.contentSize)
//
//        Window(AppWindow.history.title, id: AppWindow.history.id) {
//            HistoryView()
//                .modelContainer(sharedModelContainer)
//                .toolbar(removing: .title)
//                .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
//                .containerBackground(.regularMaterial, for: .window)
//        }
//        .windowResizability(.contentSize)
//
//        Settings {
//            SettingsView()
//                .modelContainer(sharedModelContainer)
//                .environment(updaterService)
//                .toolbar(removing: .title)
//                .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
//                .containerBackground(.regularMaterial, for: .window)
//        }
    }
}
