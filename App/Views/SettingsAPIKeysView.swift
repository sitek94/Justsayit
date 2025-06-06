import SwiftUI

@MainActor
@Observable
class SettingsAPIKeysViewModel {
    let settingsService: SettingsService

    init(settingsService: SettingsService) {
        self.settingsService = settingsService
    }

    var apiKeys: [APIKeyAccount: String] = [:]

    func loadKeys() {
        for account in APIKeyAccount.allCases {
            apiKeys[account] = settingsService.getAPIKey(for: account) ?? ""
        }
    }

    func apiKeyBinding(for account: APIKeyAccount) -> Binding<String> {
        Binding(
            get: { self.apiKeys[account, default: ""] },
            set: { newValue in
                self.apiKeys[account] = newValue
                self.settingsService.saveAPIKey(newValue, for: account)
            }
        )
    }
}

struct SettingsAPIKeysView: View {
    let settingsService: SettingsService
    @State private var viewModel: SettingsAPIKeysViewModel

    init(settingsService: SettingsService) {
        self.settingsService = settingsService
        viewModel = SettingsAPIKeysViewModel(settingsService: settingsService)
    }

    var body: some View {
        Form {
            Section {
                ForEach(APIKeyAccount.allCases) { account in
                    SecureField(account.userFacingName, text: viewModel.apiKeyBinding(for: account))
                }
            }
        }
        .formStyle(.grouped)
        .onAppear(perform: viewModel.loadKeys)
    }
}

#Preview {
    @State @Previewable var settingsService = SettingsService()

    SettingsAPIKeysView(settingsService: settingsService)
}
