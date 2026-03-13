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
        let adjustment: Double = configuration.keepThumbInTrack
            ? configuration.trackThickness * (1 - configuration.pctFill)
            : configuration.trackThickness / 2

        return ZStack {
            AdaptiveLine(thickness: configuration.trackThickness, angle: configuration.angle)
                .fill(Color.indigo.opacity(0.25))
            AdaptiveLine(
                thickness: configuration.trackThickness,
                angle: configuration.angle,
                percentFilled: configuration.pctFill,
                adjustmentForThumb: adjustment
            )
            .fill(Color.indigo)
            .mask(
                AdaptiveLine(thickness: configuration.trackThickness, angle: configuration.angle)
            )
        }
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
