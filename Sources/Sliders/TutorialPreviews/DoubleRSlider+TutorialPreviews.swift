// Swift toolchain version 6.0
// Running macOS version 26.3
// Created on 3/13/26.
//
// Author: Kieran Brown
//
// Tutorial step previews for the DoubleRSlider DocC tutorials.
// Basics:   DoubleRSlider_Basics_Step_1  … DoubleRSlider_Basics_Step_7
// Advanced: DoubleRSlider_Advanced_Step_1 … DoubleRSlider_Advanced_Step_4

import SwiftUI

// MARK: - Basics

// Step 1 – Minimal DoubleRSlider with all defaults
#Preview("DoubleRSlider_Basics_Step_1") {
    struct Step1: View {
        @State private var lower = 0.25
        @State private var upper = 0.75
        var body: some View {
            DoubleRSlider(lowerValue: $lower, upperValue: $upper)
                .frame(width: 220, height: 220)
                .padding()
        }
    }
    return Step1()
}

// Step 2 – Custom range and originAngle
#Preview("DoubleRSlider_Basics_Step_2") {
    struct Step2: View {
        @State private var lower = 20.0
        @State private var upper = 80.0
        var body: some View {
            DoubleRSlider(
                lowerValue: $lower,
                upperValue: $upper,
                range: 0...100,
                originAngle: .degrees(-90)
            )
            .frame(width: 220, height: 220)
            .padding()
        }
    }
    return Step2()
}

// Step 3 – minimumDistance
#Preview("DoubleRSlider_Basics_Step_3") {
    struct Step3: View {
        @State private var lower = 0.1
        @State private var upper = 0.9
        var body: some View {
            DoubleRSlider(
                lowerValue: $lower,
                upperValue: $upper,
                range: 0...1,
                minimumDistance: 0.1
            )
            .frame(width: 220, height: 220)
            .padding()
        }
    }
    return Step3()
}

// Step 4 – Tick marks .count(9)
#Preview("DoubleRSlider_Basics_Step_4") {
    struct Step4: View {
        @State private var lower = 0.0
        @State private var upper = 0.5
        var body: some View {
            DoubleRSlider(
                lowerValue: $lower,
                upperValue: $upper,
                range: 0...1,
                tickSpacing: .count(9)
            )
            .padding()
        }
    }
    return Step4()
}

// Step 5 – Affinity snapping
#Preview("DoubleRSlider_Basics_Step_5") {
    struct Step5: View {
        @State private var lower = 0.0
        @State private var upper = 0.5
        var body: some View {
            DoubleRSlider(
                lowerValue: $lower,
                upperValue: $upper,
                range: 0...1,
                tickSpacing: .count(9),
                affinityEnabled: true,
                affinityRadius: 0.03,
                affinityResistance: 0.015
            )
            .frame(width: 220, height: 220)
            .padding()
        }
    }
    return Step5()
}

// Step 6 – Active track arc dragging demo
#Preview("DoubleRSlider_Basics_Step_6") {
    struct Step6: View {
        @State private var lower = 0.25
        @State private var upper = 0.75
        var body: some View {
            VStack {
                Text("Drag the filled arc to shift the range")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                DoubleRSlider(
                    lowerValue: $lower,
                    upperValue: $upper,
                    range: 0...1,
                    tickSpacing: .count(9)
                )
                .frame(width: 220, height: 220)

                Text(String(format: "%.2f – %.2f", lower, upper))
                    .font(.headline)
            }
            .padding()
        }
    }
    return Step6()
}

// Step 7 – Custom labels and disabled state
#Preview("DoubleRSlider_Basics_Step_7") {
    struct Step7: View {
        @State private var lower = 0.25
        @State private var upper = 0.75
        var body: some View {
            VStack(spacing: 30) {
                DoubleRSlider(
                    lowerValue: $lower,
                    upperValue: $upper,
                    range: 0...100
                ) { v in
                    Text("from \(Int(v))")
                } upperLabel: { v in
                    Text("to \(Int(v))")
                }
                .frame(width: 220, height: 220)

                DoubleRSlider(
                    lowerValue: .constant(25),
                    upperValue: .constant(75),
                    range: 0...100
                )
                .disabled(true)
                .frame(width: 220, height: 220)
            }
            .padding()
        }
    }
    return Step7()
}

// MARK: - Advanced

// Step 1 – Declare MyDoubleRSliderStyle with stub implementations
#Preview("DoubleRSlider_Advanced_Step_1") {
    struct MyStyle: DoubleRSliderStyle {
        func makeLowerThumb(configuration: DoubleRSliderConfiguration) -> some View {
            Circle()
                .fill(Color.gray)
                .frame(width: 28, height: 28)
        }
        func makeUpperThumb(configuration: DoubleRSliderConfiguration) -> some View {
            Circle()
                .fill(Color.gray)
                .frame(width: 28, height: 28)
        }
        func makeTrack(configuration: DoubleRSliderConfiguration) -> some View {
            Circle()
                .stroke(Color.gray.opacity(0.4), lineWidth: 18)
                .padding(9)
        }
    }

    struct Step1: View {
        @State private var lower = 0.25
        @State private var upper = 0.75
        var body: some View {
            DoubleRSlider(
                lowerValue: $lower,
                upperValue: $upper,
                range: 0...1
            )
            .doubleRadialSliderStyle(MyStyle())
            .frame(width: 220, height: 220)
            .padding()
        }
    }
    return Step1()
}

// Step 2 – Implement makeTrack with teal arc
#Preview("DoubleRSlider_Advanced_Step_2") {
    struct MyStyle: DoubleRSliderStyle {
        func makeLowerThumb(configuration: DoubleRSliderConfiguration) -> some View {
            Circle()
                .fill(Color.gray)
                .frame(width: 28, height: 28)
        }
        func makeUpperThumb(configuration: DoubleRSliderConfiguration) -> some View {
            Circle()
                .fill(Color.gray)
                .frame(width: 28, height: 28)
        }
        func makeTrack(configuration: DoubleRSliderConfiguration) -> some View {
            let arcLength = configuration.upperPercent - configuration.lowerPercent
            return ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 18)
                CircularArc(percent: arcLength)
                    .stroke(Color.teal, style: StrokeStyle(lineWidth: 18, lineCap: .round))
                    .rotationEffect(configuration.lowerAngle)
            }
        }
    }

    struct Step2: View {
        @State private var lower = 0.25
        @State private var upper = 0.75
        var body: some View {
            DoubleRSlider(
                lowerValue: $lower,
                upperValue: $upper,
                range: 0...1
            )
            .doubleRadialSliderStyle(MyStyle())
            .frame(width: 220, height: 220)
            .padding()
        }
    }
    return Step2()
}

// Step 3 – Implement both thumbs with active state
#Preview("DoubleRSlider_Advanced_Step_3") {
    struct MyStyle: DoubleRSliderStyle {
        func makeLowerThumb(configuration: DoubleRSliderConfiguration) -> some View {
            let active = configuration.isLowerActive || configuration.isRangeActive
            return RoundedRectangle(cornerRadius: 6)
                .fill(active ? Color.teal : Color.white)
                .frame(width: 28, height: 28)
                .shadow(color: .black.opacity(0.25), radius: active ? 6 : 2)
        }
        func makeUpperThumb(configuration: DoubleRSliderConfiguration) -> some View {
            let active = configuration.isUpperActive || configuration.isRangeActive
            return RoundedRectangle(cornerRadius: 6)
                .fill(active ? Color.teal : Color.white)
                .frame(width: 28, height: 28)
                .shadow(color: .black.opacity(0.25), radius: active ? 6 : 2)
        }
        func makeTrack(configuration: DoubleRSliderConfiguration) -> some View {
            let arcLength = configuration.upperPercent - configuration.lowerPercent
            return ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 18)
                CircularArc(percent: arcLength)
                    .stroke(Color.teal, style: StrokeStyle(lineWidth: 18, lineCap: .round))
                    .rotationEffect(configuration.lowerAngle)
            }
        }
    }

    struct Step3: View {
        @State private var lower = 0.25
        @State private var upper = 0.75
        var body: some View {
            DoubleRSlider(
                lowerValue: $lower,
                upperValue: $upper,
                range: 0...1
            )
            .doubleRadialSliderStyle(MyStyle())
            .frame(width: 220, height: 220)
            .padding()
        }
    }
    return Step3()
}

// Step 4 – Apply finished style with tick marks and affinity
#Preview("DoubleRSlider_Advanced_Step_4") {
    struct MyStyle: DoubleRSliderStyle {
        func makeLowerThumb(configuration: DoubleRSliderConfiguration) -> some View {
            let active = configuration.isLowerActive || configuration.isRangeActive
            return RoundedRectangle(cornerRadius: 6)
                .fill(active ? Color.teal : Color.white)
                .frame(width: 28, height: 28)
                .shadow(color: .black.opacity(0.25), radius: active ? 6 : 2)
        }
        func makeUpperThumb(configuration: DoubleRSliderConfiguration) -> some View {
            let active = configuration.isUpperActive || configuration.isRangeActive
            return RoundedRectangle(cornerRadius: 6)
                .fill(active ? Color.teal : Color.white)
                .frame(width: 28, height: 28)
                .shadow(color: .black.opacity(0.25), radius: active ? 6 : 2)
        }
        func makeTrack(configuration: DoubleRSliderConfiguration) -> some View {
            let arcLength = configuration.upperPercent - configuration.lowerPercent
            return ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 18)
                CircularArc(percent: arcLength)
                    .stroke(Color.teal, style: StrokeStyle(lineWidth: 18, lineCap: .round))
                    .rotationEffect(configuration.lowerAngle)
            }
        }
        func makeTickMark(configuration: DoubleRSliderConfiguration, tickValue: Double) -> some View {
            Circle()
                .fill(Color.white.opacity(0.5))
                .frame(width: 5, height: 5)
        }
    }

    struct Step4: View {
        @State private var lower = 0.2
        @State private var upper = 0.8
        var body: some View {
            DoubleRSlider(
                lowerValue: $lower,
                upperValue: $upper,
                range: 0...1,
                tickSpacing: .count(9),
                affinityEnabled: true
            )
            .doubleRadialSliderStyle(MyStyle())
            .frame(width: 240, height: 240)
            .padding()
        }
    }
    return Step4()
}
