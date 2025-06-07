import SwiftUI

@MainActor
@Observable
class SettingsApiKeysViewModel {
    let apiKeyService = ApiKeysService()

    var apiKeys: [ApiKeyAccount: String] = [:]

    func loadKeys() async {
        for account in ApiKeyAccount.allCases {
            apiKeys[account] = await apiKeyService.getAPIKey(for: account) ?? ""
        }
    }

    func apiKeyBinding(for account: ApiKeyAccount) -> Binding<String> {
        Binding(
            get: { self.apiKeys[account, default: ""] },
            set: { newValue in
                self.apiKeys[account] = newValue
                Task {
                    await self.apiKeyService.saveAPIKey(newValue, for: account)
                }
            }
        )
    }
}

struct SettingsApiKeysView: View {
    @State private var viewModel = SettingsApiKeysViewModel()

    var body: some View {
        Form {
            Section {
                ForEach(ApiKeyAccount.allCases) { account in
                    SecureField(account.userFacingName, text: viewModel.apiKeyBinding(for: account))
                }
            }
        }
        .formStyle(.grouped)
        .task {
            await viewModel.loadKeys()
        }
    }
}

#Preview {
    SettingsApiKeysView()
}
