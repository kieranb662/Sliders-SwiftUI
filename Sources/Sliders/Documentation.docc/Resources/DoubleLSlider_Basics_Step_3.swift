import SwiftUI

struct ContentView: View {
    @State private var lower = 20.0
    @State private var upper = 80.0

    var body: some View {
        DoubleLSlider(
            lowerValue: $lower,
            upperValue: $upper,
            range: 0...100,
            angle: .degrees(90),
            keepThumbInTrack: true
        )
        .frame(width: 60, height: 200)
        .padding()
    }
}
