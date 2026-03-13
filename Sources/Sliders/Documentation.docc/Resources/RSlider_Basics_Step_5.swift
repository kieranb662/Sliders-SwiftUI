import SwiftUI

struct ContentView: View {
    @State private var value = 3.0

    var body: some View {
        RSlider($value, range: 0...10, tickSpacing: .spacing(1))
            .frame(width: 220, height: 220)
            .padding()
    }
}
