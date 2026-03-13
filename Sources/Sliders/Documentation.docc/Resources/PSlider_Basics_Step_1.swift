import SwiftUI

struct ContentView: View {
    @State private var value = 0.5

    var body: some View {
        PSlider($value, shape: Circle())
            .frame(width: 200, height: 200)
            .padding()
    }
}
