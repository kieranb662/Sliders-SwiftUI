import SwiftUI

struct ContentView: View {
    @State private var point = CGPoint(x: 0.0, y: 5.0)

    var body: some View {
        TrackPad($point, rangeX: -1...1, rangeY: 0...10)
            .frame(height: 260)
            .padding()
    }
}
