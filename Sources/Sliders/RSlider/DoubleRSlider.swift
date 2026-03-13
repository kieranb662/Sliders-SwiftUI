// Swift toolchain version 6.0
// Running macOS version 26.3
// Created on 3/13/26.
//
// Author: Kieran Brown
//

import SwiftUI

// MARK: - Double Radial Slider

/// A circular range slider with two draggable thumbs (lower and upper) and a draggable active
/// track segment between them.
///
/// # Overview
/// ``DoubleRSlider`` lets the user select a range of values on a circular track. Three elements
/// are draggable:
/// - **Lower thumb** – moves the start of the range. Cannot cross the upper thumb.
/// - **Upper thumb** – moves the end of the range. Cannot cross the lower thumb.
/// - **Active track** – drags both thumbs simultaneously, keeping the range width constant.
///
/// All three elements can move past the `originAngle` in both the positive and negative direction.
/// There are no windings; the slider spans exactly one revolution.
///
/// # Labels
///
/// Floating labels are displayed near each thumb and update continuously as the thumbs move.
/// By default both labels show the current value formatted to two decimal places.
/// Provide custom labels via the `lowerLabel` and `upperLabel` parameters:
///
/// ```swift
/// DoubleRSlider(lowerValue: $lo, upperValue: $hi, range: 0...100) { v in
///     Text("\(Int(v))°")
/// } upperLabel: { v in
///     Text("\(Int(v))°")
/// }
/// ```
///
/// Label visibility is controlled by the `.labelsVisibility(_:)` environment modifier.
///
/// # Styling
/// Provide a custom ``DoubleRSliderStyle`` via `.doubleRadialSliderStyle(_:)`. Implement:
///   - `makeLowerThumb` – the draggable lower-thumb view
///   - `makeUpperThumb` – the draggable upper-thumb view
///   - `makeTrack` – the full circular track / fill view
///   - `makeTickMark(configuration:tickValue:)` – the view shown at each tick position
///   - `makeLowerLabel(configuration:content:)` – (optional, default provided) the container for the lower floating label
///   - `makeUpperLabel(configuration:content:)` – (optional, default provided) the container for the upper floating label
///
/// Two built-in styles are available: ``DefaultDoubleRSliderStyle``.
///
/// # Minimum distance
/// `minimumDistance` (in value-domain units) ensures the two thumbs never overlap.
///
public struct DoubleRSlider<LowerLabel: View, UpperLabel: View>: View {
    @Environment(\.doubleRadialSliderStyle) private var style: AnyDoubleRSliderStyle
    @Environment(\.isEnabled) private var isEnabled: Bool
    @Environment(\.labelsVisibility) private var labelsVisibility

    // Haptic managers – one per thumb so limit/tick events are scoped correctly.
    @State private var lowerHapticManager = RSliderHapticManager()
    @State private var upperHapticManager = RSliderHapticManager()

    // Active state
    @State private var isLowerActive = false
    @State private var isUpperActive = false
    @State private var isRangeActive = false

    // Limit-hit debounce
    @State private var lowerAtLimit = false
    @State private var upperAtLimit = false

    // Tick haptic debounce
    @State private var lastLowerHapticTick: Double? = nil
    @State private var lastUpperHapticTick: Double? = nil

    // Affinity snap values
    @State private var snappedLowerTick: Double? = nil
    @State private var snappedUpperTick: Double? = nil

    // Raw [0,1) seam-tracking for each thumb  (no windings → stored purely for delta detection)
    @State private var lastLowerRawAngle: Double = 0
    @State private var lastUpperRawAngle: Double = 0

    // Range-drag: raw angle at the start of the range gesture; we diff successive locations.
    @State private var lastRangeDragRawAngle: Double = 0

    @Binding private var lowerValue: Double
    @Binding private var upperValue: Double

    private let range: ClosedRange<Double>
    private let originAngle: Angle
    private let minimumDistance: Double
    private let tickSpacing: TickMarkSpacing?
    private let affinityEnabled: Bool
    private let affinityRadius: Double
    private let affinityResistance: Double
    private let disableHaptics: Bool

    /// The user-provided label view for the lower (start) thumb.
    private var lowerLabel: (Double) -> LowerLabel
    /// The user-provided label view for the upper (end) thumb.
    private var upperLabel: (Double) -> UpperLabel

    // MARK: - Init

    /// Creates a double radial (circular) slider.
    ///
    /// - Parameters:
    ///   - lowerValue: A binding to the start of the selected range.
    ///   - upperValue: A binding to the end of the selected range.
    ///   - range: The allowed value domain. Defaults to `0...1`.
    ///   - originAngle: The angle that corresponds to the minimum value. Defaults to `.zero`
    ///     (3 o'clock).
    ///   - minimumDistance: The smallest gap (in value units) allowed between the two thumbs.
    ///     Defaults to `0.05` of the range span.
    ///   - tickSpacing: Optional tick-mark placement configuration.
    ///   - affinityEnabled: When `true`, thumbs snap magnetically to nearby tick values.
    ///   - affinityRadius: Pull radius as a fraction of the value range.
    ///   - affinityResistance: Extra escape distance beyond `affinityRadius`.
    ///   - disableHaptics: Suppresses all haptic feedback when `true`.
    ///   - lowerLabel: A view builder that creates the label for the lower (start) thumb.
    ///   - upperLabel: A view builder that creates the label for the upper (end) thumb.
    public init(
        lowerValue: Binding<Double>,
        upperValue: Binding<Double>,
        range: ClosedRange<Double> = 0...1,
        originAngle: Angle = .zero,
        minimumDistance: Double? = nil,
        tickSpacing: TickMarkSpacing? = nil,
        affinityEnabled: Bool = false,
        affinityRadius: Double = 0.04,
        affinityResistance: Double = 0.02,
        disableHaptics: Bool = false,
        @ViewBuilder lowerLabel: @escaping (Double) -> LowerLabel,
        @ViewBuilder upperLabel: @escaping (Double) -> UpperLabel
    ) {
        self._lowerValue = lowerValue
        self._upperValue = upperValue
        self.range = range
        self.originAngle = originAngle
        let span = range.upperBound - range.lowerBound
        self.minimumDistance = minimumDistance ?? (span > 0 ? span * 0.05 : 0)
        self.tickSpacing = tickSpacing
        self.affinityEnabled = affinityEnabled
        self.affinityRadius = affinityRadius
        self.affinityResistance = affinityResistance
        self.disableHaptics = disableHaptics
        self.lowerLabel = lowerLabel
        self.upperLabel = upperLabel
    }

    // MARK: - Tick mark resolution

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
            return (0..<n).map { lo + Double($0) / Double(n - 1) * (hi - lo) }
        case .count:
            return [lo]
        case .values(let vals):
            return vals.filter { $0 >= lo && $0 <= hi }.sorted()
        default:
            return []
        }
    }

    // MARK: - Affinity

    private enum AffinityTransition {
        case snappedIn, snappedOut, none
    }

    @discardableResult
    private func applyAffinityToLower(rawValue: Double) -> (value: Double, transition: AffinityTransition) {
        guard affinityEnabled, tickSpacing != nil else { return (rawValue, .none) }
        let ticks = resolveTickValues()
        guard !ticks.isEmpty else { return (rawValue, .none) }
        let span = range.upperBound - range.lowerBound
        guard span > 0 else { return (rawValue, .none) }
        let pull = affinityRadius * span
        let resist = (affinityRadius + affinityResistance) * span

        if let snapped = snappedLowerTick {
            if abs(rawValue - snapped) <= resist { return (snapped, .none) }
            snappedLowerTick = nil
            return (rawValue, .snappedOut)
        }
        let nearest = ticks.min(by: { abs($0 - rawValue) < abs($1 - rawValue) })!
        if abs(rawValue - nearest) <= pull {
            snappedLowerTick = nearest
            return (nearest, .snappedIn)
        }
        return (rawValue, .none)
    }

    @discardableResult
    private func applyAffinityToUpper(rawValue: Double) -> (value: Double, transition: AffinityTransition) {
        guard affinityEnabled, tickSpacing != nil else { return (rawValue, .none) }
        let ticks = resolveTickValues()
        guard !ticks.isEmpty else { return (rawValue, .none) }
        let span = range.upperBound - range.lowerBound
        guard span > 0 else { return (rawValue, .none) }
        let pull = affinityRadius * span
        let resist = (affinityRadius + affinityResistance) * span

        if let snapped = snappedUpperTick {
            if abs(rawValue - snapped) <= resist { return (snapped, .none) }
            snappedUpperTick = nil
            return (rawValue, .snappedOut)
        }
        let nearest = ticks.min(by: { abs($0 - rawValue) < abs($1 - rawValue) })!
        if abs(rawValue - nearest) <= pull {
            snappedUpperTick = nearest
            return (nearest, .snappedIn)
        }
        return (rawValue, .none)
    }

    // MARK: - Angle / value math

    /// Maps a drag-location point to a raw [0, 1) position around the circle
    /// with `originAngle` mapped to 0.
    private func rawAngle(from center: CGPoint, _ location: CGPoint) -> Double {
        let dx = location.x - center.x
        let dy = location.y - center.y
        let raw = Double(atan2(dy, dx)) / (2 * .pi)
        let originFraction = originAngle.degrees / 360.0
        var adjusted = raw - originFraction
        // Normalise to [0, 1)
        adjusted = adjusted.truncatingRemainder(dividingBy: 1.0)
        if adjusted < 0 { adjusted += 1.0 }
        return adjusted
    }

    /// Returns the raw [0,1) angle for a given value (used to seed drag state).
    private func rawAngleForValue(_ v: Double) -> Double {
        let span = range.upperBound - range.lowerBound
        guard span > 0 else { return 0 }
        // Clamp result to [0, 1) to match the output range of rawAngle(from:_:).
        // In particular, the maximum value maps to 1.0 which must be folded back to 0.0
        // so that seam-crossing delta maths stays consistent.
        let raw = (v - range.lowerBound) / span
        return raw >= 1.0 ? 0.0 : raw
    }

    /// Converts a raw [0, 1) circle fraction to the value domain.
    private func valueForRaw(_ raw: Double) -> Double {
        let span = range.upperBound - range.lowerBound
        return raw * span + range.lowerBound
    }

    /// Computes the angular offset (in raw [−0.5, 0.5]) between two successive drag locations.
    private func angularDelta(prev: CGPoint, next: CGPoint, center: CGPoint) -> Double {
        let rawPrev = rawAngle(from: center, prev)
        let rawNext = rawAngle(from: center, next)
        var delta = rawNext - rawPrev
        // Wrap into (–0.5, 0.5] to handle the seam
        if delta > 0.5  { delta -= 1.0 }
        if delta < -0.5 { delta += 1.0 }
        return delta
    }

    // MARK: - Value updaters

    private func updateLowerValue(from center: CGPoint, location: CGPoint) {
        let newRaw = rawAngle(from: center, location)

        // Compute signed delta, wrapping through the seam into (–0.5, 0.5]
        var delta = newRaw - lastLowerRawAngle
        if delta > 0.5  { delta -= 1.0 }
        if delta < -0.5 { delta += 1.0 }

        let span = range.upperBound - range.lowerBound
        var rawValue = lowerValue + delta * span

        // Clamp to [range.lowerBound ... upperValue - minimumDistance]
        rawValue = Swift.max(range.lowerBound, Swift.min(upperValue - minimumDistance, rawValue))

        let (snapped, _) = applyAffinityToLower(rawValue: rawValue)
        lowerValue = snapped
        lastLowerRawAngle = newRaw
    }

    private func updateUpperValue(from center: CGPoint, location: CGPoint) {
        let newRaw = rawAngle(from: center, location)

        // Compute signed delta, wrapping through the seam into (–0.5, 0.5]
        var delta = newRaw - lastUpperRawAngle
        if delta > 0.5  { delta -= 1.0 }
        if delta < -0.5 { delta += 1.0 }

        let span = range.upperBound - range.lowerBound
        var rawValue = upperValue + delta * span

        // Clamp to [lowerValue + minimumDistance ... range.upperBound]
        rawValue = Swift.max(lowerValue + minimumDistance, Swift.min(range.upperBound, rawValue))

        let (snapped, _) = applyAffinityToUpper(rawValue: rawValue)
        upperValue = snapped
        lastUpperRawAngle = newRaw
    }

    /// Shifts both values by the angular delta between `prev` and `next` drag locations.
    private func updateRangeValues(prev: CGPoint, next: CGPoint, center: CGPoint) {
        let delta = angularDelta(prev: prev, next: next, center: center)
        let span = range.upperBound - range.lowerBound
        guard span > 0 else { return }
        let valueDelta = delta * span

        let rangeWidth = upperValue - lowerValue

        var newLower = lowerValue + valueDelta
        var newUpper = upperValue + valueDelta

        // Clamp the pair to stay within the range
        if newLower < range.lowerBound {
            newLower = range.lowerBound
            newUpper = newLower + rangeWidth
        }
        if newUpper > range.upperBound {
            newUpper = range.upperBound
            newLower = newUpper - rangeWidth
        }
        // Final safety clamp on individual bounds
        newLower = Swift.max(range.lowerBound, newLower)
        newUpper = Swift.min(range.upperBound, newUpper)

        lowerValue = newLower
        upperValue = newUpper
    }

    // MARK: - Haptics

    private func fireLowerHaptics(transition: AffinityTransition) {
        guard !disableHaptics else { return }
        let atMin = lowerValue <= range.lowerBound
        let atMax = lowerValue >= range.upperBound
        if atMin || atMax {
            if !lowerAtLimit { lowerHapticManager.playLimitHit() }
            lowerAtLimit = true
        } else {
            lowerAtLimit = false
        }
        if let _ = tickSpacing {
            if affinityEnabled {
                if transition == .snappedIn { lowerHapticManager.playSnapIn() }
            } else {
                let ticks = resolveTickValues()
                guard !ticks.isEmpty else { return }
                let span = range.upperBound - range.lowerBound
                guard span > 0 else { return }
                let nearest = ticks.min(by: { abs($0 - lowerValue) < abs($1 - lowerValue) })!
                if abs(nearest - lowerValue) / span < 0.01 {
                    if lastLowerHapticTick != nearest {
                        lowerHapticManager.playTick(intensity: 0.6)
                        lastLowerHapticTick = nearest
                    }
                } else if let last = lastLowerHapticTick, abs(last - lowerValue) / span >= 0.01 {
                    lastLowerHapticTick = nil
                }
            }
        }
    }

    private func fireUpperHaptics(transition: AffinityTransition) {
        guard !disableHaptics else { return }
        let atMin = upperValue <= range.lowerBound
        let atMax = upperValue >= range.upperBound
        if atMin || atMax {
            if !upperAtLimit { upperHapticManager.playLimitHit() }
            upperAtLimit = true
        } else {
            upperAtLimit = false
        }
        if let _ = tickSpacing {
            if affinityEnabled {
                if transition == .snappedIn { upperHapticManager.playSnapIn() }
            } else {
                let ticks = resolveTickValues()
                guard !ticks.isEmpty else { return }
                let span = range.upperBound - range.lowerBound
                guard span > 0 else { return }
                let nearest = ticks.min(by: { abs($0 - upperValue) < abs($1 - upperValue) })!
                if abs(nearest - upperValue) / span < 0.01 {
                    if lastUpperHapticTick != nearest {
                        upperHapticManager.playTick(intensity: 0.6)
                        lastUpperHapticTick = nearest
                    }
                } else if let last = lastUpperHapticTick, abs(last - upperValue) / span >= 0.01 {
                    lastUpperHapticTick = nil
                }
            }
        }
    }

    // MARK: - Configuration

    private func angleForValue(_ v: Double) -> Angle {
        let span = range.upperBound - range.lowerBound
        guard span > 0 else { return originAngle }
        let pct = (v - range.lowerBound) / span
        return originAngle + .degrees(pct * 360)
    }

    private var configuration: DoubleRSliderConfiguration {
        DoubleRSliderConfiguration(
            isDisabled: !isEnabled,
            isLowerActive: isLowerActive,
            isUpperActive: isUpperActive,
            isRangeActive: isRangeActive,
            lowerValue: lowerValue,
            upperValue: upperValue,
            lowerAngle: angleForValue(lowerValue),
            upperAngle: angleForValue(upperValue),
            originAngle: originAngle,
            min: range.lowerBound,
            max: range.upperBound,
            tickMarkSpacing: tickSpacing,
            tickValues: resolveTickValues(),
            affinityEnabled: affinityEnabled,
            snappedLowerTickValue: snappedLowerTick,
            snappedUpperTickValue: snappedUpperTick
        )
    }

    // MARK: - Tick mark offset

    private func tickMarkOffset(radius: CGFloat, tickValue: Double) -> CGSize {
        let span = range.upperBound - range.lowerBound
        guard span > 0 else { return .zero }
        let pct = (tickValue - range.lowerBound) / span
        let angle = pct * 2 * .pi + originAngle.radians
        return CGSize(
            width:  radius * CGFloat(cos(angle)),
            height: radius * CGFloat(sin(angle))
        )
    }

    // MARK: - Subview builders

    /// Builds the lower thumb gesture + positioned view.
    private func makeLowerThumbView(_ proxy: GeometryProxy) -> some View {
        let radius = min(proxy.size.width, proxy.size.height) / 2
        let middle = CGPoint(x: proxy.frame(in: .global).midX,
                             y: proxy.frame(in: .global).midY)

        let gesture = DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .onChanged { drag in
                if !isLowerActive {
                    // Seed from the actual touch-down position so the first delta is ~zero,
                    // regardless of where on the circle the value sits (including the seam).
                    lastLowerRawAngle = rawAngle(from: middle, drag.startLocation)
                    lowerHapticManager.prepare()
                    isLowerActive = true
                }
                updateLowerValue(from: middle, location: drag.location)
                let (_, transition) = applyAffinityToLower(rawValue: lowerValue)
                fireLowerHaptics(transition: transition)
            }
            .onEnded { drag in
                updateLowerValue(from: middle, location: drag.location)
                let (_, transition) = applyAffinityToLower(rawValue: lowerValue)
                fireLowerHaptics(transition: transition)
                isLowerActive = false
                lastLowerHapticTick = nil
            }

        let thumbAngle = angleForValue(lowerValue)
        let pX = radius * CGFloat(cos(thumbAngle.radians))
        let pY = radius * CGFloat(sin(thumbAngle.radians))

        return style.makeLowerThumb(configuration: configuration)
            .offset(x: pX, y: pY)
            .gesture(gesture)
            .allowsHitTesting(isEnabled && !isUpperActive && !isRangeActive)
    }

    /// Builds the upper thumb gesture + positioned view.
    private func makeUpperThumbView(_ proxy: GeometryProxy) -> some View {
        let radius = min(proxy.size.width, proxy.size.height) / 2
        let middle = CGPoint(x: proxy.frame(in: .global).midX,
                             y: proxy.frame(in: .global).midY)

        let gesture = DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .onChanged { drag in
                if !isUpperActive {
                    // Seed from the actual touch-down position so the first delta is ~zero.
                    lastUpperRawAngle = rawAngle(from: middle, drag.startLocation)
                    upperHapticManager.prepare()
                    isUpperActive = true
                }
                updateUpperValue(from: middle, location: drag.location)
                let (_, transition) = applyAffinityToUpper(rawValue: upperValue)
                fireUpperHaptics(transition: transition)
            }
            .onEnded { drag in
                updateUpperValue(from: middle, location: drag.location)
                let (_, transition) = applyAffinityToUpper(rawValue: upperValue)
                fireUpperHaptics(transition: transition)
                isUpperActive = false
                lastUpperHapticTick = nil
            }

        let thumbAngle = angleForValue(upperValue)
        let pX = radius * CGFloat(cos(thumbAngle.radians))
        let pY = radius * CGFloat(sin(thumbAngle.radians))

        return style.makeUpperThumb(configuration: configuration)
            .offset(x: pX, y: pY)
            .gesture(gesture)
            .allowsHitTesting(isEnabled && !isLowerActive && !isRangeActive)
    }

    /// Builds an invisible hit-area overlay for the active track segment.
    ///
    /// The overlay uses a `CircularArc`-shaped stroke exactly matching the track, so only
    /// the filled arc region is tappable/draggable.
    private func makeRangeOverlay(_ proxy: GeometryProxy) -> some View {
        let middle = CGPoint(x: proxy.frame(in: .global).midX,
                             y: proxy.frame(in: .global).midY)

        let loPct = configuration.lowerPercent
        let hiPct = configuration.upperPercent
        let arcLength = hiPct - loPct

        // Thickness to match the track so the hit area covers exactly the filled arc.
        // We read this from the DefaultDoubleRSliderStyle if possible; fall back to 24.
        let hitThickness: CGFloat = 48  // generous hit zone (track + a bit extra)

        let gesture = DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .onChanged { drag in
                if !isRangeActive {
                    isRangeActive = true
                    lastRangeDragRawAngle = rawAngle(from: middle, drag.startLocation)
                }
                // Use stored previous raw angle for delta
                let newRaw = rawAngle(from: middle, drag.location)
                var delta = newRaw - lastRangeDragRawAngle
                if delta > 0.5  { delta -= 1.0 }
                if delta < -0.5 { delta += 1.0 }

                let span = range.upperBound - range.lowerBound
                guard span > 0 else { return }
                let valueDelta = delta * span

                let rangeWidth = upperValue - lowerValue
                var newLower = lowerValue + valueDelta
                var newUpper = upperValue + valueDelta

                if newLower < range.lowerBound {
                    newLower = range.lowerBound
                    newUpper = newLower + rangeWidth
                }
                if newUpper > range.upperBound {
                    newUpper = range.upperBound
                    newLower = newUpper - rangeWidth
                }
                newLower = Swift.max(range.lowerBound, newLower)
                newUpper = Swift.min(range.upperBound, newUpper)

                lowerValue = newLower
                upperValue = newUpper
                lastRangeDragRawAngle = newRaw
            }
            .onEnded { _ in
                isRangeActive = false
            }

        return CircularArc(percent: arcLength)
            .strokeBorder(Color.black.opacity(0.001), lineWidth: hitThickness)
            .rotationEffect(angleForValue(lowerValue))
            .padding((hitThickness - 24) / 2)
            .gesture(gesture)
            .allowsHitTesting(isEnabled && !isLowerActive && !isUpperActive)
    }

    // MARK: - Body

    /// Computes the offset to position a label outside a thumb at `value` on the radial track.
    private func labelOffsetForValue(_ v: Double, radius: CGFloat) -> CGSize {
        let thumbAngle = angleForValue(v)
        let labelRadius = radius + 36
        return CGSize(
            width:  labelRadius * CGFloat(cos(thumbAngle.radians)),
            height: labelRadius * CGFloat(sin(thumbAngle.radians))
        )
    }

    public var body: some View {
        let config = configuration
        let ticks = config.tickValues

        return style.makeTrack(configuration: config)
            .overlay(GeometryReader { proxy in
                let r = min(proxy.size.width, proxy.size.height) / 2
                ZStack(alignment: .center) {
                    // Tick marks (below thumbs)
                    ForEach(ticks, id: \.self) { tickValue in
                        style.makeTickMark(configuration: config, tickValue: tickValue)
                            .offset(tickMarkOffset(radius: r, tickValue: tickValue))
                    }

                    // Range drag overlay (below thumbs so thumbs win on overlap)
                    makeRangeOverlay(proxy)

                    // Lower thumb (renders on top for interaction)
                    makeLowerThumbView(proxy)

                    // Upper thumb
                    makeUpperThumbView(proxy)

                    // Labels (floating outside the thumbs)
                    if labelsVisibility != .hidden {
                        style.makeLowerLabel(configuration: config, content: AnyView(lowerLabel(lowerValue)))
                            .fixedSize()
                            .offset(labelOffsetForValue(lowerValue, radius: r))
                            .allowsHitTesting(false)

                        style.makeUpperLabel(configuration: config, content: AnyView(upperLabel(upperValue)))
                            .fixedSize()
                            .offset(labelOffsetForValue(upperValue, radius: r))
                            .allowsHitTesting(false)
                    }
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
            })
            .onAppear {
                lowerHapticManager.prepare()
                upperHapticManager.prepare()
            }
    }
}

extension DoubleRSlider where LowerLabel == Text, UpperLabel == Text {
    // MARK: - Init

    /// Creates a double radial (circular) slider.
    ///
    /// - Parameters:
    ///   - lowerValue: A binding to the start of the selected range.
    ///   - upperValue: A binding to the end of the selected range.
    ///   - range: The allowed value domain. Defaults to `0...1`.
    ///   - originAngle: The angle that corresponds to the minimum value. Defaults to `.zero`
    ///     (3 o'clock).
    ///   - minimumDistance: The smallest gap (in value units) allowed between the two thumbs.
    ///     Defaults to `0.05` of the range span.
    ///   - tickSpacing: Optional tick-mark placement configuration.
    ///   - affinityEnabled: When `true`, thumbs snap magnetically to nearby tick values.
    ///   - affinityRadius: Pull radius as a fraction of the value range.
    ///   - affinityResistance: Extra escape distance beyond `affinityRadius`.
    ///   - disableHaptics: Suppresses all haptic feedback when `true`.
    ///   - lowerLabel: A view builder that creates the label for the lower (start) thumb.
    ///   - upperLabel: A view builder that creates the label for the upper (end) thumb.
    public init(
        lowerValue: Binding<Double>,
        upperValue: Binding<Double>,
        range: ClosedRange<Double> = 0...1,
        originAngle: Angle = .zero,
        minimumDistance: Double? = nil,
        tickSpacing: TickMarkSpacing? = nil,
        affinityEnabled: Bool = false,
        affinityRadius: Double = 0.04,
        affinityResistance: Double = 0.02,
        disableHaptics: Bool = false,
        @ViewBuilder lowerLabel: @escaping (Double) -> LowerLabel = { Text($0, format: .number.precision(.fractionLength(2))) },
        @ViewBuilder upperLabel: @escaping (Double) -> UpperLabel = { Text($0, format: .number.precision(.fractionLength(2))) }
    ) {
        self._lowerValue = lowerValue
        self._upperValue = upperValue
        self.range = range
        self.originAngle = originAngle
        let span = range.upperBound - range.lowerBound
        self.minimumDistance = minimumDistance ?? (span > 0 ? span * 0.05 : 0)
        self.tickSpacing = tickSpacing
        self.affinityEnabled = affinityEnabled
        self.affinityRadius = affinityRadius
        self.affinityResistance = affinityResistance
        self.disableHaptics = disableHaptics
        self.lowerLabel = lowerLabel
        self.upperLabel = upperLabel
    }
}
