import Foundation
import Observation

protocol ApiKeysService: Actor {
    init(keychainService: KeychainService)
    func saveAPIKey(_ key: String, for provider: ApiKey.Provider)
    func getAPIKey(for provider: ApiKey.Provider) -> String?
    func deleteAPIKey(for provider: ApiKey.Provider)
}

actor DefaultApiKeysService: ApiKeysService {
    private let keychainService: KeychainService

    init(keychainService: KeychainService = DefaultKeychainService(service: AppConfig.bundleId)) {
        self.keychainService = keychainService
    }

    func saveAPIKey(_ key: String, for provider: ApiKey.Provider) {
        do {
            try keychainService.save(
                password: key,
                account: provider.keychainAccountName
            )
        } catch {
            // TODO: Handle errors
            print("Failed to save API key for \(provider.userFacingName): \(error)")
        }
    }

    func getAPIKey(for provider: ApiKey.Provider) -> String? {
        keychainService.retrievePassword(account: provider.keychainAccountName)
    }

    func deleteAPIKey(for provider: ApiKey.Provider) {
        do {
            try keychainService.delete(account: provider.keychainAccountName)
        } catch {
            // TODO: Handle errors
            print("Failed to delete API key for \(provider.userFacingName): \(error)")
        }
    }
}
