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
///
/// ## Styling
///
/// Conform to `TrackPadStyle` and implement:
///  - `makeThumb` – the draggable thumb view.
///  - `makeTrack` – the rectangular track background.
///  - `makePreviousValueIndicator` – (optional, default provided) the marker shown at the
///    previous position.
///
/// Apply your style with `.trackPadStyle(MyStyle())`.
///
public struct TrackPad: View {
    // MARK: State and Setup
    @Environment(\.trackPadStyle) private var style: AnyTrackPadStyle
    @Environment(\.isEnabled) private var isEnabled
    private let space: String = "Track Pad"
    @State private var isActive: Bool = false
    @State private var atXLimit: Bool = false
    @State private var atYLimit: Bool = false
    /// The committed position from the last completed drag (set on `onEnded`).
    @State private var previousValue: CGPoint? = nil
    /// Whether the thumb is currently magnetically snapped to the previous-value position.
    @State private var isSnappedToPrevious: Bool = false

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

    // MARK: - Initialisers

    public init(value: Binding<CGPoint>, rangeX: ClosedRange<CGFloat>, rangeY: ClosedRange<CGFloat>) {
        self._value = value
        self.rangeX = rangeX
        self.rangeY = rangeY
    }

    public init(_ value: Binding<CGPoint>) {
        self._value = value
    }

    /// Use this initializer when the x and y ranges are the same.
    public init(_ value: Binding<CGPoint>, range: ClosedRange<CGFloat>) {
        self._value = value
        self.rangeX = range
        self.rangeY = range
    }

    public init(x: Binding<Double>, y: Binding<Double>, rangeX: ClosedRange<CGFloat>, rangeY: ClosedRange<CGFloat>) {
        self._value = Binding(
            get: { CGPoint(x: x.wrappedValue, y: y.wrappedValue) },
            set: {
                x.wrappedValue = Double($0.x)
                y.wrappedValue = Double($0.y)
            }
        )
        self.rangeX = rangeX
        self.rangeY = rangeY
    }

    public init(x: Binding<Double>, y: Binding<Double>) {
        self._value = Binding(
            get: { CGPoint(x: x.wrappedValue, y: y.wrappedValue) },
            set: {
                x.wrappedValue = Double($0.x)
                y.wrappedValue = Double($0.y)
            }
        )
    }

    /// Use this initializer when the x and y ranges are the same.
    public init(x: Binding<Double>, y: Binding<Double>, range: ClosedRange<CGFloat>) {
        self._value = Binding(
            get: { CGPoint(x: x.wrappedValue, y: y.wrappedValue) },
            set: {
                x.wrappedValue = Double($0.x)
                y.wrappedValue = Double($0.y)
            }
        )
        self.rangeX = range
        self.rangeY = range
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
            isSnappedToPrevious: isSnappedToPrevious
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

    public var body: some View {
        ZStack {
            style.makeTrack(configuration: makeConfiguration())
            GeometryReader { proxy in
                ZStack(alignment: .center) {
                    // Previous-value indicator (rendered below the thumb)
                    if showPreviousValue, previousValue != nil {
                        style.makePreviousValueIndicator(configuration: makeConfiguration())
                            .offset(previousValueOffset(proxy))
                    }

                    // Thumb
                    style.makeThumb(configuration: makeConfiguration())
                        .offset(thumbOffset(proxy))
                        .gesture(
                            DragGesture(minimumDistance: 0, coordinateSpace: .named(space))
                                .onChanged { drag in
                                    constrainValue(proxy, drag.location)
                                    applyPreviousValueAffinity(proxy, velocity: drag.velocity)
                                    isActive = true
                                }
                                .onEnded { drag in
                                    constrainValue(proxy, drag.location)
                                    // Apply affinity one final time before committing
                                    applyPreviousValueAffinity(proxy, velocity: drag.velocity)
                                    isActive = false
                                    isSnappedToPrevious = false
                                    // Record the committed position as the new previous value
                                    if showPreviousValue {
                                        previousValue = value
                                    }
                                }
                        )
                        .allowsHitTesting(isEnabled)
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
            }
        }
        .coordinateSpace(name: space)
    }
}
