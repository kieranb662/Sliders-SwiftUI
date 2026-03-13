import SwiftUI

struct ContentView: View {
    @State private var value = 250.0

    var body: some View {
        OverflowSlider(value: $value, range: 0...1000, spacing: 25, isDisabled: false)
            .frame(height: 60)
            .padding()
    }
}
