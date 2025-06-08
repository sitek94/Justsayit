import Foundation

enum ApiKey {
    enum Provider: String, CaseIterable {
        case openAI
        case groq
        case gemini
        case anthropic

        var userFacingName: String {
            switch self {
            case .openAI: "OpenAI"
            case .groq: "Groq"
            case .gemini: "Gemini"
            case .anthropic: "Anthropic"
            }
        }

//        var keychainAccountName: String {
//            "\(AppConfig.bundleId).\(rawValue)"
//        }

        // TODO: Temporarily hardcoded for testing, remove once it's possible to edit the keychain
        // in the settings
        var keychainAccountName: String {
            switch self {
            case .openAI: "OPENAI_API_KEY"
            case .groq: "GROQ_API_KEY"
            case .gemini: "GEMINI_API_KEY"
            case .anthropic: "ANTHROPIC_API_KEY"
            }
        }
    }
}
