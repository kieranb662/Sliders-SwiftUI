import SwiftUI

struct ContentView: View {
    @State private var stepped = 0.5

    var body: some View {
        RSlider($stepped, range: 0...1, tickSpacing: .count(11))
            .frame(width: 220, height: 220)
            .padding()
    }
}
