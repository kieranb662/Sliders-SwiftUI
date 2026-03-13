import SwiftUI

struct MyRSliderStyle: RSliderStyle {

    func makeThumb(configuration: RSliderConfiguration) -> some View {
        Circle()
            .fill(Color.gray)
            .frame(width: 28, height: 28)
    }

    func makeTrack(configuration: RSliderConfiguration) -> some View {
        Circle()
            .stroke(Color.gray.opacity(0.4), lineWidth: 18)
            .padding(9)
    }

    func makeTickMark(configuration: RSliderConfiguration, tickValue: Double) -> some View {
        Circle()
            .fill(Color.gray)
            .frame(width: 4, height: 4)
    }
}

struct ContentView: View {
    @State private var value = 0.5

    var body: some View {
        RSlider($value, range: 0...1, tickSpacing: .count(11))
            .radialSliderStyle(MyRSliderStyle())
            .frame(width: 220, height: 220)
            .padding()
    }
}
