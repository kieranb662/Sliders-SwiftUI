// Swift toolchain version 6.0
// Running macOS version 26.3
// Created on 3/13/26.
//
// Author: Kieran Brown
//
// Tutorial step previews for the DoubleLSlider DocC tutorials.
// Basics:   DoubleLSlider_Basics_Step_1  … DoubleLSlider_Basics_Step_8
// Advanced: DoubleLSlider_Advanced_Step_1 … DoubleLSlider_Advanced_Step_4

import SwiftUI

// MARK: - Basics

// Step 1 – Minimal DoubleLSlider with all defaults
#Preview("DoubleLSlider_Basics_Step_1") {
    struct Step1: View {
        @State private var lower = 0.25
        @State private var upper = 0.75
        var body: some View {
            DoubleLSlider(lowerValue: $lower, upperValue: $upper)
                .frame(height: 60)
                .padding()
        }
    }
    return Step1()
}

// Step 2 – Custom range and trackThickness
#Preview("DoubleLSlider_Basics_Step_2") {
    struct Step2: View {
        @State private var lower = 25.0
        @State private var upper = 75.0
        var body: some View {
            DoubleLSlider(
                lowerValue: $lower,
                upperValue: $upper,
                range: 0...100,
                trackThickness: 28
            )
            .frame(height: 60)
            .padding()
        }
    }
    return Step2()
}

// Step 3 – Vertical (90 degrees)
#Preview("DoubleLSlider_Basics_Step_3") {
    struct Step3: View {
        @State private var lower = 20.0
        @State private var upper = 80.0
        var body: some View {
            DoubleLSlider(
                lowerValue: $lower,
                upperValue: $upper,
                range: 0...100,
                angle: .degrees(90),
                keepThumbInTrack: true
            )
            .frame(width: 60, height: 200)
            .padding()
        }
    }
    return Step3()
}

// Step 4 – keepThumbInTrack enabled
#Preview("DoubleLSlider_Basics_Step_4") {
    struct Step4: View {
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
            .frame(height: 60)
            .padding()
        }
    }
    return Step4()
}

// Step 5 – minimumDistance
#Preview("DoubleLSlider_Basics_Step_5") {
    struct Step5: View {
        @State private var lower = 0.1
        @State private var upper = 0.9
        var body: some View {
            DoubleLSlider(
                lowerValue: $lower,
                upperValue: $upper,
                range: 0...1,
                keepThumbInTrack: true,
                trackThickness: 20,
                minimumDistance: 0.15
            )
            .frame(height: 60)
            .padding()
        }
    }
    return Step5()
}

// Step 6 – Tick marks .count(11)
#Preview("DoubleLSlider_Basics_Step_6") {
    struct Step6: View {
        @State private var lower = 0.0
        @State private var upper = 0.5
        var body: some View {
            DoubleLSlider(
                lowerValue: $lower,
                upperValue: $upper,
                range: 0...1,
                keepThumbInTrack: true,
                trackThickness: 20,
                tickMarkSpacing: .count(11),
                hapticFeedbackEnabled: true
            )
            .frame(height: 60)
            .padding()
        }
    }
    return Step6()
}

// Step 7 – Affinity snapping
#Preview("DoubleLSlider_Basics_Step_7") {
    struct Step7: View {
        @State private var lower = 0.0
        @State private var upper = 0.5
        var body: some View {
            DoubleLSlider(
                lowerValue: $lower,
                upperValue: $upper,
                range: 0...1,
                keepThumbInTrack: true,
                trackThickness: 20,
                tickMarkSpacing: .count(11),
                hapticFeedbackEnabled: true,
                affinityEnabled: true,
                affinityRadius: 0.03,
                affinityResistance: 0.015
            )
            .frame(height: 60)
            .padding()
        }
    }
    return Step7()
}

// Step 8 – Custom labels and disabled state
#Preview("DoubleLSlider_Basics_Step_8") {
    struct Step8: View {
        @State private var lower = 0.25
        @State private var upper = 0.75
        var body: some View {
            VStack(spacing: 30) {
                DoubleLSlider(
                    lowerValue: $lower,
                    upperValue: $upper,
                    range: 0...100
                ) { v in
                    Text("from \(Int(v))")
                } upperLabel: { v in
                    Text("to \(Int(v))")
                }
                .frame(height: 60)

                DoubleLSlider(
                    lowerValue: .constant(25),
                    upperValue: .constant(75),
                    range: 0...100
                )
                .disabled(true)
                .frame(height: 60)
            }
            .padding()
        }
    }
    return Step8()
}

// MARK: - Advanced

// Step 1 – Declare MyDoubleLSliderStyle with stub implementations
#Preview("DoubleLSlider_Advanced_Step_1") {
    struct MyStyle: DoubleLSliderStyle {
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
            AdaptiveLine(thickness: configuration.trackThickness, angle: configuration.angle)
                .fill(Color.gray.opacity(0.4))
        }
    }

    struct Step1: View {
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
            .doubleLSliderStyle(MyStyle())
            .frame(height: 60)
            .padding()
        }
    }
    return Step1()
}

// Step 2 – Implement makeTrack with filled range segment
#Preview("DoubleLSlider_Advanced_Step_2") {
    struct MyStyle: DoubleLSliderStyle {
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
                    adjustmentForThumb: 0
                )
                .fill(Color.teal)
                .mask(
                    AdaptiveLine(
                        thickness: configuration.trackThickness,
                        angle: configuration.angle,
                        percentFilled: 1 - configuration.lowerPercent,
                        adjustmentForThumb: 0
                    )
                    .fill(Color.white)
                    .rotationEffect(.degrees(180))
                )
                .mask(AdaptiveLine(thickness: configuration.trackThickness, angle: configuration.angle))
            }
        }
    }

    struct Step2: View {
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
            .doubleLSliderStyle(MyStyle())
            .frame(height: 60)
            .padding()
        }
    }
    return Step2()
}

// Step 3 – Implement makeLowerThumb / makeUpperThumb
#Preview("DoubleLSlider_Advanced_Step_3") {
    struct MyStyle: DoubleLSliderStyle {
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
                    adjustmentForThumb: 0
                )
                .fill(Color.teal)
                .mask(
                    AdaptiveLine(
                        thickness: configuration.trackThickness,
                        angle: configuration.angle,
                        percentFilled: 1 - configuration.lowerPercent,
                        adjustmentForThumb: 0
                    )
                    .fill(Color.white)
                    .rotationEffect(.degrees(180))
                )
                .mask(AdaptiveLine(thickness: configuration.trackThickness, angle: configuration.angle))
            }
        }
    }

    struct Step3: View {
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
            .doubleLSliderStyle(MyStyle())
            .frame(height: 60)
            .padding()
        }
    }
    return Step3()
}

// Step 4 – Apply finished style to horizontal + diagonal sliders
#Preview("DoubleLSlider_Advanced_Step_4") {
    struct MyStyle: DoubleLSliderStyle {
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
                    adjustmentForThumb: 0
                )
                .fill(Color.teal)
                .mask(
                    AdaptiveLine(
                        thickness: configuration.trackThickness,
                        angle: configuration.angle,
                        percentFilled: 1 - configuration.lowerPercent,
                        adjustmentForThumb: 0
                    )
                    .fill(Color.white)
                    .rotationEffect(.degrees(180))
                )
                .mask(AdaptiveLine(thickness: configuration.trackThickness, angle: configuration.angle))
            }
        }
    }

    struct Step4: View {
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
            .doubleLSliderStyle(MyStyle())
            .padding()
        }
    }
    return Step4()
}
