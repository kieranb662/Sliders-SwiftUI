// Swift toolchain version 6.0
// Running macOS version 26.3
// Created on 3/13/26.
//
// Author: Kieran Brown
//
// Tutorial step previews for the LSlider DocC tutorials.
// Basics:  LSlider_Basics_Step_1  … LSlider_Basics_Step_11
// Advanced: LSlider_Advanced_Step_1 … LSlider_Advanced_Step_6

import SwiftUI

// MARK: - Basics

// Step 1 – Minimal LSlider with all defaults
#Preview("LSlider_Basics_Step_1") {
    struct Step1: View {
        @State private var value = 0.5
        var body: some View {
            LSlider($value)
                .frame(height: 60)
                .padding()
        }
    }
    return Step1()
}

// Step 2 – Custom range and trackThickness
#Preview("LSlider_Basics_Step_2") {
    struct Step2: View {
        @State private var value = 5.0
        var body: some View {
            VStack(spacing: 8) {
                LSlider($value, range: 0...10, trackThickness: 28)
                    .frame(height: 72)
                Text("Value: \(value, specifier: "%.1f")")
                    .font(.caption)
            }
            .padding()
        }
    }
    return Step2()
}

// Step 3 – Custom angle (diagonal slider)
#Preview("LSlider_Basics_Step_3") {
    struct Step3: View {
        @State private var value = 0.5
        var body: some View {
            LSlider($value, range: 0...1, angle: Angle(degrees: 315), trackThickness: 20)
                .frame(width: 200, height: 200)
                .padding()
        }
    }
    return Step3()
}

// Step 4 – keepThumbInTrack
#Preview("LSlider_Basics_Step_4") {
    struct Step4: View {
        @State private var value1 = 0.5
        @State private var value2 = 0.5
        var body: some View {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("keepThumbInTrack: false (default)")
                        .font(.caption2).foregroundStyle(.secondary)
                    LSlider($value1, range: 0...1, keepThumbInTrack: false, trackThickness: 20)
                        .frame(height: 60)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("keepThumbInTrack: true")
                        .font(.caption2).foregroundStyle(.secondary)
                    LSlider($value2, range: 0...1, keepThumbInTrack: true, trackThickness: 20)
                        .frame(height: 60)
                }
            }
            .padding()
        }
    }
    return Step4()
}

// Step 5 – tickMarkSpacing .count(N)
#Preview("LSlider_Basics_Step_5") {
    struct Step5: View {
        @State private var value = 0.5
        var body: some View {
            VStack(spacing: 8) {
                LSlider(
                    $value,
                    range: 0...1,
                    keepThumbInTrack: true,
                    trackThickness: 20,
                    tickMarkSpacing: .count(11),
                    hapticFeedbackEnabled: true
                )
                .frame(height: 60)
                Text("Value: \(value, specifier: "%.2f")")
                    .font(.caption)
            }
            .padding()
        }
    }
    return Step5()
}

// Step 6 – tickMarkSpacing .spacing(step)
#Preview("LSlider_Basics_Step_6") {
    struct Step6: View {
        @State private var value = 5.0
        var body: some View {
            VStack(spacing: 8) {
                LSlider(
                    $value,
                    range: 0...10,
                    keepThumbInTrack: true,
                    trackThickness: 20,
                    tickMarkSpacing: .spacing(1),
                    hapticFeedbackEnabled: true
                )
                .frame(height: 60)
                Text("Value: \(value, specifier: "%.1f")")
                    .font(.caption)
            }
            .padding()
        }
    }
    return Step6()
}

// Step 7 – tickMarkSpacing .values([...])
#Preview("LSlider_Basics_Step_7") {
    struct Step7: View {
        @State private var value = 0.5
        var body: some View {
            VStack(spacing: 8) {
                LSlider(
                    $value,
                    range: 0...1,
                    keepThumbInTrack: true,
                    trackThickness: 20,
                    tickMarkSpacing: .values([0.0, 0.25, 0.5, 0.75, 1.0]),
                    hapticFeedbackEnabled: false
                )
                .frame(height: 60)
                Text("Value: \(value, specifier: "%.2f")")
                    .font(.caption)
            }
            .padding()
        }
    }
    return Step7()
}

// Step 8 – affinityEnabled with affinityRadius and affinityResistance
#Preview("LSlider_Basics_Step_8") {
    struct Step8: View {
        @State private var value = 0.5
        var body: some View {
            VStack(spacing: 8) {
                LSlider(
                    $value,
                    range: 0...1,
                    keepThumbInTrack: true,
                    trackThickness: 20,
                    tickMarkSpacing: .count(11),
                    hapticFeedbackEnabled: true,
                    affinityEnabled: true,
                    affinityRadius: 0.04,
                    affinityResistance: 0.03
                )
                .frame(height: 60)
                Text("Value: \(value, specifier: "%.2f")")
                    .font(.caption)
            }
            .padding()
        }
    }
    return Step8()
}

// Step 9 – allowsSingleTapSelect
#Preview("LSlider_Basics_Step_9") {
    struct Step9: View {
        @State private var value = 0.5
        var body: some View {
            VStack(spacing: 8) {
                LSlider($value, range: 0...1, keepThumbInTrack: true, trackThickness: 20)
                    .allowsSingleTapSelect(true)
                    .frame(height: 60)
                Text("Tap anywhere on the track to jump")
                    .font(.caption).foregroundStyle(.secondary)
            }
            .padding()
        }
    }
    return Step9()
}

// Step 10 – Custom label closure
#Preview("LSlider_Basics_Step_10") {
    struct Step10: View {
        @State private var volume = 50.0
        var body: some View {
            LSlider($volume, range: 0...100, keepThumbInTrack: true, trackThickness: 20) { value in
                Label("\(Int(value)) dB", systemImage: "speaker.wave.2")
                    .font(.caption.bold())
            }
            .frame(height: 80)
            .padding()
        }
    }
    return Step10()
}

// Step 11 – Disabled state
#Preview("LSlider_Basics_Step_11") {
    struct Step11: View {
        @State private var value = 0.5
        var body: some View {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Enabled").font(.caption2).foregroundStyle(.secondary)
                    LSlider($value, range: 0...1, keepThumbInTrack: true, trackThickness: 20)
                        .frame(height: 60)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Disabled").font(.caption2).foregroundStyle(.secondary)
                    LSlider($value, range: 0...1, keepThumbInTrack: true, trackThickness: 20)
                        .disabled(true)
                        .frame(height: 60)
                }
            }
            .padding()
        }
    }
    return Step11()
}

// MARK: - Advanced

// Step 1 – Declare MyLSliderStyle struct with stub implementations
#Preview("LSlider_Advanced_Step_1") {
    struct MyLSliderStyle: LSliderStyle {
        func makeThumb(configuration: LSliderConfiguration) -> some View {
            Circle()
                .fill(Color.gray)
                .frame(width: configuration.trackThickness * 2,
                       height: configuration.trackThickness * 2)
        }

        func makeTrack(configuration: LSliderConfiguration) -> some View {
            AdaptiveLine(thickness: configuration.trackThickness, angle: configuration.angle)
                .fill(Color.gray.opacity(0.4))
        }

        func makeTickMark(configuration: LSliderConfiguration, tickValue: Double) -> some View {
            Circle()
                .fill(Color.gray)
                .frame(width: 4, height: 4)
        }
    }

    struct Step1: View {
        @State private var value = 0.5
        var body: some View {
            LSlider($value, range: 0...1, keepThumbInTrack: true, trackThickness: 20)
                .linearSliderStyle(MyLSliderStyle())
                .frame(height: 60)
                .padding()
        }
    }
    return Step1()
}

// Step 2 – Implement makeTrack
#Preview("LSlider_Advanced_Step_2") {
    struct MyLSliderStyle: LSliderStyle {
        func makeThumb(configuration: LSliderConfiguration) -> some View {
            Circle()
                .fill(Color.gray)
                .frame(width: configuration.trackThickness * 2,
                       height: configuration.trackThickness * 2)
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

    struct Step2: View {
        @State private var value = 0.5
        var body: some View {
            LSlider($value, range: 0...1, keepThumbInTrack: true, trackThickness: 20)
                .linearSliderStyle(MyLSliderStyle())
                .frame(height: 60)
                .padding()
        }
    }
    return Step2()
}

// Step 3 – Implement makeThumb
#Preview("LSlider_Advanced_Step_3") {
    struct MyLSliderStyle: LSliderStyle {
        func makeThumb(configuration: LSliderConfiguration) -> some View {
            let color: Color = configuration.isDisabled
                ? Color.gray
                : (configuration.isActive ? Color.white : Color.indigo)
            return Circle()
                .fill(color)
                .frame(width: configuration.trackThickness * 2,
                       height: configuration.trackThickness * 2)
                .shadow(color: .black.opacity(configuration.isDisabled ? 0 : 0.2),
                        radius: configuration.isActive ? 6 : 2)
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

    struct Step3: View {
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
    return Step3()
}

// Step 4 – Implement makeTickMark
#Preview("LSlider_Advanced_Step_4") {
    struct MyLSliderStyle: LSliderStyle {
        func makeThumb(configuration: LSliderConfiguration) -> some View {
            let color: Color = configuration.isDisabled
                ? Color.gray
                : (configuration.isActive ? Color.white : Color.indigo)
            return Circle()
                .fill(color)
                .frame(width: configuration.trackThickness * 2,
                       height: configuration.trackThickness * 2)
                .shadow(color: .black.opacity(configuration.isDisabled ? 0 : 0.2),
                        radius: configuration.isActive ? 6 : 2)
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
    }

    struct Step4: View {
        @State private var value = 0.5
        var body: some View {
            VStack(spacing: 8) {
                LSlider(
                    $value,
                    range: 0...1,
                    keepThumbInTrack: true,
                    trackThickness: 20,
                    tickMarkSpacing: .count(11)
                )
                .linearSliderStyle(MyLSliderStyle())
                .frame(height: 60)
                Text("Value: \(value, specifier: "%.2f")")
                    .font(.caption)
            }
            .padding()
        }
    }
    return Step4()
}

// Step 5 – Implement makeLabel
#Preview("LSlider_Advanced_Step_5") {
    struct MyLSliderStyle: LSliderStyle {
        func makeThumb(configuration: LSliderConfiguration) -> some View {
            let color: Color = configuration.isDisabled
                ? Color.gray
                : (configuration.isActive ? Color.white : Color.indigo)
            return Circle()
                .fill(color)
                .frame(width: configuration.trackThickness * 2,
                       height: configuration.trackThickness * 2)
                .shadow(color: .black.opacity(configuration.isDisabled ? 0 : 0.2),
                        radius: configuration.isActive ? 6 : 2)
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

    struct Step5: View {
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
    return Step5()
}

// Step 6 – Apply the finished style with .linearSliderStyle(MyLSliderStyle())
#Preview("LSlider_Advanced_Step_6") {
    struct MyLSliderStyle: LSliderStyle {
        func makeThumb(configuration: LSliderConfiguration) -> some View {
            let color: Color = configuration.isDisabled
                ? Color.gray
                : (configuration.isActive ? Color.white : Color.indigo)
            return Circle()
                .fill(color)
                .frame(width: configuration.trackThickness * 2,
                       height: configuration.trackThickness * 2)
                .shadow(color: .black.opacity(configuration.isDisabled ? 0 : 0.2),
                        radius: configuration.isActive ? 6 : 2)
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

    struct Step6: View {
        @State private var value1 = 0.5
        @State private var value2 = 0.5
        var body: some View {
            VStack(spacing: 20) {
                LSlider(
                    $value1,
                    range: 0...1,
                    keepThumbInTrack: true,
                    trackThickness: 20,
                    tickMarkSpacing: .count(11),
                    affinityEnabled: true
                )
                .linearSliderStyle(MyLSliderStyle())
                .frame(height: 80)

                LSlider(
                    $value2,
                    range: 0...1,
                    angle: Angle(degrees: 315),
                    keepThumbInTrack: true,
                    trackThickness: 20,
                    tickMarkSpacing: .count(5),
                    affinityEnabled: true
                )
                .linearSliderStyle(MyLSliderStyle())
                .frame(width: 200, height: 200)
            }
            .padding()
        }
    }
    return Step6()
}
