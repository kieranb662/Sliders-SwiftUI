import SwiftUI

struct ContentView: View {
    @State private var lower = 0.0
    @State private var upper = 0.5

    var body: some View {
        DoubleRSlider(
            lowerValue: $lower,
            upperValue: $upper,
            range: 0...1,
            tickSpacing: .count(9),
            affinityEnabled: true,
            affinityRadius: 0.03,
            affinityResistance: 0.015
        )
        .frame(width: 220, height: 220)
        .padding()
    }
}
