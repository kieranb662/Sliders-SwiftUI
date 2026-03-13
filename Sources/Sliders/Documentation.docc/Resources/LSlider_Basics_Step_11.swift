import SwiftUI

struct ContentView: View {
    @State private var value = 0.5

    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Enabled").font(.caption2).foregroundStyle(.secondary)
                LSlider($value, range: 0...1, keepThumbInTrack: true, trackThickness: 20)
                    .frame(height: 60)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("Disabled").font(.caption2).foregroundStyle(.secondary)
                LSlider($value, range: 0...1, keepThumbInTrack: true, trackThickness: 20)
                    .disabled(true)
                    .frame(height: 60)
            }
        }
        .padding()
    }
}
