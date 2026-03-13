import SwiftUI

struct ContentView: View {
    @State private var value = 50.0

    var body: some View {
        PSlider($value, range: 0...100, shape: Circle())
            .frame(width: 200, height: 200)
            .padding()
    }
}
