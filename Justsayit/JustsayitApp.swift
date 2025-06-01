//
//  JustsayitApp.swift
//  Justsayit
//
//  Created by Maciej Sitkowski on 29/05/2025.
//
import SwiftUI

@Observable
class AppSettings {
    var appName: String = "Justsayit"
    var openaiApiKey: String = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
    var groqApiKey: String = ProcessInfo.processInfo.environment["GROQ_API_KEY"] ?? ""
    var geminiApiKey: String = ProcessInfo.processInfo.environment["GEMINI_API_KEY"] ?? ""
    var anthropicApiKey: String = ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"] ?? ""
}

@main
struct JustsayitApp: App {
    @State private var appSettings = AppSettings()

    var body: some Scene {
        Window("main", id: "main") {
            ContentView()
                .environment(appSettings)
                .toolbar(removing: .title)
                .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
                .containerBackground(.regularMaterial, for: .window)
                .onAppear {
                    if let window = NSApp.windows.first(where: { $0.title == "main" }) {
                        // Hide window controls
                        window.standardWindowButton(.closeButton)?.isHidden = true
                        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
                        window.standardWindowButton(.zoomButton)?.isHidden = true
                    }
                }
                .presentedWindowStyle(.hiddenTitleBar)
        }
        .windowBackgroundDragBehavior(.enabled)
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)

        Settings {
            SettingsView()
                .environment(appSettings)
                .frame(maxWidth: 400, maxHeight: 200)
        }
    }
}
