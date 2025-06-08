import Foundation
import OpenAI

// MARK: - Transcription Errors

enum TranscriptionError: LocalizedError {
    case failedToLoadAudioFile
    case apiKeyMissing
    case invalidAudioFormat
    case networkError(String)
    case apiError(String)

    var errorDescription: String? {
        switch self {
        case .failedToLoadAudioFile:
            "Failed to load audio file"
        case .apiKeyMissing:
            "API key is missing. Please add it to TranscriptionService.swift"
        case .invalidAudioFormat:
            "Invalid audio format. Supported formats: m4a, mp3, wav, webm"
        case let .networkError(message):
            "Network error: \(message)"
        case let .apiError(message):
            "API error: \(message)"
        }
    }
}

// MARK: - Transcription Service Protocol

protocol TranscriptionService: Actor {
    func transcribe(audioURL: URL) async throws -> String
}

// MARK: - OpenAI Transcription Service

actor OpenAITranscriptionService: TranscriptionService {
    // TODO: API Key from keychain
    private let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""

    func transcribe(audioURL: URL) async throws -> String {
        guard !apiKey.isEmpty else {
            throw TranscriptionError.apiKeyMissing
        }
        guard let audioData = try? Data(contentsOf: audioURL) else {
            throw TranscriptionError.failedToLoadAudioFile
        }
        guard let fileType = AudioTranscriptionQuery.FileType(rawValue: audioURL.pathExtension.lowercased()) else {
            throw TranscriptionError.invalidAudioFormat
        }

        let openAI = OpenAI(apiToken: apiKey)
        
        let query = AudioTranscriptionQuery(
            file: audioData,
            fileType: fileType,
            model: .whisper_1
        )

        do {
            let result = try await openAI.audioTranscriptions(query: query)
            return result.text
        } catch {
            if let urlError = error as? URLError {
                throw TranscriptionError.networkError(urlError.localizedDescription)
            } else {
                throw TranscriptionError.apiError(error.localizedDescription)
            }
        }
    }
}
