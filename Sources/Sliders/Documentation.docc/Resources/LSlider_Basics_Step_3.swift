import SwiftUI

struct ContentView: View {
    @State private var value = 0.5

    var body: some View {
        LSlider(
            $value,
            range: 0...1,
            angle: Angle(degrees: 315),
            trackThickness: 20
        )
        .frame(width: 200, height: 200)
        .padding()
    }
}
