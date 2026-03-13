// Swift toolchain version 6.0
// Running macOS version 26.3
// Created on 3/25/20.
//
// Author: Kieran Brown
//

import SwiftUI

// MARK:  Radial Slider

/// # Radial Slider
///  A Circular slider whose thumb is dragged causing it to follow the path of the circle
///
///  - parameters:
///     - value: a  `Binding<Double>` value to be controlled.
///     - range: a `ClosedRange<Double>` denoting the minimum and maximum values of the slider (default is `0...1`)
///     - isDisabled: a `Bool` value describing if the sliders state is disabled (default is `false`)
///     - tickSpacing: an optional `TickMarkSpacing` that controls tick mark placement around the arc (default `nil`)
///     - affinityEnabled: when `true` the thumb magnetically snaps to nearby tick marks (default `false`)
///     - disableHaptics: when `true` all haptic feedback is suppressed (default `false`)
///
///  ## Styling The Slider
///
///  To create a custom style for the slider you need to create a `RSliderStyle` conforming struct. Conformance requires implementation of 2 methods
///  1.  `makeThumb`: which creates the draggable portion of the slider
///  2.  `makeTrack`: which creates the track which fills or emptys as the thumb is dragging within it
///  3.  `makeTickMark`: (optional) which creates the view shown at each tick position around the arc
///
/// Both methods provide access to state values of the radial slider thru the  `RSliderConfiguration` struct
///
public struct RSlider: View {
    @Environment(\.radialSliderStyle) private var style: AnyRSliderStyle
    @Environment(\.isEnabled) private var isEnabled: Bool
    @State private var hapticManager = RSliderHapticManager()
    @State private var isActive = false
    @State private var atLimit: Bool = false
    /// The last tick value the thumb has fired a haptic for, used to debounce.
    @State private var lastHapticTickValue: Double? = nil
    /// The tick value the thumb is currently snapped to (nil = free).
    @State private var snappedTickValue: Double? = nil
    /// Tracks the cumulative number of full rotations (winds)
    @State private var currentWind: Double = 0
    /// The raw [0,1) angle position from the last drag update, used to detect crossings
    @State private var lastRawAngle: Double = 0
    @Binding private var value: Double
    private let range: ClosedRange<Double>
    /// The angle on the circle that corresponds to the minimum value (default: `.zero` = 3 o'clock)
    private let originAngle: Angle
    /// Maximum number of full winds allowed (e.g. 2 = 0–720°, 0.25 = 0–90°). Default is 1.
    private let maxWinds: Double
    /// How tick marks are spaced around the arc, or `nil` to hide tick marks.
    private let tickSpacing: TickMarkSpacing?
    /// When `true` the thumb is magnetically attracted to nearby tick marks.
    private let affinityEnabled: Bool
    /// Pull radius as a fraction of the total value range.
    private let affinityRadius: Double
    /// Extra escape distance (fraction of range) beyond the pull radius needed to leave a snap.
    private let affinityResistance: Double
    /// When `true` all haptic feedback is suppressed.
    private let disableHaptics: Bool
    /// When `true`, a single tap on the track immediately moves the thumb to the tapped position.
    private let allowsSingleTapSelect: Bool

    /// Creates a radial (circular) slider.
    ///
    /// The slider maps your bound `value` onto a circle (or multiple turns of a circle).
    /// Dragging the thumb changes `value` as it moves around the track.
    ///
    /// ## Value mapping
    /// - The slider’s domain is `range`.
    /// - The *minimum* value is located at `originAngle` (by default `.zero`, i.e. the 3 o’clock position).
    /// - The slider can span more than one full revolution using `maxWinds`.
    ///
    /// ## Winds (multiple rotations)
    /// `maxWinds` is the number of full rotations represented by the entire `range`.
    /// For example:
    /// - `maxWinds = 1` maps the entire range to 0–360°.
    /// - `maxWinds = 2` maps the entire range to 0–720°.
    /// - `maxWinds = 0.25` maps the entire range to 0–90°.
    ///
    /// ## Tick marks and affinity
    /// Provide `tickSpacing` to show tick marks around the track. When `affinityEnabled` is `true`,
    /// the thumb is magnetically attracted to nearby tick values.
    ///
    /// - Note: `affinityRadius` and `affinityResistance` are expressed as *fractions of the total value range*,
    ///   not points/pixels.
    ///
    /// - Parameters:
    ///   - value: A binding to the value controlled by the slider.
    ///   - range: The allowed value range. Defaults to `0...1`.
    ///   - originAngle: The angle on the circle that corresponds to the minimum value. Defaults to `.zero`.
    ///   - maxWinds: The number of full revolutions spanned by the slider’s full value range.
    ///     Fractional winds are supported.
    ///   - tickSpacing: Optional tick mark placement configuration. When `nil`, no tick marks are drawn.
    ///   - affinityEnabled: When `true`, the thumb will snap to nearby tick values.
    ///   - affinityRadius: The distance (as a fraction of the full value range) within which the thumb will
    ///     be pulled onto the nearest tick.
    ///   - affinityResistance: Extra distance (as a fraction of full value range) the user must drag *past*
    ///     `affinityRadius` to break out of a snap.
    ///   - disableHaptics: When `true`, all haptic feedback is suppressed.
    public init(_ value: Binding<Double>,
                range: ClosedRange<Double> = 0...1,
                originAngle: Angle = .zero,
                maxWinds: Double = 1,
                tickSpacing: TickMarkSpacing? = nil,
                affinityEnabled: Bool = false,
                affinityRadius: Double = 0.04,
                affinityResistance: Double = 0.02,
                disableHaptics: Bool = false,
                allowsSingleTapSelect: Bool = false) {
        self._value = value
        self.range = range
        self.originAngle = originAngle
        self.maxWinds = maxWinds
        self.tickSpacing = tickSpacing
        self.affinityEnabled = affinityEnabled
        self.affinityRadius = affinityRadius
        self.affinityResistance = affinityResistance
        self.disableHaptics = disableHaptics
        self.allowsSingleTapSelect = allowsSingleTapSelect
    }

    // MARK: - Tick mark value resolution

    /// Resolves `tickSpacing` into concrete values within the slider's range.
    private func resolveTickValues() -> [Double] {
        let lo = range.lowerBound
        let hi = range.upperBound
        guard hi > lo else { return [] }

        switch tickSpacing {
        case .none:
            return []
        case .spacing(let step) where step > 0:
            var ticks: [Double] = []
            var v = lo
            while v <= hi + step * 1e-9 {
                ticks.append(Swift.min(v, hi))
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

    private enum AffinityTransition {
        case snappedIn
        case snappedOut
        case none
    }

    @discardableResult
    private func applyAffinity(rawValue: Double) -> (value: Double, transition: AffinityTransition) {
        guard affinityEnabled && tickSpacing != nil else { return (rawValue, .none) }
        let ticks = resolveTickValues()
        guard !ticks.isEmpty else { return (rawValue, .none) }

        let rangeSpan = range.upperBound - range.lowerBound
        guard rangeSpan > 0 else { return (rawValue, .none) }

        let pullDistance    = affinityRadius * rangeSpan
        let resistDistance  = (affinityRadius + affinityResistance) * rangeSpan

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

    // MARK: - Angle / value math

    /// Returns the raw [0, 1) position around the circle for a drag location,
    /// adjusted so that `originAngle` maps to 0.
    private func rawAngle(from pt1: CGPoint, _ pt2: CGPoint) -> Double {
        let a = pt2.x - pt1.x
        let b = pt2.y - pt1.y
        let raw = Double(atanP(x: a, y: b) / (2 * .pi))
        let originFraction = originAngle.degrees / 360.0
        return (raw - originFraction).truncatingRemainder(dividingBy: 1.0) + (raw < originFraction ? 1 : 0)
    }

    /// Returns the raw [0, 1) angle that corresponds to the current `value`.
    /// This is used to seed the drag gesture so the first delta can’t be misread as a wrap.
    private func rawAngleForCurrentValue() -> Double {
        let span = range.upperBound - range.lowerBound
        guard span > 0, maxWinds != 0 else { return 0 }
        let pct = (value - range.lowerBound) / span
        let windValue = pct * maxWinds
        let withinWind = windValue.truncatingRemainder(dividingBy: 1.0)
        // Ensure [0, 1)
        return (withinWind < 0 ? withinWind + 1 : withinWind)
    }

    /// Computes the new value and updates `currentWind` based on the drag position.
    private func updateValue(from center: CGPoint, location: CGPoint) {
        var newRaw = rawAngle(from: center, location)

        let span = range.upperBound - range.lowerBound
        let atMin = span > 0 ? (value <= range.lowerBound + span * 1e-12) : true
        let atMax = span > 0 ? (value >= range.upperBound - span * 1e-12) : true
        let maxWindIndex = floor(maxWinds)

        // Detect wrap-around crossings
        let delta = newRaw - lastRawAngle

        // If we’re pinned at the minimum (wind 0), don’t allow a backward seam-crossing
        // to be interpreted as “almost a full rotation” (0 → 0.999...).
        // Keep withinWind at 0 until the user drags forward.
        if atMin && currentWind <= 0 && delta > 0.5 {
            currentWind = 0
            newRaw = 0
            lastRawAngle = 0
            value = range.lowerBound
            return
        }

        if delta < -0.5 {
            // Crossed 0 going forward (e.g. 0.95 → 0.05)
            // If we’re already pinned at max, don’t treat this as a forward wrap;
            // otherwise the clamp would keep us stuck at max.
            if !(atMax && currentWind >= maxWindIndex) {
                currentWind += 1
                currentWind = min(maxWindIndex, currentWind)
            }
        } else if delta > 0.5 {
            // Crossed 0 going backward (e.g. 0.05 → 0.95)
            // If we’re already pinned at min, don’t treat this as a backward wrap.
            if !(atMin && currentWind <= 0) {
                currentWind -= 1
            }
        }

        if delta > 0.5 && currentWind == -1 {
            currentWind = 0
            value = range.lowerBound
            return
        }

        // Total fractional progress across all winds
        let totalPct = (currentWind + newRaw) / maxWinds

        // Clamp to [0, 1] across full wind range
        let clampedPct = Swift.max(0, Swift.min(1, totalPct))

        let rawValue = clampedPct * (range.upperBound - range.lowerBound) + range.lowerBound
        let (snappedValue, _) = applyAffinity(rawValue: rawValue)

        if abs(value - range.upperBound) > abs(value - range.lowerBound)
            && abs(snappedValue - range.upperBound) < abs(snappedValue - range.lowerBound)
            && value == range.lowerBound {
            value = range.lowerBound
            currentWind = 0
        } else {
            value = snappedValue
        }

        lastRawAngle = newRaw
    }

    // MARK: - Haptics

    private func fireHapticsForNewValue(_ newValue: Double, transition: AffinityTransition = .none) {
        guard !disableHaptics else { return }

        let atMin = newValue <= range.lowerBound
        let atMax = newValue >= range.upperBound
        let isAtLimit = atMin || atMax

        // Limit hit
        if isAtLimit {
            if !atLimit {
                hapticManager.playLimitHit()
            }
            atLimit = true
        } else {
            atLimit = false
        }

        // Tick mark haptics
        if tickSpacing != nil {
            if affinityEnabled {
                // Affinity snap replaces plain tick
                if transition == .snappedIn {
                    hapticManager.playSnapIn()
                    lastHapticTickValue = snappedTickValue
                }
            } else {
                // Plain tick haptic
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
                } else if let last = lastHapticTickValue, abs(last - newValue) / rangeSpan >= 0.01 {
                    lastHapticTickValue = nil
                }
            }
        } else {
            // No tick marks → continuous wind tension
            let totalWind = (value - range.lowerBound) / (range.upperBound - range.lowerBound) * maxWinds
            hapticManager.updateWindTension(Float(totalWind))
        }
    }
    
    // MARK: - Configuration
    
    private var configuration: RSliderConfiguration {
        let ticks = resolveTickValues()
        let percent = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        let currentWindValue = percent * maxWinds
        let withinWind = currentWindValue.truncatingRemainder(dividingBy: 1.0)
        let currentAngle = originAngle + Angle.degrees(withinWind * 360)
        
        return .init(isDisabled: !isEnabled,
                     isActive: isActive,
                     value: value,
                     angle: currentAngle,
                     originAngle: originAngle,
                     min: range.lowerBound,
                     max: range.upperBound,
                     withinWind: withinWind,
                     currentWind: currentWind,
                     maxWinds: maxWinds,
                     tickMarkSpacing: tickSpacing,
                     tickValues: ticks,
                     affinityEnabled: affinityEnabled,
                     snappedTickValue: snappedTickValue)
    }

    // MARK: - Tick mark positioning

    /// Returns the offset from the ZStack centre for a tick mark at `tickValue`,
    /// placed on the circle at `radius`.
    private func tickMarkOffset(radius: CGFloat, tickValue: Double) -> CGSize {
        let rangeSpan = range.upperBound - range.lowerBound
        guard rangeSpan > 0 else { return .zero }
        // Map tickValue to an angle, accounting for maxWinds
        let pct = (tickValue - range.lowerBound) / rangeSpan
        let angle = pct * 2 * .pi * maxWinds + originAngle.radians
        let x = radius * CGFloat(cos(angle))
        let y = radius * CGFloat(sin(angle))
        return CGSize(width: x, height: y)
    }

    // MARK: - Thumb

    private func makeThumb(_ proxy: GeometryProxy) -> some View {
        let radius = min(proxy.size.height, proxy.size.width) / 2
        let middle = CGPoint(x: proxy.frame(in: .global).midX, y: proxy.frame(in: .global).midY)

        let gesture = DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .onChanged { dragValue in
                if !isActive {
                    // Seed gesture state from the current value (not the finger-down location).
                    // This prevents the first update from being interpreted as a wrap when the user
                    // touches the “wrong” side of the thumb at the seam (especially at max).
                    lastRawAngle = rawAngleForCurrentValue()

                    let percent = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
                    let currentWindValue = percent * maxWinds
                    currentWind = floor(currentWindValue)

                    if !disableHaptics && tickSpacing == nil {
                        hapticManager.prepare()
                    }
                    isActive = true
                }
                updateValue(from: middle, location: dragValue.location)
                let (_, transition) = applyAffinity(rawValue: value)
                fireHapticsForNewValue(value, transition: transition)
            }
            .onEnded { dragValue in
                updateValue(from: middle, location: dragValue.location)
                let (_, transition) = applyAffinity(rawValue: value)
                fireHapticsForNewValue(value, transition: transition)
                isActive = false
                lastHapticTickValue = nil
                if tickSpacing == nil {
                    hapticManager.releaseSpring()
                }
            }

        // Place thumb at the correct angular position, accounting for originAngle
        let pct = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        let thumbAngle = pct * 2 * .pi * maxWinds + originAngle.radians
        let pX = radius * CGFloat(cos(thumbAngle))
        let pY = radius * CGFloat(sin(thumbAngle))

        return style.makeThumb(configuration: configuration)
            .offset(x: pX, y: pY)
            .gesture(gesture)
            .allowsHitTesting(isEnabled)
    }

    // MARK: - Body

    public var body: some View {
        let config = configuration
        let ticks = config.tickValues

        return style.makeTrack(configuration: config)
            .overlay(GeometryReader { proxy in
                let r = min(proxy.size.width, proxy.size.height) / 2
                ZStack(alignment: .center) {
                    // Tick marks (rendered below thumb)
                    ForEach(ticks, id: \.self) { tickValue in
                        style.makeTickMark(configuration: config, tickValue: tickValue)
                            .offset(tickMarkOffset(radius: r, tickValue: tickValue))
                    }
                    // Track tap gesture (rendered below thumb so thumb drag takes priority)
                    if allowsSingleTapSelect {
                        Circle()
                            .fill(Color.clear)
                            .contentShape(Circle())
                            .gesture(
                                SpatialTapGesture(coordinateSpace: .global)
                                    .onEnded { tap in
                                        // Use the same global centre that the drag gesture uses,
                                        // so rawAngle sees the same coordinate space.
                                        let globalCenter = CGPoint(
                                            x: proxy.frame(in: .global).midX,
                                            y: proxy.frame(in: .global).midY
                                        )
                                        let tappedRaw = rawAngle(from: globalCenter, tap.location)
                                        let totalPct = tappedRaw / maxWinds
                                        let clampedPct = Swift.max(0, Swift.min(1, totalPct))
                                        let rawValue = clampedPct * (range.upperBound - range.lowerBound) + range.lowerBound
                                        let (snappedValue, transition) = applyAffinity(rawValue: rawValue)
                                        value = snappedValue
                                        currentWind = 0
                                        lastRawAngle = tappedRaw
                                        fireHapticsForNewValue(snappedValue, transition: transition)
                                    }
                            )
                            .allowsHitTesting(isEnabled)
                    }
                    // Thumb
                    makeThumb(proxy)
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
            })
            .onAppear {
                hapticManager.prepare()
                let percent = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
                let currentWindValue = percent * maxWinds
                currentWind = floor(currentWindValue)
            }
            .onChange(of: value) { oldValue, newValue in
                guard !isActive else { return }
                let percent = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
                let currentWindValue = percent * maxWinds
                currentWind = floor(currentWindValue)
            }
    }
}
