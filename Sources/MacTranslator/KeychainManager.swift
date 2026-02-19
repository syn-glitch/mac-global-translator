import Foundation
import Security

struct KeychainManager {
    private static let service = "com.syn.mac-translator"
    private static let defaultAccount = "claude-api-key"
    private static let openAIAccount = "openai_api_key"

    /// Save API key to Keychain
    static func saveAPIKey(_ key: String, for account: String = defaultAccount) -> Bool {
        guard let data = key.data(using: .utf8) else { return false }

        // Delete existing entry first
        deleteAPIKey(for: account)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked,
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    /// Retrieve API key from Keychain
    static func getAPIKey(for account: String = defaultAccount) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let key = String(data: data, encoding: .utf8) else {
            return nil
        }
        return key
    }

    /// Delete API key from Keychain
    @discardableResult
    static func deleteAPIKey(for account: String = defaultAccount) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

    /// Check if Claude API key exists
    static var hasAPIKey: Bool {
        return getAPIKey(for: defaultAccount) != nil
    }

    /// Check if OpenAI API key exists
    static var hasOpenAIKey: Bool {
        return getAPIKey(for: openAIAccount) != nil
    }
    
    // Helpers for specific keys
    static func saveOpenAIKey(_ key: String) -> Bool {
        return saveAPIKey(key, for: openAIAccount)
    }
    
    static func getOpenAIKey() -> String? {
        return getAPIKey(for: openAIAccount)
    }
}
