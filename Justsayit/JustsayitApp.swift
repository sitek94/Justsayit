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
        WindowGroup {
            ContentView()
                .frame(minWidth: 400, minHeight: 300)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)

        Settings {
            SettingsView()
                .environment(appSettings)
                .frame(maxWidth: 400, maxHeight: 200)
        }
    }
}
