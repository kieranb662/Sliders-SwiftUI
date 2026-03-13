import SwiftUI

struct ContentView: View {
    @State private var value = 0.5

    var body: some View {
        VStack(spacing: 8) {
            LSlider($value, range: 0...1, keepThumbInTrack: true, trackThickness: 20)
                .allowsSingleTapSelect(true)
                .frame(height: 60)
            Text("Tap anywhere on the track to jump")
                .font(.caption).foregroundStyle(.secondary)
        }
        .padding()
    }
}
