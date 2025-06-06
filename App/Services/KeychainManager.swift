import Foundation
import Security

enum KeychainError: Error {
    case unhandledError(status: OSStatus)
    case itemNotFound
    case invalidData
    case duplicateItem
}

class KeychainManager {
    private let service: String

    init(service: String) {
        self.service = service
    }

    /// Securely saves or updates a piece of data in the keychain for a specific account.
    ///
    /// This function performs an "upsert" by first deleting any existing item for the
    /// given account and then adding the new one. This simplifies the API by not
    /// requiring the caller to know if an item already exists.
    func save(passwordData: Data, account: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]

        // To perform an "upsert", we first delete any existing item.
        // The result is ignored because the item may not exist, which is not an error for this operation.
        SecItemDelete(query as CFDictionary)

        var addQuery = query
        addQuery[kSecValueData as String] = passwordData

        let status = SecItemAdd(addQuery as CFDictionary, nil)

        // A status of `errSecDuplicateItem` should not be possible here because we just deleted the item.
        // We only need to check for success.
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
    }

    func retrieve(account: String) throws -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        if status == errSecItemNotFound {
            return nil
        }
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
        guard let data = item as? Data else {
            throw KeychainError.invalidData
        }
        return data
    }

    func delete(account: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
        let status = SecItemDelete(query as CFDictionary)

        // Deleting an item that does not exist is considered a success state,
        // so we accept `errSecItemNotFound` in addition to `errSecSuccess`.
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unhandledError(status: status)
        }
    }

    // Convenience for String
    func save(password: String, account: String) throws {
        guard let data = password.data(using: .utf8) else { throw KeychainError.invalidData }
        try save(passwordData: data, account: account)
    }

    func retrievePassword(account: String) -> String? {
        do {
            guard let data = try retrieve(account: account) else { return nil }
            return String(data: data, encoding: .utf8)
        } catch {
            print("Keychain retrieve error: \(error)")
            return nil
        }
    }
}
