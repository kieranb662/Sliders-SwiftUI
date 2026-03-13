import SwiftUI

struct ContentView: View {
    @State private var lower = 0.25
    @State private var upper = 0.75

    var body: some View {
        DoubleRSlider(lowerValue: $lower, upperValue: $upper)
            .frame(width: 220, height: 220)
            .padding()
    }
}
