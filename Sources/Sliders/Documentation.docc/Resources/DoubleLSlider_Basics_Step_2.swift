import SwiftUI

struct ContentView: View {
    @State private var lower = 25.0
    @State private var upper = 75.0

    var body: some View {
        DoubleLSlider(
            lowerValue: $lower,
            upperValue: $upper,
            range: 0...100,
            trackThickness: 28
        )
        .frame(height: 60)
        .padding()
    }
}
