import SwiftUI

struct ContentView: View {
    @State private var value = 0.5

    var body: some View {
        LSlider($value)
            .frame(height: 60)
            .padding()
    }
}
