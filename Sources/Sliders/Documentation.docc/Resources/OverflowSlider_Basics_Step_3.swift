import SwiftUI

struct ContentView: View {
    @State private var value = 100.0

    var body: some View {
        VStack {
            Text("Value: \(Int(value))")
                .font(.headline)

            Text("Drag the track quickly and release to throw it")
                .font(.caption)
                .foregroundStyle(.secondary)

            OverflowSlider(value: $value, range: 0...500, spacing: 10, isDisabled: false)
                .frame(height: 60)
        }
        .padding()
    }
}
