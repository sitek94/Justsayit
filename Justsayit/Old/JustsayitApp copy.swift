////
////  JustsayitApp.swift
////  Justsayit
////
////  Created by Maciej Sitkowski on 29/05/2025.
////
//
//import SwiftUI
//import HotKey
//
//struct OldJustsayitApp: App {
//    @State private var audioManager = AudioRecordingManager()
//    @State private var whisperClient = WhisperAPIClient()
//    
//    // Global hotkey for recording toggle
//    private let hotKey = HotKey(key: .space, modifiers: [.command, .shift])
//    
//    var body: some Scene {
//        WindowGroup {
//            OldContentView(whisperClient: whisperClient)
//                .environmentObject(audioManager)
//                .frame(minWidth: 400, minHeight: 300)
//                .onAppear {
//                    setupGlobalShortcut()
//                }
//        }
//        .windowStyle(.hiddenTitleBar)
//        .windowResizability(.contentSize)
//    }
//    
//    private func setupGlobalShortcut() {
//        hotKey.keyDownHandler = {
//            audioManager.toggleRecording()
//        }
//    }
//}
