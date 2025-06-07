import Foundation

enum ApiKeyAccount: String, CaseIterable, Identifiable {
    case openAI
    case groq
    case gemini
    case anthropic

    var id: String { rawValue }

    var userFacingName: String {
        switch self {
        case .openAI: "OpenAI"
        case .groq: "Groq"
        case .gemini: "Gemini"
        case .anthropic: "Anthropic"
        }
    }

    var keychainAccountName: String {
        switch self {
        case .openAI: "OPENAI_API_KEY"
        case .groq: "GROQ_API_KEY"
        case .gemini: "GEMINI_API_KEY"
        case .anthropic: "ANTHROPIC_API_KEY"
        }
    }
}
