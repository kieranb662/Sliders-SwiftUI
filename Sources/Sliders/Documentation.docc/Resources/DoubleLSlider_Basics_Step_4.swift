import SwiftUI

struct ContentView: View {
    @State private var lower = 0.25
    @State private var upper = 0.75

    var body: some View {
        DoubleLSlider(
            lowerValue: $lower,
            upperValue: $upper,
            range: 0...1,
            keepThumbInTrack: true,
            trackThickness: 20
        )
        .frame(height: 60)
        .padding()
    }
}
