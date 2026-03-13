import SwiftUI

struct ContentView: View {
    @State private var pan: Double = 0.0
    @State private var tilt: Double = 0.0

    var body: some View {
        TrackPad(x: $pan, y: $tilt, rangeX: -1...1, rangeY: -1...1)
            .frame(height: 260)
            .padding()
    }
}
