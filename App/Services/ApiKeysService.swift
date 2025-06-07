import Foundation
import Observation

actor ApiKeysService {
    private let keychainManager: KeychainManager

    init() {
        guard let bundleID = Bundle.main.bundleIdentifier else {
            fatalError("Unable to determine bundle identifier. Keychain service cannot be scoped.")
        }
        keychainManager = KeychainManager(service: bundleID)
    }

    func saveAPIKey(_ key: String, for account: ApiKeyAccount) {
        do {
            try keychainManager.save(
                password: key,
                account: account.keychainAccountName
            )
        } catch {
            // TODO: Handle errors
            print("Failed to save API key for \(account.userFacingName): \(error)")
        }
    }

    func getAPIKey(for account: ApiKeyAccount) -> String? {
        keychainManager.retrievePassword(account: account.keychainAccountName)
    }

    func deleteAPIKey(for account: ApiKeyAccount) {
        do {
            try keychainManager.delete(account: account.keychainAccountName)
        } catch {
            // TODO: Handle errors
            print("Failed to delete API key for \(account.userFacingName): \(error)")
        }
    }
}
