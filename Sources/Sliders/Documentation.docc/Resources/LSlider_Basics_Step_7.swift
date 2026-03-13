import SwiftUI

struct ContentView: View {
    @State private var value = 0.5

    var body: some View {
        VStack(spacing: 8) {
            LSlider(
                $value,
                range: 0...1,
                keepThumbInTrack: true,
                trackThickness: 20,
                tickMarkSpacing: .values([0.0, 0.25, 0.5, 0.75, 1.0]),
                hapticFeedbackEnabled: false
            )
            .frame(height: 60)
            Text("Value: \(value, specifier: "%.2f")")
                .font(.caption)
        }
        .padding()
    }
}
