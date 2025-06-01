//import SwiftUI
//
//struct AudioVisualizationView: View {
//    @ObservedObject var audioManager: AudioRecordingManager
//    
//    var body: some View {
//        HStack(alignment: .bottom, spacing: 2) {
//            ForEach(0..<audioManager.audioLevels.count, id: \.self) { index in
//                AudioBarView(
//                    level: audioManager.audioLevels[index],
//                    isRecording: audioManager.isRecording
//                )
//            }
//        }
//        .frame(height: 100)
//        .padding(.horizontal)
//        .background(
//            RoundedRectangle(cornerRadius: 8)
//                .fill(Color.black.opacity(0.1))
//        )
//        .overlay(
//            RoundedRectangle(cornerRadius: 8)
//                .stroke(
//                    audioManager.isRecording ? Color.red : Color.gray,
//                    lineWidth: 2
//                )
//        )
//    }
//}
//
//struct AudioBarView: View {
//    let level: Float
//    let isRecording: Bool
//    
//    @State private var animatedHeight: CGFloat = 0
//    
//    var body: some View {
//        RoundedRectangle(cornerRadius: 1)
//            .fill(
//                LinearGradient(
//                    colors: gradientColors,
//                    startPoint: .bottom,
//                    endPoint: .top
//                )
//            )
//            .frame(width: 3, height: animatedHeight)
//            .animation(.easeInOut(duration: 0.1), value: animatedHeight)
//            .onAppear {
//                updateHeight()
//            }
//            .onChange(of: level) { _, _ in
//                updateHeight()
//            }
//    }
//    
//    private var gradientColors: [Color] {
//        if isRecording {
//            return [.green, .yellow, .orange, .red]
//        } else {
//            return [.gray.opacity(0.3), .gray.opacity(0.6)]
//        }
//    }
//    
//    private func updateHeight() {
//        let baseHeight: CGFloat = 4
//        let maxHeight: CGFloat = 80
//        let scaledLevel = CGFloat(level)
//        animatedHeight = baseHeight + (scaledLevel * (maxHeight - baseHeight))
//    }
//}
//
//// MARK: - Alternative Waveform Visualization
//struct WaveformVisualizationView: View {
//    @ObservedObject var audioManager: AudioRecordingManager
//    
//    var body: some View {
//        Canvas { context, size in
//            let path = createWaveformPath(size: size)
//            
//            context.stroke(
//                path,
//                with: .color(audioManager.isRecording ? .red : .blue),
//                lineWidth: 2
//            )
//        }
//        .frame(height: 100)
//        .background(Color.black.opacity(0.05))
//        .clipShape(RoundedRectangle(cornerRadius: 8))
//    }
//    
//    private func createWaveformPath(size: CGSize) -> Path {
//        var path = Path()
//        
//        let stepWidth = size.width / CGFloat(audioManager.audioLevels.count - 1)
//        let midY = size.height / 2
//        
//        for (index, level) in audioManager.audioLevels.enumerated() {
//            let x = CGFloat(index) * stepWidth
//            let amplitude = CGFloat(level) * (midY * 0.8)
//            let y = midY - amplitude
//            
//            if index == 0 {
//                path.move(to: CGPoint(x: x, y: y))
//            } else {
//                path.addLine(to: CGPoint(x: x, y: y))
//            }
//        }
//        
//        // Mirror the waveform below the center line
//        for (index, level) in audioManager.audioLevels.enumerated().reversed() {
//            let x = CGFloat(index) * stepWidth
//            let amplitude = CGFloat(level) * (midY * 0.8)
//            let y = midY + amplitude
//            
//            path.addLine(to: CGPoint(x: x, y: y))
//        }
//        
//        path.closeSubpath()
//        
//        return path
//    }
//}
//
//// MARK: - Circular Audio Meter
//struct CircularAudioMeterView: View {
//    @ObservedObject var audioManager: AudioRecordingManager
//    
//    private var averageLevel: Float {
//        let sum = audioManager.audioLevels.reduce(0, +)
//        return sum / Float(audioManager.audioLevels.count)
//    }
//    
//    var body: some View {
//        ZStack {
//            // Background circle
//            Circle()
//                .stroke(Color.gray.opacity(0.3), lineWidth: 8)
//                .frame(width: 80, height: 80)
//            
//            // Level indicator circle
//            Circle()
//                .trim(from: 0, to: CGFloat(averageLevel))
//                .stroke(
//                    audioManager.isRecording ? Color.red : Color.blue,
//                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
//                )
//                .frame(width: 80, height: 80)
//                .rotationEffect(.degrees(-90))
//                .animation(.easeInOut(duration: 0.2), value: averageLevel)
//            
//            // Center indicator
//            Circle()
//                .fill(audioManager.isRecording ? Color.red : Color.gray)
//                .frame(width: 12, height: 12)
//                .scaleEffect(audioManager.isRecording ? 1.2 : 1.0)
//                .animation(.easeInOut(duration: 0.3), value: audioManager.isRecording)
//        }
//    }
//}
//
//#Preview {
//    VStack(spacing: 20) {
//        AudioVisualizationView(audioManager: AudioRecordingManager())
//        WaveformVisualizationView(audioManager: AudioRecordingManager())
//        CircularAudioMeterView(audioManager: AudioRecordingManager())
//    }
//    .padding()
//}
