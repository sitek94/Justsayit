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
    init(apiKeysService: ApiKeysService)
    func transcribe(audioURL: URL) async throws -> String
}

// MARK: - OpenAI Transcription Service

actor OpenAITranscriptionService: TranscriptionService {
    private let apiKeysService: ApiKeysService

    init(apiKeysService: ApiKeysService) {
        self.apiKeysService = apiKeysService
    }

    func transcribe(audioURL: URL) async throws -> String {
        guard let apiKey = await apiKeysService.getAPIKey(for: .openAI) else {
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
