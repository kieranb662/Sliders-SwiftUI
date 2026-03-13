import SwiftUI

struct ContentView: View {
    @State private var lower = 20.0
    @State private var upper = 80.0

    var body: some View {
        DoubleRSlider(
            lowerValue: $lower,
            upperValue: $upper,
            range: 0...100,
            originAngle: .degrees(-90)
        )
        .frame(width: 220, height: 220)
        .padding()
    }
}
