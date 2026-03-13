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
                tickMarkSpacing: .count(11),
                hapticFeedbackEnabled: true,
                affinityEnabled: true,
                affinityRadius: 0.04,
                affinityResistance: 0.03
            )
            .frame(height: 60)
            Text("Value: \(value, specifier: "%.2f")")
                .font(.caption)
        }
        .padding()
    }
}
