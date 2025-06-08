import Foundation

enum AppConfig {
    
    // MARK: - Application Info

    static let appName: String = "Justsayit"

    static let bundleId: String = {
        guard let id = Bundle.main.bundleIdentifier else {
            fatalError("Unable to determine bundle identifier.")
        }
        return id
    }()

    static let appVersion: String = {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return "N/A"
        }
        return version
    }()

    // MARK: - URLs

    enum URLs {
        static let githubRepository = URL(string: "https://github.com/sitek94/Justsayit")!
    }
}
