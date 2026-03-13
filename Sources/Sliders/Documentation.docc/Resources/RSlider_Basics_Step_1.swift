import SwiftUI

struct ContentView: View {
    @State private var value = 0.5

    var body: some View {
        RSlider($value)
            .frame(width: 180, height: 180)
            .padding()
    }
}
