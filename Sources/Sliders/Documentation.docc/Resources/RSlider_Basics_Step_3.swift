import SwiftUI

struct ContentView: View {
    @State private var value = 0.0

    var body: some View {
        RSlider($value, range: 0...1, maxWinds: 3)
            .frame(width: 220, height: 220)
            .padding()
    }
}
