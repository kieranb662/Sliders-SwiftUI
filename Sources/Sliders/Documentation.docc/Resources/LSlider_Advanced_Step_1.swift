import SwiftUI

struct MyLSliderStyle: LSliderStyle {

    func makeThumb(configuration: LSliderConfiguration) -> some View {
        Circle()
            .fill(Color.gray)
            .frame(
                width: configuration.trackThickness * 2,
                height: configuration.trackThickness * 2
            )
    }

    func makeTrack(configuration: LSliderConfiguration) -> some View {
        AdaptiveLine(thickness: configuration.trackThickness, angle: configuration.angle)
            .fill(Color.gray.opacity(0.4))
    }

    func makeTickMark(configuration: LSliderConfiguration, tickValue: Double) -> some View {
        Circle()
            .fill(Color.gray)
            .frame(width: 4, height: 4)
    }
}

struct ContentView: View {
    @State private var value = 0.5

    var body: some View {
        LSlider($value, range: 0...1, keepThumbInTrack: true, trackThickness: 20)
            .linearSliderStyle(MyLSliderStyle())
            .frame(height: 60)
            .padding()
    }
}
