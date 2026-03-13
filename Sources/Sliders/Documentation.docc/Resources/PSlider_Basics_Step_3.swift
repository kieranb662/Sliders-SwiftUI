import SwiftUI

struct ContentView: View {
    @State private var value = 0.5

    var body: some View {
        PSlider($value, shape: RoundedRectangle(cornerRadius: 20))
            .frame(width: 250, height: 150)
            .padding()
    }
}
