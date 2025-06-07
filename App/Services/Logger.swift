import Foundation
import os.log

enum Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.justsayit.default"

    private static func logger(for category: String) -> os.Logger {
        os.Logger(subsystem: subsystem, category: category)
    }

    static func info(_ message: String, category: String = "App") {
        logger(for: category).info("\(message, privacy: .public)")
    }

    static func debug(_ message: String, category: String = "App") {
        #if DEBUG
            logger(for: category).debug("\(message, privacy: .public)")
        #endif
    }

    static func error(_ error: Error, category: String = "Error") {
        logger(for: category).error(
            "Caught an error: \(error.localizedDescription, privacy: .public). Full details: \(String(describing: error), privacy: .private)"
        )
    }

    static func error(_ message: String, category: String = "Error") {
        logger(for: category).error("\(message, privacy: .public)")
    }
}
