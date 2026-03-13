import SwiftUI

struct MyDoubleLSliderStyle: DoubleLSliderStyle {

    func makeLowerThumb(configuration: DoubleLSliderConfiguration) -> some View {
        let active = configuration.isLowerActive || configuration.isRangeActive
        return RoundedRectangle(cornerRadius: 6)
            .fill(active ? Color.teal : Color.white)
            .frame(width: 28, height: 28)
            .shadow(color: .black.opacity(0.25), radius: active ? 6 : 2)
    }

    func makeUpperThumb(configuration: DoubleLSliderConfiguration) -> some View {
        let active = configuration.isUpperActive || configuration.isRangeActive
        return RoundedRectangle(cornerRadius: 6)
            .fill(active ? Color.teal : Color.white)
            .frame(width: 28, height: 28)
            .shadow(color: .black.opacity(0.25), radius: active ? 6 : 2)
    }

    func makeTrack(configuration: DoubleLSliderConfiguration) -> some View {
        ZStack {
            AdaptiveLine(thickness: configuration.trackThickness, angle: configuration.angle)
                .fill(Color(white: 0.2))

            AdaptiveLine(
                thickness: configuration.trackThickness,
                angle: configuration.angle,
                percentFilled: configuration.upperPercent,
                cap: .square,
                adjustmentForThumb: 0
            )
            .fill(Color.teal)
            .mask(
                AdaptiveLine(
                    thickness: configuration.trackThickness,
                    angle: configuration.angle,
                    percentFilled: 1 - configuration.lowerPercent,
                    from: .end,
                    cap: .square,
                    adjustmentForThumb: 0
                )
            )
            .mask(AdaptiveLine(thickness: configuration.trackThickness, angle: configuration.angle))
        }
    }
}

struct ContentView: View {
    @State private var lowerH = 0.2
    @State private var upperH = 0.8
    @State private var lowerD = 0.3
    @State private var upperD = 0.7

    var body: some View {
        VStack(spacing: 40) {
            DoubleLSlider(
                lowerValue: $lowerH,
                upperValue: $upperH,
                range: 0...1,
                keepThumbInTrack: true,
                trackThickness: 20,
                tickMarkSpacing: .count(11),
                affinityEnabled: true
            )
            .frame(height: 60)

            DoubleLSlider(
                lowerValue: $lowerD,
                upperValue: $upperD,
                range: 0...1,
                angle: .degrees(30),
                keepThumbInTrack: true,
                trackThickness: 20
            )
            .frame(width: 300, height: 120)
        }
        .doubleLSliderStyle(MyDoubleLSliderStyle())
        .padding()
    }
}
