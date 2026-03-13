import SwiftUI

struct MyLSliderStyle: LSliderStyle {

    func makeThumb(configuration: LSliderConfiguration) -> some View {
        let color: Color = configuration.isDisabled
            ? Color.gray
            : (configuration.isActive ? Color.white : Color.indigo)
        return Circle()
            .fill(color)
            .frame(
                width: configuration.trackThickness * 2,
                height: configuration.trackThickness * 2
            )
            .shadow(
                color: .black.opacity(configuration.isDisabled ? 0 : 0.2),
                radius: configuration.isActive ? 6 : 2
            )
            .animation(.easeOut(duration: 0.12), value: configuration.isActive)
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
        VStack(spacing: 20) {
            LSlider($value, range: 0...1, keepThumbInTrack: true, trackThickness: 20)
                .linearSliderStyle(MyLSliderStyle())
                .frame(height: 60)
            LSlider($value, range: 0...1, keepThumbInTrack: true, trackThickness: 20)
                .linearSliderStyle(MyLSliderStyle())
                .disabled(true)
                .frame(height: 60)
        }
        .padding()
    }
}
