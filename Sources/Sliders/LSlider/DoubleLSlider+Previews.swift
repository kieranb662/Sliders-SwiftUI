// Swift toolchain version 6.0
// Running macOS version 26.3
// Created on 3/13/26.
//
// Author: Kieran Brown
//

import SwiftUI

// MARK: - Diagnostic Style

/// A diagnostic style that prints live values and highlights each draggable element
/// with a distinct colour so the three gesture regions are immediately visible.
fileprivate struct DiagnosticDoubleLSliderStyle: DoubleLSliderStyle {
    let thickness = 20.0

    func makeLowerThumb(configuration: DoubleLSliderConfiguration) -> some View {
        Circle()
            .foregroundStyle(configuration.isLowerActive ? Color.green : Color.white)
            .frame(width: thickness * 2, height: thickness * 2)
            .overlay(Circle().strokeBorder(Color.green, lineWidth: 2))
    }

    func makeUpperThumb(configuration: DoubleLSliderConfiguration) -> some View {
        Circle()
            .foregroundStyle(configuration.isUpperActive ? Color.orange : Color.white)
            .frame(width: thickness * 2, height: thickness * 2)
            .overlay(Circle().strokeBorder(Color.orange, lineWidth: 2))
    }

    func makeTrack(configuration: DoubleLSliderConfiguration) -> some View {
        ZStack {
            AdaptiveLine(thickness: thickness, angle: configuration.angle)
                .fill(Color(.sRGB, red: 0.55, green: 0.55, blue: 0.59))

            // Filled region between the two thumbs
            AdaptiveLine(
                thickness: thickness,
                angle: configuration.angle,
                percentFilled: configuration.upperPercent,
                adjustmentForThumb: thickness / 2
            )
            .fill(configuration.isRangeActive ? Color.yellow : Color.blue)
            .mask(
                AdaptiveLine(
                    thickness: thickness,
                    angle: configuration.angle,
                    percentFilled: 1 - configuration.lowerPercent,
                    adjustmentForThumb: thickness / 2
                )
                .fill(Color.white)
                .rotationEffect(.degrees(180))
            )
            .mask(AdaptiveLine(thickness: thickness, angle: configuration.angle))

            VStack(spacing: 2) {
                Text("low: \(configuration.lowerValue, format: .number.precision(.fractionLength(2)))")
                Text("hi:  \(configuration.upperValue, format: .number.precision(.fractionLength(2)))")
            }
            .font(.caption2.monospaced())
            .foregroundStyle(Color.white)
        }
    }
}

// MARK: - Preview Examples

#if !os(watchOS)
fileprivate struct DoubleLSliderExamples: View {
    @State var lower1 = 0.2; @State var upper1 = 0.7
    @State var lower2 = 0.2; @State var upper2 = 0.7
    @State var lower3 = 2.0; @State var upper3 = 7.0
    @State var lower4 = 0.2; @State var upper4 = 0.7
    @State var lower5 = 0.2; @State var upper5 = 0.7
    @State var lower6 = 2.0; @State var upper6 = 7.0
    @State var lowerD = 0.2; @State var upperD = 0.7

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // ── Basic (no tick marks) ─────────────────────────────────────
                GroupBox("Basic – No Tick Marks") {
                    DoubleLSlider(
                        lowerValue: $lower1,
                        upperValue: $upper1,
                        range: 0...1,
                        keepThumbInTrack: true,
                        trackThickness: 20
                    )
                    .frame(height: 60)
                    Text("[\(lower1, specifier: "%.2f"), \(upper1, specifier: "%.2f")]")
                        .font(.caption)
                }
                
                // ── Basic (no tick marks) ─────────────────────────────────────
                GroupBox("Disabeld – No Tick Marks") {
                    DoubleLSlider(
                        lowerValue: $lower1,
                        upperValue: $upper1,
                        range: 0...1,
                        keepThumbInTrack: true,
                        trackThickness: 20
                    )
                    .disabled(true)
                    .frame(height: 60)
                    Text("[\(lower1, specifier: "%.2f"), \(upper1, specifier: "%.2f")]")
                        .font(.caption)
                }

                // ── count(11) tick marks with haptics ─────────────────────────
                GroupBox("count(11) — 11 evenly spaced ticks, haptics on") {
                    DoubleLSlider(
                        lowerValue: $lower2,
                        upperValue: $upper2,
                        range: 0...1,
                        keepThumbInTrack: true,
                        trackThickness: 20,
                        tickMarkSpacing: .count(11),
                        hapticFeedbackEnabled: true
                    )
                    .frame(height: 60)
                    .labelsHidden()
                    Text("[\(lower2, specifier: "%.2f"), \(upper2, specifier: "%.2f")]")
                        .font(.caption)
                }

                // ── spacing(1) tick marks ─────────────────────────────────────
                GroupBox("spacing(1) — step every 1 unit, range 0…10") {
                    DoubleLSlider(
                        lowerValue: $lower3,
                        upperValue: $upper3,
                        range: 0...10,
                        keepThumbInTrack: true,
                        trackThickness: 20,
                        tickMarkSpacing: .spacing(1),
                        hapticFeedbackEnabled: true
                    )
                    .frame(height: 60)
                    Text("[\(lower3, specifier: "%.1f"), \(upper3, specifier: "%.1f")]")
                        .font(.caption)
                }

                // ── Explicit values ───────────────────────────────────────────
                GroupBox("values([0.0, 0.25, 0.5, 0.75, 1.0]) — haptics off") {
                    DoubleLSlider(
                        lowerValue: $lower4,
                        upperValue: $upper4,
                        range: 0...1,
                        keepThumbInTrack: true,
                        trackThickness: 20,
                        tickMarkSpacing: .values([0.0, 0.25, 0.5, 0.75, 1.0]),
                        hapticFeedbackEnabled: false
                    )
                    .frame(height: 60)
                    Text("[\(lower4, specifier: "%.2f"), \(upper4, specifier: "%.2f")]")
                        .font(.caption)
                }

                // ── Affinity (magnetic snap) ──────────────────────────────────
                GroupBox("Affinity ON — count(11), radius 4%, resistance 3%") {
                    DoubleLSlider(
                        lowerValue: $lower5,
                        upperValue: $upper5,
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
                    Text("[\(lower5, specifier: "%.2f"), \(upper5, specifier: "%.2f")]")
                        .font(.caption)
                }

                // ── Angled slider ─────────────────────────────────────────────
                GroupBox("Angled — 30°, spacing(1), range 0…10") {
                    DoubleLSlider(
                        lowerValue: $lower6,
                        upperValue: $upper6,
                        range: 0...10,
                        angle: .degrees(30),
                        keepThumbInTrack: true,
                        trackThickness: 20,
                        tickMarkSpacing: .spacing(1)
                    )
                    .frame(height: 120)
                    Text("[\(lower6, specifier: "%.1f"), \(upper6, specifier: "%.1f")]")
                        .font(.caption)
                }

                // ── Diagnostic style ──────────────────────────────────────────
                GroupBox("Diagnostic — colour-coded gesture regions") {
                    DoubleLSlider(
                        lowerValue: $lowerD,
                        upperValue: $upperD,
                        range: 0...1,
                        keepThumbInTrack: true,
                        trackThickness: 20
                    )
                    .doubleLSliderStyle(DiagnosticDoubleLSliderStyle())
                    .frame(height: 60)
                    Text("Green = lower, Orange = upper, Yellow = range drag")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                // ── Disabled state ────────────────────────────────────────────
                GroupBox("Disabled") {
                    DoubleLSlider(
                        lowerValue: .constant(0.3),
                        upperValue: .constant(0.7),
                        range: 0...1,
                        keepThumbInTrack: true,
                        trackThickness: 20
                    )
                    .frame(height: 60)
                    .disabled(true)
                }
            }
            .padding()
        }
    }
}

#Preview("DoubleLSlider") {
    DoubleLSliderExamples()
        .preferredColorScheme(.dark)
}
#endif
