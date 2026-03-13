// Swift toolchain version 6.0
// Running macOS version 26.3
// Created on 3/13/26.
//
// Author: Kieran Brown
//

import SwiftUI

// MARK: - Diagnostic Style

struct DiagnosticDoubleRSliderStyle: DoubleRSliderStyle {
    let thickness = 24.0

    func makeLowerThumb(configuration: DoubleRSliderConfiguration) -> some View {
        Circle()
            .foregroundStyle(configuration.isLowerActive ? Color.green : Color.white)
            .frame(width: thickness, height: thickness)
            .overlay(Circle().strokeBorder(Color.green, lineWidth: 2))
            .offset(x: -thickness / 2 * cos(configuration.lowerAngle.radians),
                    y: -thickness / 2 * sin(configuration.lowerAngle.radians))
    }

    func makeUpperThumb(configuration: DoubleRSliderConfiguration) -> some View {
        Circle()
            .foregroundStyle(configuration.isUpperActive ? Color.orange : Color.white)
            .frame(width: thickness, height: thickness)
            .overlay(Circle().strokeBorder(Color.orange, lineWidth: 2))
            .offset(x: -thickness / 2 * cos(configuration.upperAngle.radians),
                    y: -thickness / 2 * sin(configuration.upperAngle.radians))
    }

    func makeTrack(configuration: DoubleRSliderConfiguration) -> some View {
        let loPct = configuration.lowerPercent
        let hiPct = configuration.upperPercent
        let arcLen = hiPct - loPct

        return ZStack {
            Circle()
                .strokeBorder(Color.gray, lineWidth: thickness)

            CircularArc(percent: arcLen)
                .strokeBorder(
                    configuration.isRangeActive ? Color.yellow : Color.blue,
                    style: StrokeStyle(lineWidth: thickness, lineCap: .round)
                )
                .rotationEffect(configuration.lowerAngle)

            VStack(spacing: 2) {
                Text("low: \(configuration.lowerValue, format: .number.precision(.fractionLength(2)))")
                Text("hi:  \(configuration.upperValue, format: .number.precision(.fractionLength(2)))")
            }
            .font(.caption2.monospaced())
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - Previews

#Preview("Default Style") {
    @Previewable @State var lower = 0.2
    @Previewable @State var upper = 0.7

    VStack(spacing: 20) {
        DoubleRSlider(lowerValue: $lower, upperValue: $upper)
            .frame(width: 200, height: 200)

        DoubleRSlider(lowerValue: $lower, upperValue: $upper,
                      originAngle: .degrees(90))
            .frame(width: 200, height: 200)

        Text(String(format: "Range: %.2f – %.2f", lower, upper))
            .font(.caption)
    }
    .padding()
}

#Preview("Diagnostic Style") {
    @Previewable @State var lower = 0.25
    @Previewable @State var upper = 0.75

    VStack(spacing: 20) {
        HStack {
            DoubleRSlider(lowerValue: $lower, upperValue: $upper)
                .doubleRadialSliderStyle(DiagnosticDoubleRSliderStyle())
                .frame(width: 160, height: 160)

            DoubleRSlider(lowerValue: $lower, upperValue: $upper,
                          originAngle: .degrees(-90))
                .doubleRadialSliderStyle(DiagnosticDoubleRSliderStyle())
                .frame(width: 160, height: 160)
        }

        Text(String(format: "lower=%.3f  upper=%.3f", lower, upper))
            .font(.caption.monospaced())
    }
    .padding()
}

#Preview("Tick Marks + Affinity") {
    @Previewable @State var lower = 0.2
    @Previewable @State var upper = 0.6

    VStack(spacing: 20) {
        DoubleRSlider(lowerValue: $lower, upperValue: $upper,
                      tickSpacing: .count(13),
                      affinityEnabled: true)
            .frame(width: 220, height: 220)

        DoubleRSlider(lowerValue: $lower, upperValue: $upper,
                      tickSpacing: .spacing(0.1))
            .frame(width: 220, height: 220)

        Text(String(format: "Range: %.2f – %.2f", lower, upper))
            .font(.caption)
    }
    .padding()
}

#Preview("Range Drag Demo") {
    @Previewable @State var lower = 0.3
    @Previewable @State var upper = 0.6

    VStack(spacing: 20) {
        Text("Drag the blue arc to shift the range")
            .font(.caption)
            .multilineTextAlignment(.center)

        DoubleRSlider(lowerValue: $lower, upperValue: $upper,
                      originAngle: .degrees(180))
            .frame(width: 240, height: 240)

        Text(String(format: "%.2f → %.2f  (width: %.2f)", lower, upper, upper - lower))
            .font(.caption.monospaced())
    }
    .padding()
}

#Preview("Disabled") {
    @Previewable @State var lower = 0.3
    @Previewable @State var upper = 0.65

    DoubleRSlider(lowerValue: $lower, upperValue: $upper)
        .frame(width: 200, height: 200)
        .disabled(true)
        .padding()
}
