import SwiftUI

struct MyDoubleLSliderStyle: DoubleLSliderStyle {

    func makeLowerThumb(configuration: DoubleLSliderConfiguration) -> some View {
        Circle()
            .fill(Color.gray)
            .frame(width: 30, height: 30)
    }

    func makeUpperThumb(configuration: DoubleLSliderConfiguration) -> some View {
        Circle()
            .fill(Color.gray)
            .frame(width: 30, height: 30)
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
    @State private var lower = 0.25
    @State private var upper = 0.75

    var body: some View {
        DoubleLSlider(
            lowerValue: $lower,
            upperValue: $upper,
            range: 0...1,
            keepThumbInTrack: true,
            trackThickness: 20
        )
        .doubleLSliderStyle(MyDoubleLSliderStyle())
        .frame(height: 60)
        .padding()
    }
}
