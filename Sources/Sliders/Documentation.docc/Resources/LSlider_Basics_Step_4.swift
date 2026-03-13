import SwiftUI

struct ContentView: View {
    @State private var value1 = 0.5
    @State private var value2 = 0.5

    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("keepThumbInTrack: false (default)")
                    .font(.caption2).foregroundStyle(.secondary)
                LSlider($value1, range: 0...1, keepThumbInTrack: false, trackThickness: 20)
                    .frame(height: 60)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("keepThumbInTrack: true")
                    .font(.caption2).foregroundStyle(.secondary)
                LSlider($value2, range: 0...1, keepThumbInTrack: true, trackThickness: 20)
                    .frame(height: 60)
            }
        }
        .padding()
    }
}
