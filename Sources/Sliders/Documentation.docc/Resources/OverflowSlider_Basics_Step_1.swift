import SwiftUI

struct ContentView: View {
    @State private var value = 50.0

    var body: some View {
        OverflowSlider(value: $value, range: 0...500, spacing: 10, isDisabled: false)
            .frame(height: 60)
            .padding()
    }
}
