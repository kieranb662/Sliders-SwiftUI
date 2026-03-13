import SwiftUI

struct ContentView: View {
    @State private var lower = 0.1
    @State private var upper = 0.9

    var body: some View {
        DoubleLSlider(
            lowerValue: $lower,
            upperValue: $upper,
            range: 0...1,
            keepThumbInTrack: true,
            trackThickness: 20,
            minimumDistance: 0.15
        )
        .frame(height: 60)
        .padding()
    }
}
