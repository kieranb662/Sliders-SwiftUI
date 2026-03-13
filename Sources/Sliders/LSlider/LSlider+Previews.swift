// Swift toolchain version 6.0
// Running macOS version 26.3
// Created on 3/12/26.
//
// Author: Kieran Brown
//

import SwiftUI

// MARK: - Preview Examples

#if !os(watchOS)
fileprivate struct LSliderExamples: View {
    @State var value1 = 0.5
    @State var value2 = 0.5
    @State var value3 = 3.0
    @State var value4 = 0.5
    @State var value5 = 0.5
    @State var value6 = 3.0

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // ── Basic slider (no tick marks) ──────────────────────────────
                GroupBox("Basic – No Tick Marks") {
                    LSlider($value1, range: 0...1, keepThumbInTrack: true, trackThickness: 20)
                        .allowsSingleTapSelect(true)
                        .frame(height: 60)
                }
                
                // ── Basic slider (no tick marks) ──────────────────────────────
                GroupBox("Disabled – No Tick Marks") {
                    LSlider($value1, range: 0...1, keepThumbInTrack: true, trackThickness: 20)
                        .allowsSingleTapSelect(true)
                        .disabled(true)
                        .frame(height: 60)
                }

                // ── Evenly-distributed tick mark count ───────────────────────
                GroupBox("count(11) — 11 evenly spaced ticks, haptics on") {
                    LSlider(
                        $value2,
                        range: 0...1,
                        keepThumbInTrack: true,
                        trackThickness: 20,
                        tickMarkSpacing: .count(11),
                        hapticFeedbackEnabled: true
                    )
                    .frame(height: 60)
                    Text("Value: \(value2, specifier: "%.2f")")
                        .font(.caption)
                }

                // ── Fixed-step spacing ────────────────────────────────────────
                GroupBox("spacing(1) — step every 1 unit, haptics on") {
                    LSlider(
                        $value3,
                        range: 0...10,
                        keepThumbInTrack: true,
                        trackThickness: 20,
                        tickMarkSpacing: .spacing(1),
                        hapticFeedbackEnabled: true
                    )
                    .frame(height: 60)
                    Text("Value: \(value3, specifier: "%.2f")")
                        .font(.caption)
                }

                // ── Explicit values ───────────────────────────────────────────
                GroupBox("values([0.0, 0.25, 0.5, 0.75, 1.0]) — haptics off") {
                    LSlider(
                        $value4,
                        range: 0...1,
                        keepThumbInTrack: true,
                        trackThickness: 20,
                        tickMarkSpacing: .values([0.0, 0.25, 0.5, 0.75, 1.0]),
                        hapticFeedbackEnabled: false
                    )
                    .frame(height: 60)
                    Text("Value: \(value4, specifier: "%.2f")")
                        .font(.caption)
                }

                // ── Affinity enabled (count) ──────────────────────────────────
                GroupBox("Affinity ON — count(11), radius 4%, resistance 3%") {
                    LSlider(
                        $value5,
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
                    Text("Value: \(value5, specifier: "%.2f")")
                        .font(.caption)
                }

                // ── Affinity enabled (spacing) ────────────────────────────────
                GroupBox("Affinity ON — spacing(1), radius 5%, resistance 3%") {
                    LSlider(
                        $value6,
                        range: 0...10,
                        keepThumbInTrack: true,
                        trackThickness: 20,
                        tickMarkSpacing: .spacing(1),
                        hapticFeedbackEnabled: true,
                        affinityEnabled: true,
                        affinityRadius: 0.05,
                        affinityResistance: 0.03
                    )
                    .frame(height: 60)
                    Text("Value: \(value6, specifier: "%.2f")")
                        .font(.caption)
                }

                // ── Diagonal slider with count-based ticks ───────────────────
                GroupBox("Diagonal (325°) with count(5) ticks + affinity") {
                    LSlider(
                        $value2,
                        range: 0...1,
                        angle: Angle(degrees: 325),
                        keepThumbInTrack: true,
                        trackThickness: 20,
                        tickMarkSpacing: .count(5),
                        hapticFeedbackEnabled: true,
                        affinityEnabled: true
                    )
                    .frame(height: 120)
                }

                // ── Custom style with tick marks ──────────────────────────────
                GroupBox("Custom BarLSliderStyle + spacing(0.1) ticks + affinity") {
                    LSlider(
                        $value1,
                        range: 0...1,
                        keepThumbInTrack: true,
                        trackThickness: 40,
                        tickMarkSpacing: .spacing(0.1),
                        hapticFeedbackEnabled: true,
                        affinityEnabled: true,
                        affinityRadius: 0.04,
                        affinityResistance: 0.02
                    )
                    .linearSliderStyle(BarLSliderStyle())
                    .frame(height: 60)
                    Text("Value: \(value1, specifier: "%.2f")")
                        .font(.caption)
                }
            }
            .padding()
        }
    }
}

// MARK: - Example Custom Style

/// A custom style that uses diamond-shaped tick marks.
private struct BarLSliderStyle: LSliderStyle {
    func makeThumb(configuration: LSliderConfiguration) -> some View {
        let isSnapped = configuration.snappedTickValue != nil
        return RoundedRectangle(cornerRadius: 4)
            .fill(
                configuration.isActive
                    ? (isSnapped ? Color.yellow : Color.orange)
                    : Color.white
            )
            .frame(
                width: configuration.trackThickness * 0.8,
                height: configuration.trackThickness * 1.4
            )
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.orange, lineWidth: isSnapped ? 2 : 0)
            )
            .shadow(radius: 3)
            .animation(.easeOut(duration: 0.1), value: isSnapped)
    }

    func makeTrack(configuration: LSliderConfiguration) -> some View {
        let adjustment: Double = configuration.keepThumbInTrack
            ? configuration.trackThickness * (1 - configuration.pctFill)
            : configuration.trackThickness / 2

        return ZStack {
            AdaptiveLine(thickness: configuration.trackThickness, angle: configuration.angle)
                .fill(Color(white: 0.2))
            AdaptiveLine(
                thickness: configuration.trackThickness,
                angle: configuration.angle,
                percentFilled: configuration.pctFill,
                cap: .square,
                adjustmentForThumb: adjustment / 2
            )
            .fill(Color.orange)
            .mask(AdaptiveLine(thickness: configuration.trackThickness, angle: configuration.angle))
        }
    }

    /// Diamond-shaped tick mark that grows when the thumb is near.
    func makeTickMark(configuration: LSliderConfiguration, tickValue: Double) -> some View {
        let range = configuration.max - configuration.min
        let thumbPct = range > 0 ? (configuration.value - configuration.min) / range : 0
        let tickPct  = range > 0 ? (tickValue           - configuration.min) / range : 0
        let distance  = abs(thumbPct - tickPct)
        let proximity = max(0, 1 - distance / 0.15)
        let isSnappedHere = configuration.snappedTickValue == tickValue

        let size    = 6.0 + 6.0 * proximity + (isSnappedHere ? 3.0 : 0)
        let opacity = 0.4 + 0.6 * proximity + (isSnappedHere ? 0.2 : 0)

        return Rectangle()
            .fill(Color.orange.opacity(min(opacity, 1.0)))
            .frame(width: size, height: size)
            .rotationEffect(.degrees(45))
            .animation(.easeOut(duration: 0.08), value: proximity)
            .animation(.easeOut(duration: 0.08), value: isSnappedHere)
    }
}


#else

fileprivate struct LSliderExamples: View {
    @State var value1 = 0.5
    @State var value2 = 0.5
    @State var value3 = 3.0
    @State var value4 = 0.5
    @State var value5 = 0.5
    @State var value6 = 3.0

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // ── Basic slider (no tick marks) ──────────────────────────────
                LSlider($value1, range: 0...1, keepThumbInTrack: true, trackThickness: 20)
                    .frame(height: 60)

                // ── Evenly-distributed tick mark count ───────────────────────
                LSlider(
                    $value2,
                    range: 0...1,
                    keepThumbInTrack: true,
                    trackThickness: 20,
                    tickMarkSpacing: .count(11),
                    hapticFeedbackEnabled: true
                )
                .frame(height: 60)
                Text("Value: \(value2, specifier: "%.2f")")
                    .font(.caption)

                // ── Fixed-step spacing ────────────────────────────────────────
                LSlider(
                    $value3,
                    range: 0...10,
                    keepThumbInTrack: true,
                    trackThickness: 20,
                    tickMarkSpacing: .spacing(1),
                    hapticFeedbackEnabled: true
                )
                .frame(height: 60)
                Text("Value: \(value3, specifier: "%.2f")")
                    .font(.caption)

                // ── Explicit values ───────────────────────────────────────────
                LSlider(
                    $value4,
                    range: 0...1,
                    keepThumbInTrack: true,
                    trackThickness: 20,
                    tickMarkSpacing: .values([0.0, 0.25, 0.5, 0.75, 1.0]),
                    hapticFeedbackEnabled: false
                )
                .frame(height: 60)
                Text("Value: \(value4, specifier: "%.2f")")
                    .font(.caption)

                // ── Affinity enabled (count) ──────────────────────────────────
                LSlider(
                    $value5,
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
                Text("Value: \(value5, specifier: "%.2f")")
                    .font(.caption)

                // ── Affinity enabled (spacing) ────────────────────────────────
                LSlider(
                    $value6,
                    range: 0...10,
                    keepThumbInTrack: true,
                    trackThickness: 20,
                    tickMarkSpacing: .spacing(1),
                    hapticFeedbackEnabled: true,
                    affinityEnabled: true,
                    affinityRadius: 0.05,
                    affinityResistance: 0.03
                )
                .frame(height: 60)
                Text("Value: \(value6, specifier: "%.2f")")
                    .font(.caption)
                
                // ── Diagonal slider with count-based ticks ───────────────────
                LSlider(
                    $value2,
                    range: 0...1,
                    angle: Angle(degrees: 325),
                    keepThumbInTrack: true,
                    trackThickness: 20,
                    tickMarkSpacing: .count(5),
                    hapticFeedbackEnabled: true,
                    affinityEnabled: true
                )
                .frame(height: 120)
            }
            .padding()
        }
    }
}

#endif


#Preview {
    LSliderExamples()
}
