import Foundation
import OpenAI

// MARK: - Transcription Errors

enum TranscriptionError: LocalizedError {
    case failedToLoadAudioFile
    case invalidAudioFormat
    case apiKeyMissing
    case networkError(String)
    case apiError(String)

    var errorDescription: String? {
        switch self {
        case .failedToLoadAudioFile:
            "Failed to load audio file"
        case .invalidAudioFormat:
            "Invalid audio format. Supported formats: m4a, mp3, wav, webm"
        case .apiKeyMissing:
            "API key is missing"
        case let .networkError(message):
            "Network error: \(message)"
        case let .apiError(message):
            "API error: \(message)"
        }
    }
}

// MARK: - Transcription Service Protocol

protocol TranscriptionService: Sendable {
    func transcribe(audioURL: URL) async throws -> String
}

// MARK: - OpenAI Transcription Service

actor OpenAITranscriptionService: TranscriptionService {
    private let openAI: OpenAI

    init(apiKey: String) {
        openAI = OpenAI(apiToken: apiKey)
    }

    func transcribe(audioURL: URL) async throws -> String {
        guard
            let fileType = AudioTranscriptionQuery.FileType(
                rawValue: audioURL.pathExtension.lowercased()
            )
        else {
            throw TranscriptionError.invalidAudioFormat
        }

        guard let audioData = try? Data(contentsOf: audioURL) else {
            throw TranscriptionError.failedToLoadAudioFile
        }

        let query = AudioTranscriptionQuery(
            file: audioData,
            fileType: fileType,
            model: .whisper_1
        )

        do {
            let result = try await openAI.audioTranscriptions(query: query)
            return result.text
        } catch {
            // Map errors to our domain-specific errors
            if let urlError = error as? URLError {
                throw TranscriptionError.networkError(urlError.localizedDescription)
            } else {
                throw TranscriptionError.apiError(error.localizedDescription)
            }
        }
    }
}
