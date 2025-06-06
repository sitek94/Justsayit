import Combine
import Sparkle
import SwiftUI

@MainActor @Observable
final class UpdaterService {
    let updater: SPUUpdater
    private let updaterController: SPUStandardUpdaterController

    var canCheckForUpdates = false

    private var cancellables = Set<AnyCancellable>()

    init() {
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
        updater = updaterController.updater

        updater.publisher(for: \.canCheckForUpdates)
            .sink { [weak self] canCheck in
                self?.canCheckForUpdates = canCheck
            }
            .store(in: &cancellables)
    }

    func checkForUpdates() {
        updater.checkForUpdates()
    }
}
