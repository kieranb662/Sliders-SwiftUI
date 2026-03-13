import SwiftUI

struct ContentView: View {
    @State private var value = 5.0

    var body: some View {
        VStack(spacing: 8) {
            LSlider($value, range: 0...10, trackThickness: 28)
                .frame(height: 72)
            Text("Value: \(value, specifier: "%.1f")")
                .font(.caption)
        }
        .padding()
    }
}
