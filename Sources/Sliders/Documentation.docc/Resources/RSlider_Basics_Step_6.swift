import SwiftUI

struct ContentView: View {
    @State private var snapped = 0.5

    var body: some View {
        RSlider(
            $snapped,
            range: 0...1,
            tickSpacing: .count(11),
            affinityEnabled: true,
            affinityRadius: 0.02,
            affinityResistance: 0.01
        )
        .frame(width: 220, height: 220)
        .padding()
    }
}
