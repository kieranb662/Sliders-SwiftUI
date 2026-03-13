import SwiftUI

struct ContentView: View {
    @State private var temperature = 20.0

    var body: some View {
        RSlider($temperature, range: 0...100, originAngle: .degrees(-90))
            .frame(width: 220, height: 220)
            .padding()
    }
}
