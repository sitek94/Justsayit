import SwiftUI

struct DebugView: View {
    private let clipboardService: ClipboardService = DefaultClipboardService()

    @State private var output: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Debug")
                .font(.title2)

            Button("Paste at cursor") {
                Task {
                    do {
                        try await Task.sleep(for: .seconds(2))
                        try clipboardService.pasteAtCursor("Hello, world!")
                        appendOutput("✅ Paste at cursor succeeded")
                    } catch {
                        appendOutput("❌ Error: \(String(describing: error))")
                    }
                }
            }

            ScrollView {
                Text(output.isEmpty ? "No output yet." : output)
                    .font(.system(.body, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            .frame(minHeight: 120, maxHeight: 200)
        }
        .padding()
    }

    private func appendOutput(_ text: String) {
        if !output.isEmpty {
            output += "\n"
        }
        output += text
    }
}

#Preview {
    DebugView()
}
