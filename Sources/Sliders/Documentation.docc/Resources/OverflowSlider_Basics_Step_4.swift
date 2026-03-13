import SwiftUI

struct MyOverflowSliderStyle: OverflowSliderStyle {
    func makeThumb(configuration: OverflowSliderConfiguration) -> some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(configuration.thumbIsActive ? Color.orange : Color.blue)
            .opacity(0.5)
            .frame(width: 20, height: 50)
    }

    func makeTrack(configuration: OverflowSliderConfiguration) -> some View {
        let totalLength = configuration.max - configuration.min
        let spacing = configuration.tickSpacing

        return TickMarks(
            spacing: CGFloat(spacing),
            ticks: Int(totalLength / Double(spacing))
        )
        .stroke(Color.orange.opacity(0.6))
        .frame(width: CGFloat(totalLength))
    }
}

struct ContentView: View {
    @State private var value = 50.0

    var body: some View {
        OverflowSlider(value: $value, range: 0...500, spacing: 10, isDisabled: false)
            .overflowSliderStyle(MyOverflowSliderStyle())
            .frame(height: 60)
            .padding()
    }
}
