import SwiftUI

struct RecordingVisualizer: View {
    let state: RecordingState

    var body: some View {
        Rectangle()
            .fill(fillColor)
            .overlay {
                VStack(spacing: 4) {
                    Text(title)
                        .font(.title2)
                        .foregroundColor(.secondary)

                    if !description.isEmpty {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .animation(.easeInOut(duration: 0.3), value: state)
    }

    private var fillColor: Color {
        switch state {
        case .idle: .gray.opacity(0.2)
        case .recording: .red.opacity(0.3)
        case .transcribing: .blue.opacity(0.3)
        case .processing: .orange.opacity(0.3)
        case .outputting: .green.opacity(0.3)
        case .error: .red.opacity(0.5)
        }
    }

    private var title: String {
        switch state {
        case .idle: "Ready"
        case .recording: "🎤 Recording..."
        case .transcribing: "🧠 Transcribing..."
        case .processing, .outputting: "⚙️ Processing..."
        case .error: "❌ Error"
        }
    }

    private var description: String {
        switch state {
        case let .error(error):
            error.localizedDescription
        default:
            ""
        }
    }
}
