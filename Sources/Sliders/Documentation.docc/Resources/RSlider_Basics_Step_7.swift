import SwiftUI

struct ContentView: View {
    @State private var speed = 0.5

    var body: some View {
        VStack(spacing: 30) {
            RSlider($speed, range: 0...200) { value in
                Text("\(Int(value)) km/h")
            }
            .frame(width: 220, height: 220)

            RSlider(.constant(100), range: 0...200)
                .disabled(true)
                .frame(width: 220, height: 220)
        }
        .padding()
    }
}
