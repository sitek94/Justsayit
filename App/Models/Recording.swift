import Foundation

struct Recording: Codable, Identifiable {
    let id: UUID
    let createdAt: Date
    let audioFileURL: URL
    let duration: TimeInterval

    var rawResult: String?
    var result: String?
    var prompt: String?

    // You can add a default initializer for convenience
    init(id: UUID = UUID(),
         audioFileURL: URL,
         duration: TimeInterval,
         createdAt: Date = Date(),
         rawResult: String? = nil,
         result: String? = nil,
         prompt: String? = nil) {
        self.id = id
        self.audioFileURL = audioFileURL
        self.duration = duration
        self.createdAt = createdAt
        self.rawResult = rawResult
        self.result = result
        self.prompt = prompt
    }
}
