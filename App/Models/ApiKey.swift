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

        var keychainAccountName: String {
            "\(AppConfig.bundleId).\(self.rawValue)"
        }
    }
}