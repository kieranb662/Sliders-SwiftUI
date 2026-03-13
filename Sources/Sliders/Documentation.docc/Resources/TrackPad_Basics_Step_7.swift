import SwiftUI

struct ContentView: View {
    @State private var point = CGPoint(x: 0.5, y: 0.5)

    var body: some View {
        TrackPad($point)
            .tickCountX(3)
            .tickCountY(5)
            .frame(height: 260)
            .padding()
    }
}
