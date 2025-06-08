import Foundation

enum ApiKey {
    enum Provider: String, CaseIterable, Identifiable {
        case openAI
        case groq
        case gemini
        case anthropic

        var id: Self { self }

        var userFacingName: String {
            switch self {
            case .openAI: "OpenAI"
            case .groq: "Groq"
            case .gemini: "Gemini"
            case .anthropic: "Anthropic"
            }
        }

        var keychainAccountName: String {
            "\(AppConfig.bundleId).\(id)"
        }
    }
}
