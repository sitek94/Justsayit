import Foundation
import OpenAI

// MARK: - Processing Errors

enum ProcessingError: LocalizedError {
    case apiKeyMissing
    case networkError(String)
    case apiError(String)
    case noResult

    var errorDescription: String? {
        switch self {
        case .apiKeyMissing:
            "API key is missing. Please add it to your environment variables."
        case let .networkError(message):
            "Network error: \(message)"
        case let .apiError(message):
            "API error: \(message)"
        case .noResult:
            "The API returned no result."
        }
    }
}

// MARK: - Processing Service Protocol

protocol ProcessingService: Actor {
    init(apiKeysService: ApiKeysService)
    func process(text: String) async throws -> String
}

// MARK: - OpenAI Processing Service

actor OpenAIProcessingService: ProcessingService {
    private let apiKeysService: ApiKeysService

    init(apiKeysService: ApiKeysService) {
        self.apiKeysService = apiKeysService
    }

    // TODO: dynamic system prompt and model
    private let systemPrompt = """
    You are a helpful assistant that processes raw speech-to-text transcription.
    Your goal is to fix any punctuation, spelling, and grammatical errors, and make the text more readable, but without changing the original meaning.
    The user will provide the raw text.
    Do not add any extra comments, just return the processed text.
    """

    func process(text: String) async throws -> String {
        guard let apiKey = await apiKeysService.getAPIKey(for: .openAI) else {
            throw ProcessingError.apiKeyMissing
        }

        let openAI = OpenAI(apiToken: apiKey)

        let query = ChatQuery(
            messages: [
                .init(role: .system, content: systemPrompt),
                .init(role: .user, content: text),
            ].compactMap(\.self),
            model: Model.gpt4_1_mini
        )

        do {
            let result = try await openAI.chats(query: query)
            guard let processedText = result.choices.first?.message.content else {
                throw ProcessingError.noResult
            }
            return processedText
        } catch {
            if let urlError = error as? URLError {
                throw ProcessingError.networkError(urlError.localizedDescription)
            } else {
                throw ProcessingError.apiError(error.localizedDescription)
            }
        }
    }
}
