import SwiftUI

struct ContentView: View {
    @State private var lower = 0.0
    @State private var upper = 0.5

    var body: some View {
        DoubleLSlider(
            lowerValue: $lower,
            upperValue: $upper,
            range: 0...1,
            keepThumbInTrack: true,
            trackThickness: 20,
            tickMarkSpacing: .count(11),
            hapticFeedbackEnabled: true,
            affinityEnabled: true,
            affinityRadius: 0.03,
            affinityResistance: 0.015
        )
        .frame(height: 60)
        .padding()
    }
}
