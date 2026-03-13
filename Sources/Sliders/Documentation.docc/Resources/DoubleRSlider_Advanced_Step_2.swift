import SwiftUI

struct MyDoubleRSliderStyle: DoubleRSliderStyle {

    func makeLowerThumb(configuration: DoubleRSliderConfiguration) -> some View {
        Circle()
            .fill(Color.gray)
            .frame(width: 28, height: 28)
    }

    func makeUpperThumb(configuration: DoubleRSliderConfiguration) -> some View {
        Circle()
            .fill(Color.gray)
            .frame(width: 28, height: 28)
    }

    func makeTrack(configuration: DoubleRSliderConfiguration) -> some View {
        let arcLength = configuration.upperPercent - configuration.lowerPercent
        return ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 18)

            CircularArc(percent: arcLength)
                .stroke(Color.teal, style: StrokeStyle(lineWidth: 18, lineCap: .round))
                .padding(9)
        }
    }
}

struct ContentView: View {
    @State private var lower = 0.25
    @State private var upper = 0.75

    var body: some View {
        DoubleRSlider(
            lowerValue: $lower,
            upperValue: $upper,
            range: 0...1
        )
        .doubleRadialSliderStyle(MyDoubleRSliderStyle())
        .frame(width: 220, height: 220)
        .padding()
    }
}
