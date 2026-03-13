import SwiftUI

struct ContentView: View {
    @State private var lower = 0.1
    @State private var upper = 0.9

    var body: some View {
        DoubleRSlider(
            lowerValue: $lower,
            upperValue: $upper,
            range: 0...1,
            minimumDistance: 0.1
        )
        .frame(width: 220, height: 220)
        .padding()
    }
}
