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
        let range = configuration.max - configuration.min
        let thumbPct = range > 0 ? (configuration.value - configuration.min) / range : 0
        let tickPct  = range > 0 ? (tickValue - configuration.min) / range : 0
        let distance  = abs(thumbPct - tickPct)
        let proximity = max(0, 1 - distance / 0.15)

        let size    = 5.0 + 7.0 * proximity
        let opacity = 0.3 + 0.7 * proximity

        return Circle()
            .fill(Color.indigo.opacity(opacity))
            .frame(width: size, height: size)
            .animation(.easeOut(duration: 0.1), value: proximity)
    }

    func makeLabel(configuration: LSliderConfiguration, content: AnyView) -> some View {
        content
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.indigo)
                    .shadow(color: .black.opacity(0.25), radius: 4, y: 2)
            )
            .foregroundStyle(.white)
            .scaleEffect(configuration.isActive ? 1.0 : 0.75)
            .opacity(configuration.isActive ? 1.0 : 0.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isActive)
    }
}

struct ContentView: View {
    @State private var value = 0.5

    var body: some View {
        LSlider(
            $value,
            range: 0...1,
            keepThumbInTrack: true,
            trackThickness: 20,
            tickMarkSpacing: .count(11)
        )
        .linearSliderStyle(MyLSliderStyle())
        .frame(height: 80)
        .padding()
    }
}
