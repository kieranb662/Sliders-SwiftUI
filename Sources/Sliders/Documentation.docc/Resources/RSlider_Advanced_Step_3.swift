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
