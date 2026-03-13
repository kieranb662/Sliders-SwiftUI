// Swift toolchain version 6.0
// Running macOS version 26.3
// Created on 4/6/20.
//
// Author: Kieran Brown
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
    /// When `true`, a single tap on the track immediately moves the thumb to the tapped position.
    private var allowsSingleTapSelect: Bool = false

    // MARK: - Initialisers

    /// Creates a linear slider that controls `value` within `range` and is rendered at `angle`.
    ///
    /// The slider can optionally show tick marks (see `tickMarkSpacing`) and can provide
    /// haptic feedback as the thumb crosses those tick marks.
    ///
    /// If `affinityEnabled` is `true` and tick marks are configured, the thumb will
    /// magnetically snap to nearby tick marks.
    ///
    /// - Important: `affinityEnabled` has no effect when `tickMarkSpacing` is `nil`.
    ///
    /// - Parameters:
    ///   - value: A binding to the value being edited.
    ///   - range: The minimum and maximum bounds for `value`.
    ///   - angle: The angle of the slider’s track.
    ///   - keepThumbInTrack: If `true`, the thumb’s center is constrained to stay within the track’s end caps.
    ///   - trackThickness: The thickness of the track, used by layout and the default style.
    ///   - tickMarkSpacing: How tick marks are spaced, or `nil` to hide them.
    ///   - hapticFeedbackEnabled: If `true`, crossing a tick mark may trigger haptics (best-effort, device-dependent).
    ///   - affinityEnabled: Enables magnetic snapping to tick marks.
    ///   - affinityRadius: Pull radius as a fraction of the total value range.
    ///   - affinityResistance: Extra escape distance (fraction of range) beyond the pull radius required to leave a snap.
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

    /// Creates a linear slider that controls `value` within `range`.
    ///
    /// This overload uses a default `angle` of `.zero` (horizontal).
    ///
    /// - Parameters:
    ///   - value: A binding to the value being edited.
    ///   - range: The minimum and maximum bounds for `value`.
    ///   - keepThumbInTrack: If `true`, the thumb’s center is constrained to stay within the track’s end caps.
    ///   - trackThickness: The thickness of the track, used by layout and the default style.
    ///   - tickMarkSpacing: How tick marks are spaced, or `nil` to hide them.
    ///   - hapticFeedbackEnabled: If `true`, crossing a tick mark may trigger haptics (best-effort, device-dependent).
    ///   - affinityEnabled: Enables magnetic snapping to tick marks (requires `tickMarkSpacing != nil`).
    ///   - affinityRadius: Pull radius as a fraction of the total value range.
    ///   - affinityResistance: Extra escape distance (fraction of range) beyond the pull radius required to leave a snap.
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

    /// Creates a linear slider that controls `value` and is rendered at `angle`.
    ///
    /// This overload uses a default `range` of `0...1`.
    ///
    /// - Parameters:
    ///   - value: A binding to the value being edited.
    ///   - angle: The angle of the slider’s track.
    ///   - keepThumbInTrack: If `true`, the thumb’s center is constrained to stay within the track’s end caps.
    ///   - trackThickness: The thickness of the track, used by layout and the default style.
    ///   - tickMarkSpacing: How tick marks are spaced, or `nil` to hide them.
    ///   - hapticFeedbackEnabled: If `true`, crossing a tick mark may trigger haptics (best-effort, device-dependent).
    ///   - affinityEnabled: Enables magnetic snapping to tick marks (requires `tickMarkSpacing != nil`).
    ///   - affinityRadius: Pull radius as a fraction of the total value range.
    ///   - affinityResistance: Extra escape distance (fraction of range) beyond the pull radius required to leave a snap.
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

    /// Creates a linear slider with default configuration.
    ///
    /// Defaults:
    /// - `range`: `0...1`
    /// - `angle`: `.zero`
    /// - `keepThumbInTrack`: `false`
    /// - `trackThickness`: `20`
    /// - `tickMarkSpacing`: `nil` (no tick marks)
    /// - `hapticFeedbackEnabled`: `true`
    /// - `affinityEnabled`: `false`
    ///
    /// - Parameter value: A binding to the value being edited.
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

    /// Enables or disables placing the thumb by tapping directly on the track.
    ///
    /// - Parameter allows: When `true`, a single tap on the track moves the thumb to that position.
    public func allowsSingleTapSelect(_ allows: Bool) -> LSlider {
        var copy = self
        copy.allowsSingleTapSelect = allows
        return copy
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

                // Track tap gesture (rendered below thumb so thumb drag takes priority)
                if allowsSingleTapSelect {
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            SpatialTapGesture(coordinateSpace: .named(space))
                                .onEnded { tap in
                                    let (start, end) = calculateEndPoints(geo)
                                    let parameter = Double(calculateParameter(start, end, tap.location))
                                    impactHandler(parameter == 1 || parameter == 0)
                                    let rawValue = (range.upperBound - range.lowerBound) * parameter + range.lowerBound
                                    let (newValue, transition) = applyAffinity(rawValue: rawValue)
                                    value = newValue
                                    fireTickHapticIfNeeded(newValue: newValue, transition: transition)
                                    isActive = false
                                    lastHapticTickValue = nil
                                }
                        )
                        .allowsHitTesting(isEnabled)
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
