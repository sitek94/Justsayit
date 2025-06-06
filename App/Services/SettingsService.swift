import Foundation
import Observation

@Observable
class SettingsService {
    // MARK: - Properties

    private let keychainManager: KeychainManager

    // MARK: - Initialization

    init() {
        guard let bundleID = Bundle.main.bundleIdentifier else {
            fatalError("Unable to determine bundle identifier. Keychain service cannot be scoped.")
        }
        // Initialize the manager for our app's specific service
        keychainManager = KeychainManager(service: bundleID)
    }

    // MARK: - API Key Management

    func saveAPIKey(_ key: String, for account: APIKeyAccount) {
        do {
            try keychainManager.save(
                password: key,
                account: account.keychainAccountName
            )
        } catch {
            print("Failed to save API key for \(account.userFacingName): \(error)")
            // TODO: Handle error appropriately in UI if needed
        }
    }

    func getAPIKey(for account: APIKeyAccount) -> String? {
        keychainManager.retrievePassword(account: account.keychainAccountName)
    }

    func deleteAPIKey(for account: APIKeyAccount) {
        do {
            try keychainManager.delete(account: account.keychainAccountName)
        } catch {
            print("Failed to delete API key for \(account.userFacingName): \(error)")
        }
    }
}
