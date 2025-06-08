import SwiftUI

struct RecordingView: View {
    @Environment(RecordingManager.self) var recordingManager

    var body: some View {
        VStack(spacing: 20) {
            Text(String(format: "%.2f", recordingManager.elapsedTime))
                .font(.system(size: 40, weight: .light, design: .monospaced))

            Button(action: {
                Task { await recordingManager.toggleRecording() }
            }) {
                Text(recordingManager.isRecording ? "Stop Recording" : "Start Recording")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 200)
                    .background(recordingManager.isRecording ? Color.red : Color.blue)
                    .cornerRadius(12)
            }

            Text(recordingManager.rawResult)
            Text(recordingManager.processedResult)
        }
        .padding()
    }
}

#Preview {
    let recordingManager = RecordingManager()

    RecordingView()
        .environment(recordingManager)
}
