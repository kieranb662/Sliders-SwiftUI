import SwiftUI

struct ContentView: View {
    @State private var lower = 0.25
    @State private var upper = 0.75

    var body: some View {
        VStack {
            Text("Drag the filled arc to shift the range")
                .font(.caption)
                .foregroundStyle(.secondary)

            DoubleRSlider(
                lowerValue: $lower,
                upperValue: $upper,
                range: 0...1,
                tickSpacing: .count(9)
            )
            .frame(width: 220, height: 220)

            Text(String(format: "%.2f – %.2f", lower, upper))
                .font(.headline)
        }
        .padding()
    }
}
