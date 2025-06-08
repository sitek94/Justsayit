import Foundation
import Observation

actor ApiKeysService {
    private let keychainService: KeychainService

    init(keychainService: KeychainService = KeychainService(service: AppConfig.bundleId)) {
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
