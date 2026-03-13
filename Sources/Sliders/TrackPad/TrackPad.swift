// Swift toolchain version 6.0
// Running macOS version 26.3
// Created on 4/6/20.
//
// Author: Kieran Brown
//

import SwiftUI


// MARK: - TrackPad

/// # Track Pad
///
/// The 2-D equivalent of a `Slider`. A draggable thumb moves freely inside a rectangular
/// area, controlling independent x and y values simultaneously.
///
/// - parameters:
///     - value: A `CGPoint` whose `x` and `y` components are controlled by the trackpad.
///     - rangeX: The `ClosedRange<CGFloat>` for the x component.
///     - rangeY: The `ClosedRange<CGFloat>` for the y component.
///     - showPreviousValue: When `true`, a visual indicator marks the last committed position
///       (the position when the user lifted their finger). The indicator has an affinity with
///       that position — when the thumb is dragged slowly near it, it snaps back.
///     - previousValueAffinityRadius: Fraction of the track diagonal within which the previous-
///       value snap becomes active (default `0.06`).
///     - previousValueAffinityResistance: Extra fraction beyond `previousValueAffinityRadius`
///       the drag must travel before the snap releases (default `0.03`).
///     - previousValueVelocityThreshold: Maximum drag speed (pts/s) at which the affinity snap
///       can engage. Above this speed the snap is ignored, enabling fast swipes to pass through
///       freely (default `180`).
///     - tickCountX: Number of tick-mark intervals along the x-axis (default `0` = off).
///     - tickCountY: Number of tick-mark intervals along the y-axis (default `0` = off).
///     - tickAffinityRadius: Fraction of the track diagonal within which the thumb snaps to
///       the nearest tick intersection (default `0.05`).
///     - tickAffinityResistance: Extra fraction beyond `tickAffinityRadius` the drag must
///       travel to escape a tick snap (default `0.02`).
///     - tickAffinityVelocityThreshold: Maximum drag speed (pts/s) at which tick snapping can
///       engage (default `150`).
///
/// ## Tick Marks
///
/// Set `tickCountX` and/or `tickCountY` to positive integers to divide the track into a
/// regular grid of tick positions.  When both are > 0 the intersections form snap points.
/// When only one axis has ticks, lines are drawn and single-axis snapping occurs.
/// Use the fluent modifiers `.tickCountX(_:)`, `.tickCountY(_:)`, `.tickAffinityRadius(_:)`,
/// `.tickAffinityResistance(_:)`, and `.tickAffinityVelocityThreshold(_:)` to configure the
/// behaviour.
///
/// ## Styling
///
/// Conform to `TrackPadStyle` and implement:
///  - `makeThumb` – the draggable thumb view.
///  - `makeTrack` – the rectangular track background.
///  - `makePreviousValueIndicator` – (optional, default provided) the marker shown at the
///    previous position.
///  - `makeTickMarks` – (optional, default provided) the grid rendered inside the track.
///
/// Apply your style with `.trackPadStyle(MyStyle())`.
///
public struct TrackPad<LabelView: View>: View {
    // MARK: State and Setup
    @Environment(\.trackPadStyle) private var style: AnyTrackPadStyle
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.labelsVisibility) private var labelsVisibility
    private let space: String = "Track Pad"
    @State private var isActive: Bool = false
    @State private var atXLimit: Bool = false
    @State private var atYLimit: Bool = false
    /// The committed position from the last completed drag (set on `onEnded`).
    @State private var previousValue: CGPoint? = nil
    /// Whether the thumb is currently magnetically snapped to the previous-value position.
    @State private var isSnappedToPrevious: Bool = false
    /// Whether the thumb is currently snapped to a tick-mark intersection.
    @State private var isSnappedToTick: Bool = false
    /// The tick intersection (normalised [0,1]) the thumb is currently snapped to.
    @State private var snappedTickPct: CGPoint? = nil

    // MARK: Inputs
    @Binding public var value: CGPoint
    public var rangeX: ClosedRange<CGFloat> = 0...1
    public var rangeY: ClosedRange<CGFloat> = 0...1

    /// When `true`, a visual indicator marks the last committed position and affinity snap
    /// is enabled near it.
    public var showPreviousValue: Bool = false

    /// Fraction of the track diagonal within which the previous-value snap activates.
    public var previousValueAffinityRadius: Double = 0.06
    /// Extra fraction beyond `previousValueAffinityRadius` before the snap releases.
    public var previousValueAffinityResistance: Double = 0.03
    /// Maximum drag velocity (pts/s) at which the snap can engage.
    public var previousValueVelocityThreshold: Double = 180.0

    // MARK: Tick mark inputs

    /// Number of equal intervals along the x-axis.  `0` disables tick marks on that axis.
    public var tickCountX: Int = 0
    /// Number of equal intervals along the y-axis.  `0` disables tick marks on that axis.
    public var tickCountY: Int = 0
    /// Fraction of the track diagonal within which the thumb snaps to the nearest tick.
    public var tickAffinityRadius: Double = 0.05
    /// Extra fraction the drag must travel beyond `tickAffinityRadius` to escape a tick snap.
    public var tickAffinityResistance: Double = 0.02
    /// Maximum drag speed (pts/s) at which tick-mark snapping can engage.
    public var tickAffinityVelocityThreshold: Double = 150.0

    // MARK: Single-tap select

    /// When `true`, a single tap on the track immediately moves the thumb to the tapped position.
    public var allowsSingleTapSelect: Bool = false

    /// The user-provided label view displayed near the thumb.
    private var label: (_ x: Double, _ y: Double) -> LabelView
 
    // MARK: - Initialisers

    /// Creates a `TrackPad` with independent x and y ranges.
    ///
    /// - Parameters:
    ///   - value: A binding to the `CGPoint` whose `x` and `y` components the trackpad controls.
    ///   - rangeX: The closed range of valid values along the x-axis. Defaults to `0...1`.
    ///   - rangeY: The closed range of valid values along the y-axis. Defaults to `0...1`.
    ///   - label: A view builder closure that creates the label view.
    public init(
        _ value: Binding<CGPoint>,
        rangeX: ClosedRange<CGFloat> = 0...1,
        rangeY: ClosedRange<CGFloat> = 0...1,
        @ViewBuilder label: @escaping (_ x: Double, _ y: Double) -> LabelView
    ) {
        self._value = value
        self.rangeX = rangeX
        self.rangeY = rangeY
        self.label = label
    }

    /// Creates a `TrackPad` with a single range applied to both axes.
    ///
    /// - Parameters:
    ///   - value: A binding to the `CGPoint` the trackpad controls.
    ///   - range: The closed range used for both the x-axis and y-axis. Defaults to `0...1`.
    ///   - label: A view builder closure that creates the label view.
    public init(
        _ value: Binding<CGPoint>,
        range: ClosedRange<CGFloat> = 0...1,
        @ViewBuilder label: @escaping (_ x: Double, _ y: Double) -> LabelView
    ) {
        self._value = value
        self.rangeX = range
        self.rangeY = range
        self.label = label
    }

    /// Creates a `TrackPad` backed by separate `Double` bindings for each axis, with
    /// independent ranges.
    ///
    /// - Parameters:
    ///   - x: A binding to the horizontal value.
    ///   - y: A binding to the vertical value.
    ///   - rangeX: The closed range of valid values along the x-axis. Defaults to `0...1`.
    ///   - rangeY: The closed range of valid values along the y-axis. Defaults to `0...1`.
    ///   - label: A view builder closure that creates the label view.
    public init(
        x: Binding<Double>,
        y: Binding<Double>,
        rangeX: ClosedRange<CGFloat> = 0...1,
        rangeY: ClosedRange<CGFloat> = 0...1,
        @ViewBuilder label: @escaping (_ x: Double, _ y: Double) -> LabelView
    ) {
        self._value = Binding(
            get: { CGPoint(x: x.wrappedValue, y: y.wrappedValue) },
            set: {
                x.wrappedValue = Double($0.x)
                y.wrappedValue = Double($0.y)
            }
        )
        self.rangeX = rangeX
        self.rangeY = rangeY
        self.label = label
    }

    /// Creates a `TrackPad` backed by separate `Double` bindings for each axis, with the
    /// same range applied to both axes.
    ///
    /// - Parameters:
    ///   - x: A binding to the horizontal value.
    ///   - y: A binding to the vertical value.
    ///   - range: The closed range used for both axes. Defaults to `0...1`.
    ///   - label: A view builder closure that creates the label view.
    public init(
        x: Binding<Double>,
        y: Binding<Double>,
        range: ClosedRange<CGFloat> = 0...1,
        @ViewBuilder label: @escaping (_ x: Double, _ y: Double) -> LabelView
    ) {
        self._value = Binding(
            get: { CGPoint(x: x.wrappedValue, y: y.wrappedValue) },
            set: {
                x.wrappedValue = Double($0.x)
                y.wrappedValue = Double($0.y)
            }
        )
        self.rangeX = range
        self.rangeY = range
        self.label = label
    }
    
    // MARK: - Configuration

    private func makeConfiguration() -> TrackPadConfiguration {
        let pctX = Double((value.x - rangeX.lowerBound) / (rangeX.upperBound - rangeX.lowerBound))
        let pctY = Double((value.y - rangeY.lowerBound) / (rangeY.upperBound - rangeY.lowerBound))

        var prevPctX: Double? = nil
        var prevPctY: Double? = nil
        var prevValX: Double? = nil
        var prevValY: Double? = nil

        if let prev = previousValue {
            prevPctX = Double((prev.x - rangeX.lowerBound) / (rangeX.upperBound - rangeX.lowerBound))
            prevPctY = Double((prev.y - rangeY.lowerBound) / (rangeY.upperBound - rangeY.lowerBound))
            prevValX = Double(prev.x)
            prevValY = Double(prev.y)
        }

        return TrackPadConfiguration(
            isDisabled: !isEnabled,
            isActive: isActive,
            pctX: pctX,
            pctY: pctY,
            valueX: Double(value.x),
            valueY: Double(value.y),
            minX: Double(rangeX.lowerBound),
            maxX: Double(rangeX.upperBound),
            minY: Double(rangeY.lowerBound),
            maxY: Double(rangeY.upperBound),
            showPreviousValue: showPreviousValue,
            previousPctX: prevPctX,
            previousPctY: prevPctY,
            previousValueX: prevValX,
            previousValueY: prevValY,
            isSnappedToPrevious: isSnappedToPrevious,
            tickCountX: tickCountX,
            tickCountY: tickCountY,
            isSnappedToTick: isSnappedToTick,
            snappedTickPctX: snappedTickPct.map { Double($0.x) },
            snappedTickPctY: snappedTickPct.map { Double($0.y) }
        )
    }
    
    // MARK: - Fluent configuration modifiers
    
    /// Shows or hides the previous-value indicator.
    ///
    /// When `true`, a visual marker is shown at the last committed position and
    /// affinity snapping towards it is enabled.
    public func showPreviousValue(_ show: Bool) -> TrackPad {
        var copy = self
        copy.showPreviousValue = show
        return copy
    }
    
    /// Sets the affinity pull radius for the previous-value indicator.
    ///
    /// - Parameter radius: Fraction of the track diagonal within which the snap activates.
    public func previousValueAffinityRadius(_ radius: Double) -> TrackPad {
        var copy = self
        copy.previousValueAffinityRadius = radius
        return copy
    }
    
    /// Sets the affinity resistance for the previous-value indicator.
    ///
    /// - Parameter resistance: Extra fraction beyond the pull radius the drag must travel to escape.
    public func previousValueAffinityResistance(_ resistance: Double) -> TrackPad {
        var copy = self
        copy.previousValueAffinityResistance = resistance
        return copy
    }
    
    /// Sets the maximum drag velocity at which the previous-value snap can engage.
    ///
    /// - Parameter threshold: Speed in points per second. Drags faster than this pass through freely.
    public func previousValueVelocityThreshold(_ threshold: Double) -> TrackPad {
        var copy = self
        copy.previousValueVelocityThreshold = threshold
        return copy
    }

    // MARK: Tick mark fluent modifiers

    /// Sets the number of tick-mark intervals along the x-axis.
    ///
    /// - Parameter count: Number of equal intervals (e.g. `4` → 5 lines at 0%, 25%, 50%, 75%, 100%).
    ///   Pass `0` to hide tick marks on this axis.
    public func tickCountX(_ count: Int) -> TrackPad {
        var copy = self
        copy.tickCountX = max(0, count)
        return copy
    }

    /// Sets the number of tick-mark intervals along the y-axis.
    ///
    /// - Parameter count: Number of equal intervals.  Pass `0` to hide tick marks on this axis.
    public func tickCountY(_ count: Int) -> TrackPad {
        var copy = self
        copy.tickCountY = max(0, count)
        return copy
    }

    /// Convenience: sets the same tick-mark interval count on both axes.
    ///
    /// Equivalent to calling `.tickCountX(_:)` and `.tickCountY(_:)` with the same value.
    ///
    /// - Parameter count: Number of equal intervals on each axis.  Pass `0` to hide tick marks.
    public func tickCount(_ count: Int) -> TrackPad {
        var copy = self
        let c = max(0, count)
        copy.tickCountX = c
        copy.tickCountY = c
        return copy
    }

    /// Sets the affinity pull radius for tick-mark snapping.
    ///
    /// - Parameter radius: Fraction of the track diagonal within which the snap activates.
    public func tickAffinityRadius(_ radius: Double) -> TrackPad {
        var copy = self
        copy.tickAffinityRadius = radius
        return copy
    }

    /// Sets the resistance beyond the pull radius before a tick snap releases.
    ///
    /// - Parameter resistance: Extra fraction the drag must travel to escape.
    public func tickAffinityResistance(_ resistance: Double) -> TrackPad {
        var copy = self
        copy.tickAffinityResistance = resistance
        return copy
    }

    /// Sets the maximum drag speed at which tick-mark snapping can engage.
    ///
    /// - Parameter threshold: Speed in points per second.
    public func tickAffinityVelocityThreshold(_ threshold: Double) -> TrackPad {
        var copy = self
        copy.tickAffinityVelocityThreshold = threshold
        return copy
    }

    /// Enables or disables placing the thumb by tapping directly on the track.
    ///
    /// - Parameter allows: When `true`, a single tap on the track moves the thumb to that position.
    public func allowsSingleTapSelect(_ allows: Bool) -> TrackPad {
        var copy = self
        copy.allowsSingleTapSelect = allows
        return copy
    }

    // MARK: - Calculations
    
    /// Converts a drag location into a clamped `value`, firing edge haptics as needed.
    /// Returns the raw (unconstrained) normalised fractions before clamping.
    private func constrainValue(_ proxy: GeometryProxy, _ location: CGPoint) {
        let w = proxy.size.width
        let h = proxy.size.height
        let pctX = (location.x / w).clamped(to: 0...1)
        let pctY = (location.y / h).clamped(to: 0...1)
        
        // Horizontal haptic handling
        if pctX == 1 || pctX == 0 {
            if !atXLimit { impactOccured() }
            atXLimit = true
        } else {
            atXLimit = false
        }
        // Vertical haptic handling
        if pctY == 1 || pctY == 0 {
            if !atYLimit { impactOccured() }
            atYLimit = true
        } else {
            atYLimit = false
        }
        
        let newX = pctX * (rangeX.upperBound - rangeX.lowerBound) + rangeX.lowerBound
        let newY = pctY * (rangeY.upperBound - rangeY.lowerBound) + rangeY.lowerBound
        value = CGPoint(x: newX, y: newY)
    }
    
    /// Applies previous-value affinity, potentially snapping `value` to `previousValue`.
    ///
    /// - Parameters:
    ///   - proxy: The geometry of the track, used to compute the diagonal for distance normalisation.
    ///   - velocity: The current drag velocity in points per second.
    private func applyPreviousValueAffinity(_ proxy: GeometryProxy, velocity: CGSize) {
        guard showPreviousValue, let prev = previousValue else { return }
        
        let w = Double(proxy.size.width)
        let h = Double(proxy.size.height)
        let diagonal = (w * w + h * h).squareRoot()
        guard diagonal > 0 else { return }
        
        // Current position in normalised [0,1] space
        let currentPctX = Double((value.x - rangeX.lowerBound) / (rangeX.upperBound - rangeX.lowerBound))
        let currentPctY = Double((value.y - rangeY.lowerBound) / (rangeY.upperBound - rangeY.lowerBound))
        
        // Previous position in normalised [0,1] space
        let prevPctX = Double((prev.x - rangeX.lowerBound) / (rangeX.upperBound - rangeX.lowerBound))
        let prevPctY = Double((prev.y - rangeY.lowerBound) / (rangeY.upperBound - rangeY.lowerBound))
        
        // Distance in screen space between current thumb and previous-value position
        let dx = (currentPctX - prevPctX) * w
        let dy = (currentPctY - prevPctY) * h
        let screenDistance = (dx * dx + dy * dy).squareRoot()
        let normalisedDistance = screenDistance / diagonal
        
        let speed = (Double(velocity.width) * Double(velocity.width) + Double(velocity.height) * Double(velocity.height)).squareRoot()
        
        let pullRadius     = previousValueAffinityRadius
        let resistRadius   = previousValueAffinityRadius + previousValueAffinityResistance
        
        if isSnappedToPrevious {
            // ── Hold phase: stay snapped until drag escapes resistance zone ──
            if normalisedDistance > resistRadius {
                isSnappedToPrevious = false
            } else {
                // Keep value pinned to previous
                value = prev
            }
        } else {
            // ── Pull phase: snap when close enough AND moving slowly ──────────
            if normalisedDistance <= pullRadius && speed <= previousValueVelocityThreshold {
                isSnappedToPrevious = true
                value = prev
                playSnapHaptic()
            }
        }
    }
    
    /// Applies tick-mark affinity, potentially snapping `value` to the nearest tick intersection.
    ///
    /// - Parameters:
    ///   - proxy: The geometry of the track, used to compute the diagonal.
    ///   - velocity: The current drag velocity in points per second.
    private func applyTickAffinity(_ proxy: GeometryProxy, velocity: CGSize) {
        let nx = tickCountX
        let ny = tickCountY
        guard nx > 0 || ny > 0 else { return }

        let w = Double(proxy.size.width)
        let h = Double(proxy.size.height)
        let diagonal = (w * w + h * h).squareRoot()
        guard diagonal > 0 else { return }

        let currentPctX = Double((value.x - rangeX.lowerBound) / (rangeX.upperBound - rangeX.lowerBound))
        let currentPctY = Double((value.y - rangeY.lowerBound) / (rangeY.upperBound - rangeY.lowerBound))

        let speed = (Double(velocity.width) * Double(velocity.width) + Double(velocity.height) * Double(velocity.height)).squareRoot()

        let pullRadius   = tickAffinityRadius
        let resistRadius = tickAffinityRadius + tickAffinityResistance

        if isSnappedToTick, let snapped = snappedTickPct {
            // ── Hold phase: stay snapped until drag escapes resistance zone ───────
            let dxS = (currentPctX - Double(snapped.x)) * w
            let dyS = (currentPctY - Double(snapped.y)) * h
            let dist = (dxS * dxS + dyS * dyS).squareRoot() / diagonal

            if dist > resistRadius {
                isSnappedToTick = false
                snappedTickPct = nil
            } else {
                // Reconstruct domain value for the snapped tick
                let snapX = CGFloat(snapped.x) * (rangeX.upperBound - rangeX.lowerBound) + rangeX.lowerBound
                let snapY = CGFloat(snapped.y) * (rangeY.upperBound - rangeY.lowerBound) + rangeY.lowerBound
                value = CGPoint(x: snapX, y: snapY)
            }
        } else {
            // ── Pull phase: find nearest tick and snap if within radius ───────────
            // Nearest tick fraction on each axis
            let nearPctX: Double = nx > 0 ? (Double(Int((currentPctX * Double(nx)).rounded())) / Double(nx)).clamped(to: 0...1) : currentPctX
            let nearPctY: Double = ny > 0 ? (Double(Int((currentPctY * Double(ny)).rounded())) / Double(ny)).clamped(to: 0...1) : currentPctY

            let dx = (currentPctX - nearPctX) * w
            let dy = (currentPctY - nearPctY) * h
            let dist = (dx * dx + dy * dy).squareRoot() / diagonal

            if dist <= pullRadius && speed <= tickAffinityVelocityThreshold {
                isSnappedToTick = true
                snappedTickPct = CGPoint(x: nearPctX, y: nearPctY)
                let snapX = CGFloat(nearPctX) * (rangeX.upperBound - rangeX.lowerBound) + rangeX.lowerBound
                let snapY = CGFloat(nearPctY) * (rangeY.upperBound - rangeY.lowerBound) + rangeY.lowerBound
                value = CGPoint(x: snapX, y: snapY)
                playSnapHaptic()
            }
        }
    }
    
    private func thumbOffset(_ proxy: GeometryProxy) -> CGSize {
        let w = proxy.size.width
        let h = proxy.size.height
        let pctX = (value.x - rangeX.lowerBound) / (rangeX.upperBound - rangeX.lowerBound)
        let pctY = (value.y - rangeY.lowerBound) / (rangeY.upperBound - rangeY.lowerBound)
        return CGSize(width: w * (pctX - 0.5), height: h * (pctY - 0.5))
    }
    
    private func previousValueOffset(_ proxy: GeometryProxy) -> CGSize {
        guard let prev = previousValue else { return .zero }
        let w = proxy.size.width
        let h = proxy.size.height
        let pctX = (prev.x - rangeX.lowerBound) / (rangeX.upperBound - rangeX.lowerBound)
        let pctY = (prev.y - rangeY.lowerBound) / (rangeY.upperBound - rangeY.lowerBound)
        return CGSize(width: w * (pctX - 0.5), height: h * (pctY - 0.5))
    }
    
    // MARK: - Haptics
    
    private func impactOccured() {
#if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
#endif
    }
    
    private func playSnapHaptic() {
#if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred(intensity: 0.7)
#endif
    }
    
    // MARK: - View

    /// Computes the offset to position a label above the thumb.
    private func labelOffset(_ proxy: GeometryProxy) -> CGSize {
        let thumb = thumbOffset(proxy)
        return CGSize(width: thumb.width, height: thumb.height - 36)
    }

    public var body: some View {
        ZStack {
            style.makeTrack(configuration: makeConfiguration())
            GeometryReader { proxy in
                ZStack(alignment: .center) {
                    // Tick marks (rendered below the previous-value indicator and thumb)
                    if tickCountX > 0 || tickCountY > 0 {
                        style.makeTickMarks(configuration: makeConfiguration())
                            .frame(width: proxy.size.width, height: proxy.size.height)
                    }

                    // Previous-value indicator (rendered below the thumb)
                    if showPreviousValue, previousValue != nil {
                        style.makePreviousValueIndicator(configuration: makeConfiguration())
                            .offset(previousValueOffset(proxy))
                    }
                    
                    // Track tap gesture
                    if allowsSingleTapSelect {
                        Rectangle()
                            .fill(Color.clear)
                            .contentShape(Rectangle())
                            .gesture(
                                SpatialTapGesture(coordinateSpace: .named(space))
                                    .onEnded { tap in
                                        constrainValue(proxy, tap.location)
                                        isActive = false
                                        isSnappedToPrevious = false
                                        isSnappedToTick = false
                                        snappedTickPct = nil
                                        if showPreviousValue {
                                            previousValue = value
                                        }
                                    }
                            )
                    }

                    // Thumb
                    style.makeThumb(configuration: makeConfiguration())
                        .offset(thumbOffset(proxy))
                        .gesture(
                            DragGesture(minimumDistance: 0, coordinateSpace: .named(space))
                                .onChanged { drag in
                                    constrainValue(proxy, drag.location)
                                    applyTickAffinity(proxy, velocity: drag.velocity)
                                    applyPreviousValueAffinity(proxy, velocity: drag.velocity)
                                    isActive = true
                                }
                                .onEnded { drag in
                                    constrainValue(proxy, drag.location)
                                    // Apply affinity one final time before committing
                                    applyTickAffinity(proxy, velocity: drag.velocity)
                                    applyPreviousValueAffinity(proxy, velocity: drag.velocity)
                                    isActive = false
                                    isSnappedToPrevious = false
                                    isSnappedToTick = false
                                    snappedTickPct = nil
                                    // Record the committed position as the new previous value
                                    if showPreviousValue {
                                        previousValue = value
                                    }
                                }
                        )
                        .allowsHitTesting(isEnabled)

                    // Label (floating above the thumb)
                    if labelsVisibility != .hidden {
                        style.makeLabel(configuration: makeConfiguration(), content: AnyView(label(value.x, value.y)))
                            .fixedSize()
                            .offset(labelOffset(proxy))
                            .allowsHitTesting(false)
                    }
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
            }
        }
        .coordinateSpace(name: space)
    }
}

extension TrackPad where LabelView == Text {
    // MARK: - Initialisers

    /// Creates a `TrackPad` with independent x and y ranges.
    ///
    /// - Parameters:
    ///   - value: A binding to the `CGPoint` whose `x` and `y` components the trackpad controls.
    ///   - rangeX: The closed range of valid values along the x-axis. Defaults to `0...1`.
    ///   - rangeY: The closed range of valid values along the y-axis. Defaults to `0...1`.
    ///   - label: A view builder closure that creates the label view.
    public init(
        _ value: Binding<CGPoint>,
        rangeX: ClosedRange<CGFloat> = 0...1,
        rangeY: ClosedRange<CGFloat> = 0...1,
        @ViewBuilder label: @escaping (_ x: Double, _ y: Double) -> LabelView = {
            Text("\(Text($0, format: .number.precision(.fractionLength(2)))), \(Text($1, format: .number.precision(.fractionLength(2))))")
        }
    ) {
        self._value = value
        self.rangeX = rangeX
        self.rangeY = rangeY
        self.label = label
    }

    /// Creates a `TrackPad` with a single range applied to both axes.
    ///
    /// - Parameters:
    ///   - value: A binding to the `CGPoint` the trackpad controls.
    ///   - range: The closed range used for both the x-axis and y-axis. Defaults to `0...1`.
    ///   - label: A view builder closure that creates the label view.
    public init(
        _ value: Binding<CGPoint>,
        range: ClosedRange<CGFloat> = 0...1,
        @ViewBuilder label: @escaping (_ x: Double, _ y: Double) -> LabelView = {
            Text("\(Text($0, format: .number.precision(.fractionLength(2)))), \(Text($1, format: .number.precision(.fractionLength(2))))")
        }
    ) {
        self._value = value
        self.rangeX = range
        self.rangeY = range
        self.label = label
    }

    /// Creates a `TrackPad` backed by separate `Double` bindings for each axis, with
    /// independent ranges.
    ///
    /// - Parameters:
    ///   - x: A binding to the horizontal value.
    ///   - y: A binding to the vertical value.
    ///   - rangeX: The closed range of valid values along the x-axis. Defaults to `0...1`.
    ///   - rangeY: The closed range of valid values along the y-axis. Defaults to `0...1`.
    ///   - label: A view builder closure that creates the label view.
    public init(
        x: Binding<Double>,
        y: Binding<Double>,
        rangeX: ClosedRange<CGFloat> = 0...1,
        rangeY: ClosedRange<CGFloat> = 0...1,
        @ViewBuilder label: @escaping (_ x: Double, _ y: Double) -> LabelView = {
            Text("\(Text($0, format: .number.precision(.fractionLength(2)))), \(Text($1, format: .number.precision(.fractionLength(2))))")
        }
    ) {
        self._value = Binding(
            get: { CGPoint(x: x.wrappedValue, y: y.wrappedValue) },
            set: {
                x.wrappedValue = Double($0.x)
                y.wrappedValue = Double($0.y)
            }
        )
        self.rangeX = rangeX
        self.rangeY = rangeY
        self.label = label
    }

    /// Creates a `TrackPad` backed by separate `Double` bindings for each axis, with the
    /// same range applied to both axes.
    ///
    /// - Parameters:
    ///   - x: A binding to the horizontal value.
    ///   - y: A binding to the vertical value.
    ///   - range: The closed range used for both axes. Defaults to `0...1`.
    ///   - label: A view builder closure that creates the label view.
    public init(
        x: Binding<Double>,
        y: Binding<Double>,
        range: ClosedRange<CGFloat> = 0...1,
        @ViewBuilder label: @escaping (_ x: Double, _ y: Double) -> LabelView = {
            Text("\(Text($0, format: .number.precision(.fractionLength(2)))), \(Text($1, format: .number.precision(.fractionLength(2))))")
        }
    ) {
        self._value = Binding(
            get: { CGPoint(x: x.wrappedValue, y: y.wrappedValue) },
            set: {
                x.wrappedValue = Double($0.x)
                y.wrappedValue = Double($0.y)
            }
        )
        self.rangeX = range
        self.rangeY = range
        self.label = label
    }
}
