//
//  LSlider.swift
//  MyExamples
//
//  Created by Kieran Brown on 4/6/20.
//  Copyright © 2020 BrownandSons. All rights reserved.
//

import SwiftUI

// MARK: - LSlider
/// # Spatially Adaptive Linear Slider
///
/// A fully stylable linear slider that can be placed at any angle.  Tick marks can be
/// added via the `tickMarkSpacing` parameter and will optionally play haptic feedback
/// when the thumb passes over them.
///
/// - parameters:
///     - value: `Binding<Double>` The value the slider should control
///     - range: `ClosedRange<Double>` The minimum and maximum numbers that `value` can be
///     - angle: `Angle` The angle you would like the slider to be at
///     - isDisabled: `Bool` Whether or not the slider should be disabled
///     - keepThumbInTrack: `Bool` Whether the thumb is constrained to stay within the track's extent
///     - trackThickness: `Double` The thickness of the track
///     - tickMarkSpacing: `TickMarkSpacing?` How tick marks should be spaced, or `nil` to hide them
///     - hapticFeedbackEnabled: `Bool` Whether crossing a tick mark triggers haptic feedback
///
/// ## Styling The Slider
///
/// Conform to `LSliderStyle` and implement:
///   - `makeThumb` – the draggable thumb view
///   - `makeTrack` – the track/fill view
///   - `makeTickMark(configuration:tickValue:)` – the view shown at each tick position
///
/// Apply your style with `.linearSliderStyle(MyStyle())`.
public struct LSlider: View {
    // MARK: State and Setup
    @Environment(\.linearSliderStyle) private var style: AnyLSliderStyle
    @StateObject private var hapticManager = LSliderHapticManager()
    @State private var isActive: Bool = false
    @State private var atLimit: Bool = false
    /// The last tick value the thumb was snapped near, used to avoid re-firing haptics.
    @State private var lastHapticTickValue: Double? = nil
    private let space: String = "Slider"

    // MARK: Input
    @Binding private var value: Double
    private var range: ClosedRange<Double> = 0...1
    private var angle: Angle = .zero
    private var isDisabled: Bool = false
    private var keepThumbInTrack: Bool = false
    private var trackThickness: Double = 40
    private var tickMarkSpacing: TickMarkSpacing? = nil
    private var hapticFeedbackEnabled: Bool = true

    // MARK: - Initialisers

    public init(
        _ value: Binding<Double>,
        range: ClosedRange<Double>,
        angle: Angle,
        isDisabled: Bool = false,
        keepThumbInTrack: Bool = false,
        trackThickness: Double = 40,
        tickMarkSpacing: TickMarkSpacing? = nil,
        hapticFeedbackEnabled: Bool = true
    ) {
        self._value = value
        self.range = range
        self.angle = angle
        self.isDisabled = isDisabled
        self.keepThumbInTrack = keepThumbInTrack
        self.trackThickness = trackThickness
        self.tickMarkSpacing = tickMarkSpacing
        self.hapticFeedbackEnabled = hapticFeedbackEnabled
    }

    public init(
        _ value: Binding<Double>,
        range: ClosedRange<Double>,
        isDisabled: Bool = false,
        keepThumbInTrack: Bool = false,
        trackThickness: Double = 40,
        tickMarkSpacing: TickMarkSpacing? = nil,
        hapticFeedbackEnabled: Bool = true
    ) {
        self._value = value
        self.range = range
        self.isDisabled = isDisabled
        self.keepThumbInTrack = keepThumbInTrack
        self.trackThickness = trackThickness
        self.tickMarkSpacing = tickMarkSpacing
        self.hapticFeedbackEnabled = hapticFeedbackEnabled
    }

    public init(
        _ value: Binding<Double>,
        angle: Angle,
        isDisabled: Bool = false,
        keepThumbInTrack: Bool = false,
        trackThickness: Double = 40,
        tickMarkSpacing: TickMarkSpacing? = nil,
        hapticFeedbackEnabled: Bool = true
    ) {
        self._value = value
        self.angle = angle
        self.isDisabled = isDisabled
        self.keepThumbInTrack = keepThumbInTrack
        self.trackThickness = trackThickness
        self.tickMarkSpacing = tickMarkSpacing
        self.hapticFeedbackEnabled = hapticFeedbackEnabled
    }

    public init(_ value: Binding<Double>) {
        self._value = value
    }

    // MARK: - Tick Mark Value Resolution

    /// Resolves the `tickMarkSpacing` into concrete values within the slider's range.
    private func resolveTickValues() -> [Double] {
        let lo = range.lowerBound
        let hi = range.upperBound
        guard hi > lo else { return [] }

        switch tickMarkSpacing {
        case .none:
            return []
        case .spacing(let step) where step > 0:
            var ticks: [Double] = []
            var v = lo
            while v <= hi + step * 1e-9 {
                ticks.append(min(v, hi))
                v += step
            }
            return ticks
        case .count(let n) where n >= 2:
            return (0..<n).map { i in
                lo + Double(i) / Double(n - 1) * (hi - lo)
            }
        case .count:
            return [lo]
        case .values(let vals):
            return vals.filter { $0 >= lo && $0 <= hi }.sorted()
        default:
            return []
        }
    }

    // MARK: - Calculations

    private func calculateEndPoints(_ proxy: GeometryProxy) -> (start: CGPoint, end: CGPoint) {
        let w = Double(proxy.size.width)
        let h = Double(proxy.size.height)
        let T = trackThickness

        let θ = angle.radians
        let absCos = abs(cos(θ))
        let absSin = abs(sin(θ))
        let epsilon: Double = 1e-10

        let capsuleMaxFromWidth:  Double = absCos > epsilon ? (w - T) / absCos + T : .infinity
        let capsuleMaxFromHeight: Double = absSin > epsilon ? (h - T) / absSin + T : .infinity
        let capsuleLength = max(0, min(capsuleMaxFromWidth, capsuleMaxFromHeight))

        let halfTravel: Double
        if keepThumbInTrack {
            halfTravel = (capsuleLength - T) / 2
        } else {
            halfTravel = capsuleLength / 2
        }

        let cx = w / 2
        let cy = h / 2
        let dx = cos(θ)
        let dy = sin(θ)

        let start = CGPoint(x: cx - halfTravel * dx, y: cy - halfTravel * dy)
        let end   = CGPoint(x: cx + halfTravel * dx, y: cy + halfTravel * dy)
        return (start, end)
    }

    private func thumbOffset(_ proxy: GeometryProxy) -> CGSize {
        let ends = calculateEndPoints(proxy)
        let pct = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        let x = (1 - pct) * Double(ends.start.x) + pct * Double(ends.end.x) - Double(proxy.size.width  / 2)
        let y = (1 - pct) * Double(ends.start.y) + pct * Double(ends.end.y) - Double(proxy.size.height / 2)
        return CGSize(width: x, height: y)
    }

    /// Returns the offset from the ZStack centre for a tick mark at `tickValue`.
    private func tickMarkOffset(_ proxy: GeometryProxy, tickValue: Double) -> CGSize {
        let ends = calculateEndPoints(proxy)
        let range = range.upperBound - range.lowerBound
        let pct = range > 0 ? (tickValue - self.range.lowerBound) / range : 0
        let x = (1 - pct) * Double(ends.start.x) + pct * Double(ends.end.x) - Double(proxy.size.width  / 2)
        let y = (1 - pct) * Double(ends.start.y) + pct * Double(ends.end.y) - Double(proxy.size.height / 2)
        return CGSize(width: x, height: y)
    }

    private var configuration: LSliderConfiguration {
        let ticks = resolveTickValues()
        return LSliderConfiguration(
            isDisabled: isDisabled,
            isActive: isActive,
            pctFill: (value - range.lowerBound) / (range.upperBound - range.lowerBound),
            value: value,
            angle: angle,
            min: range.lowerBound,
            max: range.upperBound,
            keepThumbInTrack: keepThumbInTrack,
            trackThickness: trackThickness,
            tickMarkSpacing: tickMarkSpacing,
            tickValues: ticks
        )
    }

    // MARK: - Haptics

    private func impactOccured() {
#if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
#endif
    }

    private func impactHandler(_ parameterAtLimit: Bool) {
        if parameterAtLimit {
            if !atLimit { impactOccured() }
            atLimit = true
        } else {
            atLimit = false
        }
    }

    /// Fires a haptic tick if the thumb has moved onto (or very close to) a tick mark
    /// that hasn't already fired.
    private func fireTickHapticIfNeeded(newValue: Double) {
        guard hapticFeedbackEnabled else { return }
        let ticks = resolveTickValues()
        guard !ticks.isEmpty else { return }
        let rangeSpan = range.upperBound - range.lowerBound
        guard rangeSpan > 0 else { return }

        // Find the nearest tick
        let nearest = ticks.min(by: { abs($0 - newValue) < abs($1 - newValue) })!
        let distancePct = abs(nearest - newValue) / rangeSpan

        // Fire if within 1 % of range and we haven't already fired for this tick
        if distancePct < 0.01 {
            if lastHapticTickValue != nearest {
                hapticManager.playTick(intensity: 0.6)
                lastHapticTickValue = nearest
            }
        } else {
            // Reset once we move away
            if let last = lastHapticTickValue, abs(last - newValue) / rangeSpan >= 0.01 {
                lastHapticTickValue = nil
            }
        }
    }

    // MARK: - Gesture

    private func makeGesture(_ proxy: GeometryProxy) -> some Gesture {
        DragGesture(minimumDistance: 10, coordinateSpace: .named(space))
            .onChanged({ drag in
                let (start, end) = calculateEndPoints(proxy)
                let parameter = Double(calculateParameter(start, end, drag.location))
                impactHandler(parameter == 1 || parameter == 0)
                let newValue = (range.upperBound - range.lowerBound) * parameter + range.lowerBound
                value = newValue
                fireTickHapticIfNeeded(newValue: newValue)
                isActive = true
            })
            .onEnded({ drag in
                let (start, end) = calculateEndPoints(proxy)
                let parameter = Double(calculateParameter(start, end, drag.location))
                impactHandler(parameter == 1 || parameter == 0)
                let newValue = (range.upperBound - range.lowerBound) * parameter + range.lowerBound
                value = newValue
                fireTickHapticIfNeeded(newValue: newValue)
                isActive = false
                lastHapticTickValue = nil
            })
    }

    // MARK: - View

    public var body: some View {
        GeometryReader { geo in
            let config = configuration
            let ticks = config.tickValues
            ZStack {
                // Track
                style.makeTrack(configuration: config)

                // Tick marks (rendered below the thumb)
                ForEach(ticks, id: \.self) { tickValue in
                    style.makeTickMark(configuration: config, tickValue: tickValue)
                        .offset(tickMarkOffset(geo, tickValue: tickValue))
                }

                // Thumb
                style.makeThumb(configuration: config)
                    .offset(thumbOffset(geo))
                    .gesture(makeGesture(geo))
                    .allowsHitTesting(!isDisabled)
            }
            .coordinateSpace(name: space)
        }
    }
}

// MARK: - Preview Examples

fileprivate struct LSliderExamples: View {
    @State var value1 = 0.5
    @State var value2 = 0.5
    @State var value3 = 3.0
    @State var value4 = 0.5

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // ── Basic slider (no tick marks) ──────────────────────────────
                GroupBox("Basic – No Tick Marks") {
                    LSlider($value1, range: 0...1, keepThumbInTrack: true, trackThickness: 40)
                        .frame(height: 60)
                }

                // ── Evenly-distributed tick mark count ───────────────────────
                GroupBox("count(11) — 11 evenly spaced ticks, haptics on") {
                    LSlider(
                        $value2,
                        range: 0...1,
                        keepThumbInTrack: true,
                        trackThickness: 40,
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
                        trackThickness: 40,
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
                        trackThickness: 40,
                        tickMarkSpacing: .values([0.0, 0.25, 0.5, 0.75, 1.0]),
                        hapticFeedbackEnabled: false
                    )
                    .frame(height: 60)
                    Text("Value: \(value4, specifier: "%.2f")")
                        .font(.caption)
                }

                // ── Diagonal slider with count-based ticks ───────────────────
                GroupBox("Diagonal (325°) with count(5) ticks") {
                    LSlider(
                        $value2,
                        range: 0...1,
                        angle: Angle(degrees: 325),
                        keepThumbInTrack: true,
                        trackThickness: 40,
                        tickMarkSpacing: .count(5),
                        hapticFeedbackEnabled: true
                    )
                    .frame(height: 120)
                }

                // ── Custom style with tick marks ──────────────────────────────
                GroupBox("Custom BarLSliderStyle + spacing(0.1) ticks") {
                    LSlider(
                        $value1,
                        range: 0...1,
                        keepThumbInTrack: true,
                        trackThickness: 40,
                        tickMarkSpacing: .spacing(0.1),
                        hapticFeedbackEnabled: true
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
        RoundedRectangle(cornerRadius: 4)
            .fill(configuration.isActive ? Color.orange : Color.white)
            .frame(width: 14, height: configuration.trackThickness * 1.4)
            .shadow(radius: 3)
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
                adjustmentForThumb: adjustment
            )
            .fill(Color.orange)
            .mask(AdaptiveLine(thickness: configuration.trackThickness, angle: configuration.angle))
        }
    }

    /// Diamond-shaped tick mark that rotates to align with the slider axis.
    func makeTickMark(configuration: LSliderConfiguration, tickValue: Double) -> some View {
        let range = configuration.max - configuration.min
        let thumbPct = range > 0 ? (configuration.value - configuration.min) / range : 0
        let tickPct  = range > 0 ? (tickValue           - configuration.min) / range : 0
        let distance  = abs(thumbPct - tickPct)
        let proximity = max(0, 1 - distance / 0.15)

        let size = 6.0 + 6.0 * proximity
        let opacity = 0.4 + 0.6 * proximity

        return Rectangle()
            .fill(Color.orange.opacity(opacity))
            .frame(width: size, height: size)
            .rotationEffect(.degrees(45))
            .animation(.easeOut(duration: 0.08), value: proximity)
    }
}

#Preview {
    LSliderExamples()
        .frame(width: 380)
}
