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
/// ## Tick Mark Affinity (Magnetic Snap)
///
/// When `affinityEnabled` is `true` and tick marks are configured, the thumb is
/// magnetically attracted to nearby tick marks:
///
/// - **Pull zone** – within `affinityRadius` (fraction of total range) the thumb is
///   pulled all the way onto the nearest tick mark and "snapped" there.
/// - **Resistance zone** – once snapped, the thumb stays locked until the raw drag
///   position moves beyond `affinityRadius + affinityResistance`, giving a tactile
///   resistance feel before the thumb escapes.
///
/// - parameters:
///     - value: `Binding<Double>` The value the slider should control
///     - range: `ClosedRange<Double>` The minimum and maximum numbers that `value` can be
///     - angle: `Angle` The angle you would like the slider to be at
///     - keepThumbInTrack: `Bool` Whether the thumb is constrained to stay within the track's extent
///     - trackThickness: `Double` The thickness of the track
///     - tickMarkSpacing: `TickMarkSpacing?` How tick marks should be spaced, or `nil` to hide them
///     - hapticFeedbackEnabled: `Bool` Whether crossing a tick mark triggers haptic feedback
///     - affinityEnabled: `Bool` Whether the thumb snaps magnetically to tick marks (requires `tickMarkSpacing != nil`)
///     - affinityRadius: `Double` Fraction of the total range within which a tick attracts the thumb (default 0.04)
///     - affinityResistance: `Double` Extra fraction beyond `affinityRadius` the drag must travel to escape a snap (default 0.02)
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
    @Environment(\.isEnabled) private var isEnabled: Bool
    @StateObject private var hapticManager = LSliderHapticManager()
    @State private var isActive: Bool = false
    @State private var atLimit: Bool = false
    /// The last tick value the thumb was snapped near, used to avoid re-firing haptics.
    @State private var lastHapticTickValue: Double? = nil
    /// The tick value the thumb is currently snapped to (nil = free).
    @State private var snappedTickValue: Double? = nil
    private let space: String = "Slider"

    // MARK: Input
    @Binding private var value: Double
    private var range: ClosedRange<Double> = 0...1
    private var angle: Angle = .zero
    private var keepThumbInTrack: Bool = false
    private var trackThickness: Double = 20
    private var tickMarkSpacing: TickMarkSpacing? = nil
    private var hapticFeedbackEnabled: Bool = true
    private var affinityEnabled: Bool = false
    /// Pull radius as a fraction of the total value range.
    private var affinityRadius: Double = 0.04
    /// Extra escape distance (fraction of range) beyond the pull radius needed to leave a snap.
    private var affinityResistance: Double = 0.02

    // MARK: - Initialisers

    public init(
        _ value: Binding<Double>,
        range: ClosedRange<Double>,
        angle: Angle,
        keepThumbInTrack: Bool = false,
        trackThickness: Double = 20,
        tickMarkSpacing: TickMarkSpacing? = nil,
        hapticFeedbackEnabled: Bool = true,
        affinityEnabled: Bool = false,
        affinityRadius: Double = 0.04,
        affinityResistance: Double = 0.02
    ) {
        self._value = value
        self.range = range
        self.angle = angle
        self.keepThumbInTrack = keepThumbInTrack
        self.trackThickness = trackThickness
        self.tickMarkSpacing = tickMarkSpacing
        self.hapticFeedbackEnabled = hapticFeedbackEnabled
        self.affinityEnabled = affinityEnabled
        self.affinityRadius = affinityRadius
        self.affinityResistance = affinityResistance
    }

    public init(
        _ value: Binding<Double>,
        range: ClosedRange<Double>,
        keepThumbInTrack: Bool = false,
        trackThickness: Double = 20,
        tickMarkSpacing: TickMarkSpacing? = nil,
        hapticFeedbackEnabled: Bool = true,
        affinityEnabled: Bool = false,
        affinityRadius: Double = 0.04,
        affinityResistance: Double = 0.02
    ) {
        self._value = value
        self.range = range
        self.keepThumbInTrack = keepThumbInTrack
        self.trackThickness = trackThickness
        self.tickMarkSpacing = tickMarkSpacing
        self.hapticFeedbackEnabled = hapticFeedbackEnabled
        self.affinityEnabled = affinityEnabled
        self.affinityRadius = affinityRadius
        self.affinityResistance = affinityResistance
    }

    public init(
        _ value: Binding<Double>,
        angle: Angle,
        keepThumbInTrack: Bool = false,
        trackThickness: Double = 20,
        tickMarkSpacing: TickMarkSpacing? = nil,
        hapticFeedbackEnabled: Bool = true,
        affinityEnabled: Bool = false,
        affinityRadius: Double = 0.04,
        affinityResistance: Double = 0.02
    ) {
        self._value = value
        self.angle = angle
        self.keepThumbInTrack = keepThumbInTrack
        self.trackThickness = trackThickness
        self.tickMarkSpacing = tickMarkSpacing
        self.hapticFeedbackEnabled = hapticFeedbackEnabled
        self.affinityEnabled = affinityEnabled
        self.affinityRadius = affinityRadius
        self.affinityResistance = affinityResistance
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

    // MARK: - Affinity / Magnetic Snap

    /// Describes a snap transition that occurred during `applyAffinity`.
    private enum AffinityTransition {
        case snappedIn   // thumb just entered a snap
        case snappedOut  // thumb just broke free from a snap
        case none
    }

    /// Applies affinity logic to a raw drag-computed value.
    ///
    /// - Returns: A tuple of the adjusted display value and any snap transition that occurred.
    @discardableResult
    private func applyAffinity(rawValue: Double) -> (value: Double, transition: AffinityTransition) {
        guard affinityEnabled && tickMarkSpacing != nil else { return (rawValue, .none) }

        let ticks = resolveTickValues()
        guard !ticks.isEmpty else { return (rawValue, .none) }

        let rangeSpan = range.upperBound - range.lowerBound
        guard rangeSpan > 0 else { return (rawValue, .none) }

        let pullDistance   = affinityRadius * rangeSpan
        let resistDistance = (affinityRadius + affinityResistance) * rangeSpan

        // ── Hold phase: already snapped ──────────────────────────────────────
        if let snapped = snappedTickValue {
            let distToSnapped = abs(rawValue - snapped)
            if distToSnapped <= resistDistance {
                return (snapped, .none)
            } else {
                snappedTickValue = nil
                return (rawValue, .snappedOut)
            }
        }

        // ── Pull phase: find nearest tick within pull distance ───────────────
        let nearest = ticks.min(by: { abs($0 - rawValue) < abs($1 - rawValue) })!
        if abs(rawValue - nearest) <= pullDistance {
            snappedTickValue = nearest
            return (nearest, .snappedIn)
        }

        return (rawValue, .none)
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
            isDisabled: !isEnabled,
            isActive: isActive,
            pctFill: (value - range.lowerBound) / (range.upperBound - range.lowerBound),
            value: value,
            angle: angle,
            min: range.lowerBound,
            max: range.upperBound,
            keepThumbInTrack: keepThumbInTrack,
            trackThickness: trackThickness,
            tickMarkSpacing: tickMarkSpacing,
            tickValues: ticks,
            affinityEnabled: affinityEnabled,
            snappedTickValue: snappedTickValue
        )
    }

    // MARK: - Haptics

    private func impactOccured() {
#if os(iOS)
        if tickMarkSpacing == nil && hapticFeedbackEnabled && isEnabled {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
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
    /// that hasn't already fired.  When affinity is enabled, snap transition haptics
    /// are used instead — this method is a no-op for plain `playTick` calls in that mode.
    private func fireTickHapticIfNeeded(newValue: Double, transition: AffinityTransition = .none) {
        guard hapticFeedbackEnabled else { return }

        // Affinity mode: dedicated snap-in / snap-out haptics replace the tick haptic.
        if affinityEnabled && tickMarkSpacing != nil {
            if transition == .snappedIn {
                hapticManager.playSnapIn()
            }
            return
        }

        // Non-affinity tick haptic (unchanged behaviour)
        let ticks = resolveTickValues()
        guard !ticks.isEmpty else { return }
        let rangeSpan = range.upperBound - range.lowerBound
        guard rangeSpan > 0 else { return }

        let nearest = ticks.min(by: { abs($0 - newValue) < abs($1 - newValue) })!
        let distancePct = abs(nearest - newValue) / rangeSpan

        if distancePct < 0.01 {
            if lastHapticTickValue != nearest {
                hapticManager.playTick(intensity: 0.6)
                lastHapticTickValue = nearest
            }
        } else {
            if let last = lastHapticTickValue, abs(last - newValue) / rangeSpan >= 0.01 {
                lastHapticTickValue = nil
            }
        }
    }

    // MARK: - Gesture

    private func makeGesture(_ proxy: GeometryProxy) -> some Gesture {
        DragGesture(minimumDistance: 5, coordinateSpace: .named(space))
            .onChanged({ drag in
                let (start, end) = calculateEndPoints(proxy)
                let parameter = Double(calculateParameter(start, end, drag.location))
                impactHandler(parameter == 1 || parameter == 0)
                let rawValue = (range.upperBound - range.lowerBound) * parameter + range.lowerBound
                let (newValue, transition) = applyAffinity(rawValue: rawValue)
                value = newValue
                fireTickHapticIfNeeded(newValue: newValue, transition: transition)
                isActive = true
            })
            .onEnded({ drag in
                let (start, end) = calculateEndPoints(proxy)
                let parameter = Double(calculateParameter(start, end, drag.location))
                impactHandler(parameter == 1 || parameter == 0)
                let rawValue = (range.upperBound - range.lowerBound) * parameter + range.lowerBound
                let (newValue, transition) = applyAffinity(rawValue: rawValue)
                value = newValue
                fireTickHapticIfNeeded(newValue: newValue, transition: transition)
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
                    .simultaneousGesture(makeGesture(geo))
                    .allowsHitTesting(isEnabled)
            }
            .coordinateSpace(name: space)
        }
    }
}

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
