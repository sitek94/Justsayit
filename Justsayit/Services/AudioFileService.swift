import Foundation

// MARK: - File Management Error Types
enum AudioFileError: Error, LocalizedError {
    case directoryNotFound
    case fileNotFound
    case deletionFailed(String)
    case loadingFailed(String)
    case urlCreationFailed
    
    var errorDescription: String? {
        switch self {
        case .directoryNotFound:
            return "Documents directory not found"
        case .fileNotFound:
            return "Audio file not found"
        case .deletionFailed(let reason):
            return "Failed to delete file: \(reason)"
        case .loadingFailed(let reason):
            return "Failed to load recordings: \(reason)"
        case .urlCreationFailed:
            return "Failed to create file URL"
        }
    }
}

// MARK: - Audio Recording Model
struct AudioRecording: Sendable {
    let url: URL
    let name: String
    let date: Date
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var displayName: String {
        name.replacingOccurrences(of: "_", with: " ").capitalized
    }
}

// MARK: - File Management Actor
actor AudioFileService {
    private let documentsDirectory: URL
    private let fileExtension = "wav"
    
    init() {
        self.documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                    ?? FileManager.default.temporaryDirectory.appendingPathComponent("Justsayit")
    }
    
    // MARK: - File URL Generation
    func createRecordingURL() -> URL {
        let fileName = "recording_\(Date().timeIntervalSince1970).\(fileExtension)"
        return documentsDirectory.appendingPathComponent(fileName)
    }
    
    // MARK: - Loading Recordings
    func loadRecordings() async throws -> [AudioRecording] {
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: documentsDirectory,
                includingPropertiesForKeys: [.creationDateKey],
                options: .skipsHiddenFiles
            )
            
            let audioFiles = fileURLs.filter { url in
                url.pathExtension.lowercased() == fileExtension
            }
            
            let recordings = audioFiles.compactMap { url -> AudioRecording? in
                do {
                    let resourceValues = try url.resourceValues(forKeys: [.creationDateKey])
                    let creationDate = resourceValues.creationDate ?? Date()
                    let fileName = url.deletingPathExtension().lastPathComponent
                    
                    return AudioRecording(
                        url: url,
                        name: fileName,
                        date: creationDate
                    )
                } catch {
                    print("Error getting file attributes for \(url): \(error)")
                    return nil
                }
            }
            
            return recordings.sorted { $0.date > $1.date } // Newest first
            
        } catch {
            throw AudioFileError.loadingFailed(error.localizedDescription)
        }
    }
    
    // MARK: - File Deletion
    func deleteRecording(at url: URL) async throws {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            throw AudioFileError.deletionFailed(error.localizedDescription)
        }
    }
    
    func deleteRecordings(at urls: [URL]) async throws {
        for url in urls {
            try await deleteRecording(at: url)
        }
    }
    
    // MARK: - File Information
    func getFileSize(for url: URL) throws -> Int64 {
        let resourceValues = try url.resourceValues(forKeys: [.fileSizeKey])
        return Int64(resourceValues.fileSize ?? 0)
    }
    
    func fileExists(at url: URL) -> Bool {
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    // MARK: - Directory Management
    func getDocumentsDirectory() -> URL {
        return documentsDirectory
    }
    
    func getTotalStorageUsed() async throws -> Int64 {
        let recordings = try await loadRecordings()
        var totalSize: Int64 = 0
        
        for recording in recordings {
            do {
                let size = try getFileSize(for: recording.url)
                totalSize += size
            } catch {
                // Continue counting other files if one fails
                continue
            }
        }
        
        return totalSize
    }
    
    // MARK: - Utility Methods
    func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}
