// Swift toolchain version 6.0
// Running macOS version 26.3
// Created on 3/13/26.
//
// Author: Kieran Brown
//
// Tutorial step previews for the RSlider DocC tutorials.
// Basics:   RSlider_Basics_Step_1  … RSlider_Basics_Step_7
// Advanced: RSlider_Advanced_Step_1 … RSlider_Advanced_Step_5

import SwiftUI

// MARK: - Basics

// Step 1 – Minimal RSlider with all defaults
#Preview("RSlider_Basics_Step_1") {
    struct Step1: View {
        @State private var value = 0.5
        var body: some View {
            RSlider($value)
                .frame(width: 180, height: 180)
                .padding()
        }
    }
    return Step1()
}

// Step 2 – Custom range and originAngle
#Preview("RSlider_Basics_Step_2") {
    struct Step2: View {
        @State private var temperature = 20.0
        var body: some View {
            RSlider($temperature, range: 0...100, originAngle: .degrees(90))
                .frame(width: 220, height: 220)
                .padding()
        }
    }
    return Step2()
}

// Step 3 – Multiple winds
#Preview("RSlider_Basics_Step_3") {
    struct Step3: View {
        @State private var value = 0.0
        var body: some View {
            RSlider($value, range: 0...1, maxWinds: 3)
                .frame(width: 220, height: 220)
                .padding()
        }
    }
    return Step3()
}

// Step 4 – Tick marks .count(11)
#Preview("RSlider_Basics_Step_4") {
    struct Step4: View {
        @State private var stepped = 0.5
        var body: some View {
            RSlider($stepped, range: 0...1, tickSpacing: .count(11))
                .frame(width: 220, height: 220)
                .padding()
        }
    }
    return Step4()
}

// Step 5 – Tick marks .spacing(1)
#Preview("RSlider_Basics_Step_5") {
    struct Step5: View {
        @State private var value = 3.0
        var body: some View {
            RSlider($value, range: 0...10, tickSpacing: .spacing(1))
                .frame(width: 220, height: 220)
                .padding()
        }
    }
    return Step5()
}

// Step 6 – Affinity snapping
#Preview("RSlider_Basics_Step_6") {
    struct Step6: View {
        @State private var snapped = 0.5
        var body: some View {
            RSlider(
                $snapped,
                range: 0...1,
                tickSpacing: .count(11),
                affinityEnabled: true,
                affinityRadius: 0.02,
                affinityResistance: 0.01
            )
            .frame(width: 220, height: 220)
            .padding()
        }
    }
    return Step6()
}

// Step 7 – Custom label and disabled state
#Preview("RSlider_Basics_Step_7") {
    struct Step7: View {
        @State private var speed = 0.5
        var body: some View {
            VStack(spacing: 30) {
                RSlider($speed, range: 0...200) { value in
                    Text("\(Int(value)) km/h")
                }
                .frame(width: 220, height: 220)

                RSlider(.constant(100), range: 0...200)
                    .disabled(true)
                    .frame(width: 220, height: 220)
            }
            .padding()
        }
    }
    return Step7()
}

// MARK: - Advanced

// Step 1 – Declare MyRSliderStyle with stub implementations
#Preview("RSlider_Advanced_Step_1") {
    struct MyStyle: RSliderStyle {
        func makeThumb(configuration: RSliderConfiguration) -> some View {
            Circle()
                .fill(Color.gray)
                .frame(width: 28, height: 28)
        }
        func makeTrack(configuration: RSliderConfiguration) -> some View {
            Circle()
                .stroke(Color.gray.opacity(0.4), lineWidth: 18)
                .padding(9)
        }
        func makeTickMark(configuration: RSliderConfiguration, tickValue: Double) -> some View {
            Circle()
                .fill(Color.gray)
                .frame(width: 4, height: 4)
        }
    }

    struct Step1: View {
        @State private var value = 0.5
        var body: some View {
            RSlider($value, range: 0...1, tickSpacing: .count(11))
                .radialSliderStyle(MyStyle())
                .frame(width: 220, height: 220)
                .padding()
        }
    }
    return Step1()
}

// Step 2 – Implement makeTrack with CircularArc
#Preview("RSlider_Advanced_Step_2") {
    struct MyStyle: RSliderStyle {
        func makeThumb(configuration: RSliderConfiguration) -> some View {
            Circle()
                .fill(Color.gray)
                .frame(width: 28, height: 28)
        }
        func makeTrack(configuration: RSliderConfiguration) -> some View {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 18)
                CircularArc(percent: configuration.withinWind)
                    .stroke(Color.cyan, style: StrokeStyle(lineWidth: 18, lineCap: .round))
            }
        }
        func makeTickMark(configuration: RSliderConfiguration, tickValue: Double) -> some View {
            Circle()
                .fill(Color.gray)
                .frame(width: 4, height: 4)
        }
    }

    struct Step2: View {
        @State private var value = 0.5
        var body: some View {
            RSlider($value, range: 0...1, tickSpacing: .count(11))
                .radialSliderStyle(MyStyle())
                .frame(width: 220, height: 220)
                .padding()
        }
    }
    return Step2()
}

// Step 3 – Implement makeThumb
#Preview("RSlider_Advanced_Step_3") {
    struct MyStyle: RSliderStyle {
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
        }
        func makeTickMark(configuration: RSliderConfiguration, tickValue: Double) -> some View {
            Circle()
                .fill(Color.gray)
                .frame(width: 4, height: 4)
        }
    }

    struct Step3: View {
        @State private var value = 0.5
        var body: some View {
            RSlider($value, range: 0...1, tickSpacing: .count(11))
                .radialSliderStyle(MyStyle())
                .frame(width: 220, height: 220)
                .padding()
        }
    }
    return Step3()
}

// Step 4 – Implement makeTickMark with proximity glow
#Preview("RSlider_Advanced_Step_4") {
    struct MyStyle: RSliderStyle {
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

    struct Step4: View {
        @State private var value = 0.5
        var body: some View {
            RSlider($value, range: 0...1, tickSpacing: .count(11))
                .radialSliderStyle(MyStyle())
                .frame(width: 220, height: 220)
                .padding()
        }
    }
    return Step4()
}

// Step 5 – Apply finished style to multiple sliders
#Preview("RSlider_Advanced_Step_5") {
    struct MyStyle: RSliderStyle {
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
                    .rotationEffect(configuration.originAngle)
            }
           
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

    struct Step5: View {
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
            .radialSliderStyle(MyStyle())
            .padding()
        }
    }
    return Step5()
}
