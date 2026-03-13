import SwiftUI

struct ContentView: View {
    @State private var volume = 50.0

    var body: some View {
        LSlider($volume, range: 0...100, keepThumbInTrack: true, trackThickness: 20) { value in
            Label("\(Int(value)) dB", systemImage: "speaker.wave.2")
                .font(.caption.bold())
        }
        .frame(height: 80)
        .padding()
    }
}
