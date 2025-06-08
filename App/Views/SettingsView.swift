import SwiftUI

@MainActor
@Observable
class SettingsViewModel {
    private let apiKeyService: ApiKeysService

    init(apiKeyService: ApiKeysService = DefaultApiKeysService()) {
        self.apiKeyService = apiKeyService
    }

    var apiKeys: [ApiKey.Provider: String] = [:]

    func loadKeys() async {
        for provider in ApiKey.Provider.allCases {
            apiKeys[provider] = await apiKeyService.getAPIKey(for: provider) ?? ""
        }
    }

    func apiKeyBinding(for provider: ApiKey.Provider) -> Binding<String> {
        Binding(
            get: { self.apiKeys[provider, default: ""] },
            set: { newValue in
                self.apiKeys[provider] = newValue
                Task {
                    await self.apiKeyService.saveAPIKey(newValue, for: provider)
                }
            }
        )
    }
}

struct SettingsView: View {
    @State var viewModel: SettingsViewModel

    var body: some View {
        Form {
            Section {
                ForEach(ApiKey.Provider.allCases) { provider in
                    SecureField(provider.userFacingName, text: viewModel.apiKeyBinding(for: provider))
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
    let viewModel = SettingsViewModel(apiKeyService: DefaultApiKeysService())

    NavigationStack {
        SettingsView(viewModel: viewModel)
    }
}
