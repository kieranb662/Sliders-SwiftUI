import SwiftUI

struct ContentView: View {
    @State private var point = CGPoint(x: 0.5, y: 0.5)

    var body: some View {
        VStack(spacing: 20) {
            TrackPad($point, rangeX: -1...1, rangeY: -1...1) { x, y in
                Text(String(format: "x: %.2f  y: %.2f", x, y))
            }
            .frame(height: 260)

            TrackPad(.constant(CGPoint(x: 0.5, y: 0.5)))
                .disabled(true)
                .frame(height: 260)
        }
        .padding()
    }
}
