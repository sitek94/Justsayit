import Foundation
import os

private let logger = Logger.make(category: "RecordingStorageService")

actor RecordingStorageService {
    private let metadataFileName = "metadata.json"
    private let recordingFileName = "recording.wav"

    private let pathProvider = PathProvider()
    private let fileManager = FileManager.default

    func save(temporaryURL: URL, duration: TimeInterval, prompt: String) async throws -> Recording {
        logger.info("Attempting to save new recording...")

        do {
            let recordingsDirectory = try pathProvider.getRecordingsDirectory()
            logger.debug("Base recordings directory: \(recordingsDirectory.path)")

            let id = UUID()
            let recordingDirectory = recordingsDirectory.appendingPathComponent(id.uuidString)
            try fileManager.createDirectory(at: recordingDirectory, withIntermediateDirectories: true)
            logger.debug("Created new recording directory: \(recordingDirectory.path)")

            let permanentAudioURL = recordingDirectory.appendingPathComponent(recordingFileName)
            try fileManager.moveItem(at: temporaryURL, to: permanentAudioURL)
            logger.debug("Moved audio file to: \(permanentAudioURL.path)")

            let recording = Recording(
                id: id,
                audioFileURL: permanentAudioURL,
                duration: duration,
                createdAt: Date(),
                prompt: prompt
            )

            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let metadata = try encoder.encode(recording)
            logger.debug("Encoded metadata for recording ID \(id.uuidString)")

            let metadataURL = recordingDirectory.appendingPathComponent(metadataFileName)
            try metadata.write(to: metadataURL)
            logger.debug("Saved metadata to: \(metadataURL.path)")

            logger.info("✅ Recording saved successfully. ID: \(id.uuidString)")
            return recording
        } catch {
            logger.error("Failed to save recording: \(error.localizedDescription)")
            throw error
        }
    }

    func fetchAllRecordings() async throws -> [Recording] {
        logger.info("Attempting to fetch all recordings...")

        do {
            let recordingsDirectory = try pathProvider.getRecordingsDirectory()
            logger.debug("Base recordings directory: \(recordingsDirectory.path)")

            let recordingSubdirectories = try fileManager.contentsOfDirectory(
                at: recordingsDirectory,
                includingPropertiesForKeys: nil,
                options: .skipsHiddenFiles
            )
            logger.debug("Found \(recordingSubdirectories.count) items in the recordings directory.")

            var recordings: [Recording] = []
            let decoder = JSONDecoder()

            for directory in recordingSubdirectories {
                logger.debug("Processing item: \(directory.lastPathComponent)")
                let metadataURL = directory.appendingPathComponent(metadataFileName)

                guard fileManager.fileExists(atPath: metadataURL.path) else {
                    logger.debug("Skipping item \(directory.lastPathComponent) as it has no metadata file.")
                    continue
                }

                do {
                    let data = try Data(contentsOf: metadataURL)
                    let recording = try decoder.decode(Recording.self, from: data)
                    recordings.append(recording)
                } catch {
                    logger.error(
                        "Failed to decode metadata for recording at \(directory.lastPathComponent): \(error.localizedDescription)"
                    )
                }
            }

            recordings.sort { $0.createdAt > $1.createdAt }

            logger.info("✅ Successfully fetched and decoded \(recordings.count) recordings.")
            return recordings

        } catch {
            logger.error("Could not fetch recordings. A top-level error occurred: \(error.localizedDescription)")
            throw error
        }
    }
}
