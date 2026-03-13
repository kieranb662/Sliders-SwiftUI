// Swift toolchain version 6.0
// Running macOS version 26.3
// Created on 3/13/26.
//
// Author: Kieran Brown
//

import SwiftUI

// MARK: - DoubleLSlider

/// A spatially adaptive linear range slider with a lower thumb, an upper thumb,
/// and a draggable active-track segment between them.
///
/// # Overview
/// ``DoubleLSlider`` lets the user select a range of values on a linear track at any angle.
/// Three elements are draggable:
/// - **Lower thumb** – moves the start of the range. Cannot cross the upper thumb.
/// - **Upper thumb** – moves the end of the range. Cannot cross the lower thumb.
/// - **Active track** – drags both thumbs simultaneously, keeping the range width constant.
///
/// # Labels
///
/// Floating labels are displayed near each thumb and update continuously as the thumbs move.
/// By default both labels show the current value formatted to two decimal places.
/// Provide custom labels via the `lowerLabel` and `upperLabel` parameters:
///
/// ```swift
/// DoubleLSlider(lowerValue: $lo, upperValue: $hi, range: 0...100) { v in
///     Text("from \(Int(v))")
/// } upperLabel: { v in
///     Text("to \(Int(v))")
/// }
/// ```
///
/// Label visibility is controlled by the `.labelsVisibility(_:)` environment modifier.
///
/// # Styling
/// Provide a custom ``DoubleLSliderStyle`` via `.doubleLSliderStyle(_:)`. Implement:
///   - `makeLowerThumb` – the draggable lower-thumb view
///   - `makeUpperThumb` – the draggable upper-thumb view
///   - `makeTrack` – the full track / fill view
///   - `makeTickMark(configuration:tickValue:)` – the view shown at each tick position
///   - `makeLowerLabel(configuration:content:)` – (optional, default provided) the container for the lower floating label
///   - `makeUpperLabel(configuration:content:)` – (optional, default provided) the container for the upper floating label
///
/// # Minimum Distance
/// `minimumDistance` (in value-domain units) ensures the two thumbs never overlap.
public struct DoubleLSlider<LowerLabel: View, UpperLabel: View>: View {
    @Environment(\.doubleLSliderStyle) private var style: AnyDoubleLSliderStyle
    @Environment(\.isEnabled) private var isEnabled: Bool
    @Environment(\.labelsVisibility) private var labelsVisibility

    // Haptic managers – one per thumb
    @State private var lowerHapticManager = LSliderHapticManager()
    @State private var upperHapticManager = LSliderHapticManager()

    // Active state
    @State private var isLowerActive = false
    @State private var isUpperActive = false
    @State private var isRangeActive = false

    // Tick haptic debounce
    @State private var lastLowerHapticTick: Double? = nil
    @State private var lastUpperHapticTick: Double? = nil

    // Limit-hit haptic debounce
    @State private var lowerAtLimit = false
    @State private var upperAtLimit = false

    // Affinity snap values
    @State private var snappedLowerTick: Double? = nil
    @State private var snappedUpperTick: Double? = nil

    // Range drag: the parameter [0,1] along the track at the start of each drag event.
    @State private var rangeDragLastParameter: Double = 0

    private let space = "DoubleLSlider"

    @Binding private var lowerValue: Double
    @Binding private var upperValue: Double

    private let range: ClosedRange<Double>
    private let angle: Angle
    private let keepThumbInTrack: Bool
    private let trackThickness: Double
    private let minimumDistance: Double
    private let tickMarkSpacing: TickMarkSpacing?
    private let hapticFeedbackEnabled: Bool
    private let affinityEnabled: Bool
    private let affinityRadius: Double
    private let affinityResistance: Double

    /// The user-provided label view for the lower (start) thumb.
    private var lowerLabel: (Double) -> LowerLabel
    /// The user-provided label view for the upper (end) thumb.
    private var upperLabel: (Double) -> UpperLabel

    // MARK: - Init

    /// Creates a double linear slider.
    ///
    /// - Parameters:
    ///   - lowerValue: A binding to the start of the selected range.
    ///   - upperValue: A binding to the end of the selected range.
    ///   - range: The allowed value domain. Defaults to `0...1`.
    ///   - angle: The angle of the slider's track. Defaults to `.zero` (horizontal).
    ///   - keepThumbInTrack: If `true`, the thumb centres are constrained to the track's extent.
    ///   - trackThickness: The thickness of the track.
    ///   - minimumDistance: The smallest gap (in value units) between the two thumbs.
    ///     Defaults to 5 % of the range span.
    ///   - tickMarkSpacing: Optional tick-mark placement configuration.
    ///   - hapticFeedbackEnabled: Whether crossing a tick mark triggers haptic feedback.
    ///   - affinityEnabled: When `true`, thumbs snap magnetically to nearby tick values.
    ///   - affinityRadius: Pull radius as a fraction of the value range.
    ///   - affinityResistance: Extra escape distance beyond `affinityRadius`.
    ///   - lowerLabel: A view builder closure that produces the label view for the lower thumb.
    ///   - upperLabel: A view builder closure that produces the label view for the upper thumb.
    public init(
        lowerValue: Binding<Double>,
        upperValue: Binding<Double>,
        range: ClosedRange<Double> = 0...1,
        angle: Angle = .zero,
        keepThumbInTrack: Bool = false,
        trackThickness: Double = 20,
        minimumDistance: Double? = nil,
        tickMarkSpacing: TickMarkSpacing? = nil,
        hapticFeedbackEnabled: Bool = true,
        affinityEnabled: Bool = false,
        affinityRadius: Double = 0.04,
        affinityResistance: Double = 0.02,
        @ViewBuilder lowerLabel: @escaping (Double) -> LowerLabel,
        @ViewBuilder upperLabel: @escaping (Double) -> UpperLabel
    ) {
        self._lowerValue = lowerValue
        self._upperValue = upperValue
        self.range = range
        self.angle = angle
        self.keepThumbInTrack = keepThumbInTrack
        self.trackThickness = trackThickness
        let span = range.upperBound - range.lowerBound
        self.minimumDistance = minimumDistance ?? (span > 0 ? span * 0.05 : 0)
        self.tickMarkSpacing = tickMarkSpacing
        self.hapticFeedbackEnabled = hapticFeedbackEnabled
        self.affinityEnabled = affinityEnabled
        self.affinityRadius = affinityRadius
        self.affinityResistance = affinityResistance
        self.lowerLabel = lowerLabel
        self.upperLabel = upperLabel
    }

    // MARK: - Tick Mark Resolution

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
        guard affinityEnabled, tickMarkSpacing != nil else { return (rawValue, .none) }
        let ticks = resolveTickValues()
        guard !ticks.isEmpty else { return (rawValue, .none) }
        let span = range.upperBound - range.lowerBound
        guard span > 0 else { return (rawValue, .none) }
        let pull    = affinityRadius * span
        let resist  = (affinityRadius + affinityResistance) * span

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
        guard affinityEnabled, tickMarkSpacing != nil else { return (rawValue, .none) }
        let ticks = resolveTickValues()
        guard !ticks.isEmpty else { return (rawValue, .none) }
        let span = range.upperBound - range.lowerBound
        guard span > 0 else { return (rawValue, .none) }
        let pull    = affinityRadius * span
        let resist  = (affinityRadius + affinityResistance) * span

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

    // MARK: - Geometry

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
        let halfTravel: Double = keepThumbInTrack ? (capsuleLength - T) / 2 : capsuleLength / 2
        let cx = w / 2
        let cy = h / 2
        let dx = cos(θ)
        let dy = sin(θ)
        let start = CGPoint(x: cx - halfTravel * dx, y: cy - halfTravel * dy)
        let end   = CGPoint(x: cx + halfTravel * dx, y: cy + halfTravel * dy)
        return (start, end)
    }

    /// Returns the offset from the ZStack centre for a given parameter value in [0,1].
    private func offsetForParameter(_ parameter: Double, proxy: GeometryProxy) -> CGSize {
        let (start, end) = calculateEndPoints(proxy)
        let x = (1 - parameter) * start.x + parameter * end.x - Double(proxy.size.width  / 2)
        let y = (1 - parameter) * start.y + parameter * end.y - Double(proxy.size.height / 2)
        return CGSize(width: x, height: y)
    }

    private func parameterForValue(_ v: Double) -> Double {
        let span = range.upperBound - range.lowerBound
        guard span > 0 else { return 0 }
        return (v - range.lowerBound) / span
    }

    private func valueForParameter(_ p: Double) -> Double {
        (range.upperBound - range.lowerBound) * p + range.lowerBound
    }

    // MARK: - Haptics

    private func playLimitHaptic() {
#if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.impactOccurred()
#endif
    }

    private func fireLowerHaptics(transition: AffinityTransition) {
        guard hapticFeedbackEnabled else { return }
        let atMin = lowerValue <= range.lowerBound
        let atMax = lowerValue >= upperValue - minimumDistance
        if atMin || atMax {
            if !lowerAtLimit { playLimitHaptic() }
            lowerAtLimit = true
        } else {
            lowerAtLimit = false
        }
        guard let _ = tickMarkSpacing else { return }
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

    private func fireUpperHaptics(transition: AffinityTransition) {
        guard hapticFeedbackEnabled else { return }
        let atMin = upperValue <= lowerValue + minimumDistance
        let atMax = upperValue >= range.upperBound
        if atMin || atMax {
            if !upperAtLimit { playLimitHaptic() }
            upperAtLimit = true
        } else {
            upperAtLimit = false
        }
        guard let _ = tickMarkSpacing else { return }
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

    // MARK: - Configuration

    private var configuration: DoubleLSliderConfiguration {
        DoubleLSliderConfiguration(
            isDisabled: !isEnabled,
            isLowerActive: isLowerActive,
            isUpperActive: isUpperActive,
            isRangeActive: isRangeActive,
            lowerValue: lowerValue,
            upperValue: upperValue,
            angle: angle,
            min: range.lowerBound,
            max: range.upperBound,
            keepThumbInTrack: keepThumbInTrack,
            trackThickness: trackThickness,
            tickMarkSpacing: tickMarkSpacing,
            tickValues: resolveTickValues(),
            affinityEnabled: affinityEnabled,
            snappedLowerTickValue: snappedLowerTick,
            snappedUpperTickValue: snappedUpperTick
        )
    }

    // MARK: - Subview Builders

    /// The lower thumb positioned along the track with its drag gesture attached.
    private func makeLowerThumbView(_ proxy: GeometryProxy) -> some View {
        let (start, end) = calculateEndPoints(proxy)

        let gesture = DragGesture(minimumDistance: 0, coordinateSpace: .named(space))
            .onChanged { drag in
                if !isLowerActive {
                    lowerHapticManager.prepare()
                    isLowerActive = true
                }
                let rawParam = Double(calculateParameter(start, end, drag.location))
                let rawValue = Swift.max(
                    range.lowerBound,
                    Swift.min(upperValue - minimumDistance, valueForParameter(rawParam))
                )
                let (snapped, transition) = applyAffinityToLower(rawValue: rawValue)
                lowerValue = snapped
                fireLowerHaptics(transition: transition)
            }
            .onEnded { drag in
                let rawParam = Double(calculateParameter(start, end, drag.location))
                let rawValue = Swift.max(
                    range.lowerBound,
                    Swift.min(upperValue - minimumDistance, valueForParameter(rawParam))
                )
                let (snapped, transition) = applyAffinityToLower(rawValue: rawValue)
                lowerValue = snapped
                fireLowerHaptics(transition: transition)
                isLowerActive = false
                lastLowerHapticTick = nil
            }

        return style.makeLowerThumb(configuration: configuration)
            .offset(offsetForParameter(parameterForValue(lowerValue), proxy: proxy))
            .gesture(gesture)
            .allowsHitTesting(isEnabled && !isUpperActive && !isRangeActive)
    }

    /// The upper thumb positioned along the track with its drag gesture attached.
    private func makeUpperThumbView(_ proxy: GeometryProxy) -> some View {
        let (start, end) = calculateEndPoints(proxy)

        let gesture = DragGesture(minimumDistance: 0, coordinateSpace: .named(space))
            .onChanged { drag in
                if !isUpperActive {
                    upperHapticManager.prepare()
                    isUpperActive = true
                }
                let rawParam = Double(calculateParameter(start, end, drag.location))
                let rawValue = Swift.max(
                    lowerValue + minimumDistance,
                    Swift.min(range.upperBound, valueForParameter(rawParam))
                )
                let (snapped, transition) = applyAffinityToUpper(rawValue: rawValue)
                upperValue = snapped
                fireUpperHaptics(transition: transition)
            }
            .onEnded { drag in
                let rawParam = Double(calculateParameter(start, end, drag.location))
                let rawValue = Swift.max(
                    lowerValue + minimumDistance,
                    Swift.min(range.upperBound, valueForParameter(rawParam))
                )
                let (snapped, transition) = applyAffinityToUpper(rawValue: rawValue)
                upperValue = snapped
                fireUpperHaptics(transition: transition)
                isUpperActive = false
                lastUpperHapticTick = nil
            }

        return style.makeUpperThumb(configuration: configuration)
            .offset(offsetForParameter(parameterForValue(upperValue), proxy: proxy))
            .gesture(gesture)
            .allowsHitTesting(isEnabled && !isLowerActive && !isRangeActive)
    }

    /// An invisible hit region covering the active track between the two thumbs.
    ///
    /// The hit area is a rotated capsule whose length spans the distance between the two
    /// thumb centres, giving a precise and comfortable drag target.
    private func makeRangeOverlay(_ proxy: GeometryProxy) -> some View {
        let (start, end) = calculateEndPoints(proxy)
        let span = range.upperBound - range.lowerBound

        // Compute the pixel positions of the two thumb centres
        let loPct = parameterForValue(lowerValue)
        let hiPct = parameterForValue(upperValue)
        let loPt  = CGPoint(
            x: (1 - loPct) * start.x + loPct * end.x,
            y: (1 - loPct) * start.y + loPct * end.y
        )
        let hiPt  = CGPoint(
            x: (1 - hiPct) * start.x + hiPct * end.x,
            y: (1 - hiPct) * start.y + hiPct * end.y
        )
        let segmentLength = sqrt(pow(hiPt.x - loPt.x, 2) + pow(hiPt.y - loPt.y, 2))
        let hitThickness  = CGFloat(trackThickness * 2 + 8)  // track + a little extra for touch comfort

        // Centre of the segment in the coordinate space of the ZStack
        let midX = (loPt.x + hiPt.x) / 2 - Double(proxy.size.width  / 2)
        let midY = (loPt.y + hiPt.y) / 2 - Double(proxy.size.height / 2)

        let gesture = DragGesture(minimumDistance: 0, coordinateSpace: .named(space))
            .onChanged { drag in
                if !isRangeActive {
                    isRangeActive = true
                    // Seed the last parameter so the first delta is zero
                    rangeDragLastParameter = Double(calculateParameter(start, end, drag.startLocation))
                    lowerHapticManager.prepare()
                    upperHapticManager.prepare()
                }
                let currentParam = Double(calculateParameter(start, end, drag.location))
                let delta = currentParam - rangeDragLastParameter
                rangeDragLastParameter = currentParam

                guard span > 0, abs(delta) > 0 else { return }
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
                lowerValue = Swift.max(range.lowerBound, newLower)
                upperValue = Swift.min(range.upperBound, newUpper)
            }
            .onEnded { _ in
                isRangeActive = false
            }

        return Capsule()
            .fill(Color.black.opacity(0.001))
            .frame(width: segmentLength, height: hitThickness)
            .rotationEffect(angle)
            .offset(x: midX, y: midY)
            .gesture(gesture)
            .allowsHitTesting(isEnabled && !isLowerActive && !isUpperActive)
    }

    // MARK: - Body

    /// Computes the perpendicular offset to position a label above a thumb at `parameter`.
    private func labelOffsetForParameter(_ parameter: Double, proxy: GeometryProxy) -> CGSize {
        let thumb = offsetForParameter(parameter, proxy: proxy)
        let θ = angle.radians
        let perpX = -sin(θ)
        let perpY = cos(θ)
        let labelDistance = trackThickness * 2 + 16
        return CGSize(
            width:  thumb.width  + perpX * labelDistance,
            height: thumb.height - perpY * labelDistance
        )
    }

    public var body: some View {
        let config = configuration
        let ticks  = config.tickValues

        GeometryReader { proxy in
            ZStack {
                // Track
                style.makeTrack(configuration: config)

                // Tick marks (below thumbs)
                ForEach(ticks, id: \.self) { tickValue in
                    style.makeTickMark(configuration: config, tickValue: tickValue)
                        .offset(offsetForParameter(parameterForValue(tickValue), proxy: proxy))
                }

                // Range drag overlay (below thumbs so thumbs win on overlap)
                makeRangeOverlay(proxy)

                // Lower thumb
                makeLowerThumbView(proxy)

                // Upper thumb
                makeUpperThumbView(proxy)

                // Labels (floating above thumbs)
                if labelsVisibility != .hidden {
                    style.makeLowerLabel(configuration: config, content: AnyView(lowerLabel(lowerValue)))
                        .fixedSize()
                        .offset(labelOffsetForParameter(parameterForValue(lowerValue), proxy: proxy))
                        .allowsHitTesting(false)

                    style.makeUpperLabel(configuration: config, content: AnyView(upperLabel(upperValue)))
                        .fixedSize()
                        .offset(labelOffsetForParameter(parameterForValue(upperValue), proxy: proxy))
                        .allowsHitTesting(false)
                }
            }
            .coordinateSpace(name: space)
        }
        .onAppear {
            lowerHapticManager.prepare()
            upperHapticManager.prepare()
        }
    }
}

extension DoubleLSlider where LowerLabel == Text, UpperLabel == Text {
    
    // MARK: - Init

    /// Creates a double linear slider.
    ///
    /// - Parameters:
    ///   - lowerValue: A binding to the start of the selected range.
    ///   - upperValue: A binding to the end of the selected range.
    ///   - range: The allowed value domain. Defaults to `0...1`.
    ///   - angle: The angle of the slider's track. Defaults to `.zero` (horizontal).
    ///   - keepThumbInTrack: If `true`, the thumb centres are constrained to the track's extent.
    ///   - trackThickness: The thickness of the track.
    ///   - minimumDistance: The smallest gap (in value units) between the two thumbs.
    ///     Defaults to 5 % of the range span.
    ///   - tickMarkSpacing: Optional tick-mark placement configuration.
    ///   - hapticFeedbackEnabled: Whether crossing a tick mark triggers haptic feedback.
    ///   - affinityEnabled: When `true`, thumbs snap magnetically to nearby tick values.
    ///   - affinityRadius: Pull radius as a fraction of the value range.
    ///   - affinityResistance: Extra escape distance beyond `affinityRadius`.
    ///   - lowerLabel: A view builder closure that produces the label view for the lower thumb.
    ///   - upperLabel: A view builder closure that produces the label view for the upper thumb.
    public init(
        lowerValue: Binding<Double>,
        upperValue: Binding<Double>,
        range: ClosedRange<Double> = 0...1,
        angle: Angle = .zero,
        keepThumbInTrack: Bool = false,
        trackThickness: Double = 20,
        minimumDistance: Double? = nil,
        tickMarkSpacing: TickMarkSpacing? = nil,
        hapticFeedbackEnabled: Bool = true,
        affinityEnabled: Bool = false,
        affinityRadius: Double = 0.04,
        affinityResistance: Double = 0.02,
        @ViewBuilder lowerLabel: @escaping (Double) -> LowerLabel = { Text($0, format: .number.precision(.fractionLength(2))) },
        @ViewBuilder upperLabel: @escaping (Double) -> UpperLabel = { Text($0, format: .number.precision(.fractionLength(2))) }
    ) {
        self._lowerValue = lowerValue
        self._upperValue = upperValue
        self.range = range
        self.angle = angle
        self.keepThumbInTrack = keepThumbInTrack
        self.trackThickness = trackThickness
        let span = range.upperBound - range.lowerBound
        self.minimumDistance = minimumDistance ?? (span > 0 ? span * 0.05 : 0)
        self.tickMarkSpacing = tickMarkSpacing
        self.hapticFeedbackEnabled = hapticFeedbackEnabled
        self.affinityEnabled = affinityEnabled
        self.affinityRadius = affinityRadius
        self.affinityResistance = affinityResistance
        self.lowerLabel = lowerLabel
        self.upperLabel = upperLabel
    }
}
