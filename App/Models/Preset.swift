// import Foundation
// import SwiftData

// @Model
// final class Preset {
//     var id: UUID
//     var name: String
//     var prompt: String
//     var model: String
//     var provider: String
//     var lastModified: Date

//     init(name: String, prompt: String, model: String, provider: String) {
//         id = UUID()
//         self.name = name
//         self.prompt = prompt
//         self.model = model
//         self.provider = provider
//         lastModified = .now
//     }

//     var asSendable: PresetSendable {
//         PresetSendable(name: name, prompt: prompt, model: model, provider: provider)
//     }
// }

// struct PresetSendable: Sendable {
//     let name: String
//     let prompt: String
//     let model: String
//     let provider: String
// }

// let DEFAULT_PRESET = Preset(
//     name: "Default",
//     prompt: "You are a helpful assistant.",
//     model: "gpt-4o",
//     provider: "OpenAI"
// ).asSendable
