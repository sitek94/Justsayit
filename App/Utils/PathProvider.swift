import Foundation

enum PathProvider {
    private static let appDirectory = "justsayit"
    private static let recordingsDirectory = "recordings"

    static func getAppDirectory() throws -> URL {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw NSError(
                domain: "PathProvider",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Could not find Documents directory."]
            )
        }

        let appDirectoryURL = documentsURL.appendingPathComponent(appDirectory)

        try FileManager.default.createDirectory(at: appDirectoryURL, withIntermediateDirectories: true, attributes: nil)

        return appDirectoryURL
    }

    static func getRecordingsDirectory() throws -> URL {
        let appDirectoryURL = try getAppDirectory()
        let recordingsDirectoryURL = appDirectoryURL.appendingPathComponent(recordingsDirectory)

        try FileManager.default.createDirectory(
            at: recordingsDirectoryURL,
            withIntermediateDirectories: true,
            attributes: nil
        )

        return recordingsDirectoryURL
    }
}
