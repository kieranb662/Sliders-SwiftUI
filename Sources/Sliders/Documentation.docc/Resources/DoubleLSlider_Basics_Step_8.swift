import SwiftUI

struct ContentView: View {
    @State private var lower = 0.25
    @State private var upper = 0.75

    var body: some View {
        VStack(spacing: 30) {
            DoubleLSlider(
                lowerValue: $lower,
                upperValue: $upper,
                range: 0...100
            ) { v in
                Text("from \(Int(v))")
            } upperLabel: { v in
                Text("to \(Int(v))")
            }
            .frame(height: 60)

            DoubleLSlider(
                lowerValue: .constant(25),
                upperValue: .constant(75),
                range: 0...100
            )
            .disabled(true)
            .frame(height: 60)
        }
        .padding()
    }
}
