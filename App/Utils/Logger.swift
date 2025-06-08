import Foundation
import os

enum Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.macieksitkowski.Justsayit"

    static func make(category: String) -> os.Logger {
        os.Logger(subsystem: subsystem, category: category)
    }
}
