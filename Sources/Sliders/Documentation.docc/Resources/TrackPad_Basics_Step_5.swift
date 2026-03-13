import SwiftUI

struct ContentView: View {
    @State private var point = CGPoint(x: 0.5, y: 0.5)

    var body: some View {
        TrackPad($point)
            .showPreviousValue(true)
            .previousValueAffinityRadius(0.03)
            .previousValueAffinityResistance(0.01)
            .frame(height: 260)
            .padding()
    }
}
