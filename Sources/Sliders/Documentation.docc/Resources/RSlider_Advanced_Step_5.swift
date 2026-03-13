import SwiftUI

struct MyRSliderStyle: RSliderStyle {

    func makeThumb(configuration: RSliderConfiguration) -> some View {
        let color: Color = configuration.isDisabled ? .gray :
            (configuration.isActive ? .cyan : .white)
        let shadowRadius: Double = configuration.isActive ? 8 : 3

        return Circle()
            .fill(color)
            .frame(width: 28, height: 28)
            .shadow(radius: shadowRadius)
            .animation(.easeOut(duration: 0.15), value: configuration.isActive)
    }

    func makeTrack(configuration: RSliderConfiguration) -> some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 18)

            CircularArc(percent: configuration.withinWind)
                .stroke(Color.cyan, style: StrokeStyle(lineWidth: 18, lineCap: .round))
        }
        .padding(9)
    }

    func makeTickMark(configuration: RSliderConfiguration, tickValue: Double) -> some View {
        let range = configuration.max - configuration.min
        let thumbPct = range > 0 ? (configuration.value - configuration.min) / range : 0
        let tickPct  = range > 0 ? (tickValue - configuration.min) / range : 0
        let proximity = max(0, 1 - abs(thumbPct - tickPct) / 0.20)
        let size    = 4.0 + 6.0 * proximity
        let opacity = 0.35 + 0.65 * proximity

        return Circle()
            .fill(Color.cyan.opacity(opacity))
            .frame(width: size, height: size)
            .animation(.easeOut(duration: 0.1), value: proximity)
    }
}

struct ContentView: View {
    @State private var value1 = 0.4
    @State private var value2 = 0.6

    var body: some View {
        VStack(spacing: 30) {
            RSlider(
                $value1,
                range: 0...1,
                tickSpacing: .count(11),
                affinityEnabled: true
            )
            .frame(width: 220, height: 220)

            RSlider($value2, range: 0...1, originAngle: .degrees(-90))
                .frame(width: 180, height: 180)
        }
        .radialSliderStyle(MyRSliderStyle())
        .padding()
    }
}
