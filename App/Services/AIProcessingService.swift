import Foundation

protocol AIProcessingService: Actor {
    func process(_ input: String, with preset: PresetSendable) -> String
}

actor OpenAIProcessingService: AIProcessingService {
    private let apiKeysService = ApiKeysService()

    func process(_ input: String, with _: PresetSendable) -> String {
        input
    }
}
