// Swift toolchain version 6.0
// Running macOS version 26.3
// Created on 4/7/20.
//
// Author: Kieran Brown
//

import SwiftUI

/// # Radial Track Pad
///
/// A control that constrains the drag gesture of the thumb to be contained within the radius
/// of a circular track.  Similar to a joystick, except the thumb stays where the drag ended.
///
/// - parameters:
///     - offset: `Binding<Double>` The normalised distance (`0…1`) from the track centre to
///       the thumb.
///     - angle: `Binding<Angle>` The angle of the line from the pad's centre to the thumb,
///       measured clockwise from the trailing direction.
///     - showPreviousValue: When `true`, a visual indicator marks the last committed position
///       (set when the user lifts their finger).  The indicator has a magnetic affinity — when
///       the thumb is dragged slowly near it, it snaps back.
///     - previousValueAffinityRadius: Fraction of the track radius within which the previous-
///       value snap activates (default `0.06`).
///     - previousValueAffinityResistance: Extra fraction beyond `previousValueAffinityRadius`
///       the drag must travel to release the snap (default `0.03`).
///     - previousValueVelocityThreshold: Maximum drag speed (pts/s) at which the snap can
///       engage.  Faster drags pass through freely (default `180`).
///     - tickCountR: Number of equal radial intervals — concentric rings (default `0` = off).
///     - tickCountTheta: Number of equal angular sectors — spoke lines (default `0` = off).
///     - tickAffinityRadius: Fraction of the track radius within which the thumb snaps to the
///       nearest polar tick intersection (default `0.05`).
///     - tickAffinityResistance: Extra fraction beyond `tickAffinityRadius` the drag must
///       travel to escape a tick snap (default `0.02`).
///     - tickAffinityVelocityThreshold: Maximum drag speed (pts/s) at which tick snapping can
///       engage (default `150`).
///
/// ## Polar Tick Marks
///
/// Set `tickCountR` and/or `tickCountTheta` to positive integers to add rings and spokes.
/// When both are > 0, their intersections become snap targets.  Use the fluent modifiers
/// `.tickCountR(_:)`, `.tickCountTheta(_:)`, `.tickAffinityRadius(_:)`, etc. to configure.
///
/// ## Styling
///
/// Conform to `RadialPadStyle` and implement:
///  - `makeThumb` — the draggable thumb view.
///  - `makeTrack` — the circular track background.
///  - `makePreviousValueIndicator` — *(optional, default provided)* the marker shown at the
///    previous position.
///  - `makeTickMarks` — *(optional, default provided)* polar grid rendered inside the track.
///
/// Apply your style with `.radialPadStyle(MyStyle())`.
///
public struct RadialPad: View {
    // MARK: - Environment / internal state

    @Environment(\.radialPadStyle) private var style: AnyRadialPadStyle
    @Environment(\.isEnabled)      private var isEnabled
    private let space: String = "Radial Pad"

    @State private var isActive: Bool = false
    @State private var isAtLimit: Bool = false

    /// The committed position from the last completed drag (set on `onEnded`).
    @State private var previousValue: (radialOffset: Double, angle: Angle)? = nil
    /// Whether the thumb is currently magnetically snapped to the previous-value position.
    @State private var isSnappedToPrevious: Bool = false
    /// Whether the thumb is currently snapped to a polar tick intersection.
    @State private var isSnappedToTick: Bool = false
    /// The polar tick intersection the thumb is currently snapped to.
    @State private var snappedTick: (r: Double, theta: Angle)? = nil

    // MARK: - Inputs

    @Binding public var offset: Double
    @Binding public var angle: Angle

    // MARK: Previous-value feature

    /// When `true`, a visual indicator marks the last committed position and affinity snap
    /// is enabled near it.
    public var showPreviousValue: Bool = false
    /// Fraction of the track radius within which the previous-value snap activates.
    public var previousValueAffinityRadius: Double = 0.06
    /// Extra fraction beyond `previousValueAffinityRadius` before the snap releases.
    public var previousValueAffinityResistance: Double = 0.03
    /// Maximum drag velocity (pts/s) at which the snap can engage.
    public var previousValueVelocityThreshold: Double = 180.0

    // MARK: Tick mark inputs

    /// Number of equal radial intervals (concentric rings).  `0` disables r-ticks.
    public var tickCountR: Int = 0
    /// Number of equal angular sectors (spoke lines).  `0` disables θ-ticks.
    public var tickCountTheta: Int = 0
    /// Fraction of the track radius within which the thumb snaps to the nearest polar tick.
    public var tickAffinityRadius: Double = 0.05
    /// Extra fraction the drag must travel beyond `tickAffinityRadius` to escape a tick snap.
    public var tickAffinityResistance: Double = 0.02
    /// Maximum drag speed (pts/s) at which tick-mark snapping can engage.
    public var tickAffinityVelocityThreshold: Double = 150.0

    // MARK: - Initialisers

    public init(offset: Binding<Double>, angle: Binding<Angle>) {
        self._offset = offset
        self._angle  = angle
    }

    // MARK: - Fluent configuration modifiers

    /// Shows or hides the previous-value indicator.
    public func showPreviousValue(_ show: Bool) -> RadialPad {
        var copy = self; copy.showPreviousValue = show; return copy
    }
    /// Sets the affinity pull radius for the previous-value indicator.
    public func previousValueAffinityRadius(_ radius: Double) -> RadialPad {
        var copy = self; copy.previousValueAffinityRadius = radius; return copy
    }
    /// Sets the affinity resistance for the previous-value indicator.
    public func previousValueAffinityResistance(_ resistance: Double) -> RadialPad {
        var copy = self; copy.previousValueAffinityResistance = resistance; return copy
    }
    /// Sets the maximum drag velocity at which the previous-value snap can engage.
    public func previousValueVelocityThreshold(_ threshold: Double) -> RadialPad {
        var copy = self; copy.previousValueVelocityThreshold = threshold; return copy
    }

    /// Sets the number of equal radial intervals (concentric rings).
    public func tickCountR(_ count: Int) -> RadialPad {
        var copy = self; copy.tickCountR = max(0, count); return copy
    }
    /// Sets the number of equal angular sectors (spoke lines).
    public func tickCountTheta(_ count: Int) -> RadialPad {
        var copy = self; copy.tickCountTheta = max(0, count); return copy
    }
    /// Convenience: sets both `tickCountR` and `tickCountTheta` to the same value.
    public func tickCount(r: Int, theta: Int) -> RadialPad {
        var copy = self
        copy.tickCountR     = max(0, r)
        copy.tickCountTheta = max(0, theta)
        return copy
    }
    /// Sets the affinity pull radius for tick snapping.
    public func tickAffinityRadius(_ radius: Double) -> RadialPad {
        var copy = self; copy.tickAffinityRadius = radius; return copy
    }
    /// Sets the resistance beyond the pull radius before a tick snap releases.
    public func tickAffinityResistance(_ resistance: Double) -> RadialPad {
        var copy = self; copy.tickAffinityResistance = resistance; return copy
    }
    /// Sets the maximum drag speed at which tick-mark snapping can engage.
    public func tickAffinityVelocityThreshold(_ threshold: Double) -> RadialPad {
        var copy = self; copy.tickAffinityVelocityThreshold = threshold; return copy
    }

    // MARK: - Configuration builder

    private func makeConfiguration() -> RadialPadConfiguration {
        RadialPadConfiguration(
            isDisabled: !isEnabled,
            isActive: isActive,
            isAtLimit: offset >= 1.0,
            angle: angle,
            radialOffset: offset,
            showPreviousValue: showPreviousValue,
            previousAngle: previousValue?.angle,
            previousRadialOffset: previousValue?.radialOffset,
            isSnappedToPrevious: isSnappedToPrevious,
            tickCountR: tickCountR,
            tickCountTheta: tickCountTheta,
            isSnappedToTick: isSnappedToTick,
            snappedTickR: snappedTick?.r,
            snappedTickTheta: snappedTick?.theta
        )
    }

    // MARK: - Position helpers

    /// Converts a drag location into polar `(offset, angle)`, clamped to `[0, 1]` radially.
    private func updatePosition(_ proxy: GeometryProxy, location: CGPoint) {
        let middle = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2)
        let radius = Double(min(proxy.size.width, proxy.size.height)) / 2
        let dist   = sqrt(Double((middle - location).magnitudeSquared))
        let newOffset = min(1.0, dist / radius)

        let wasAtLimit = isAtLimit
        isAtLimit = newOffset >= 1.0
        if isAtLimit && !wasAtLimit { impactOccurred() }

        offset = newOffset
        angle  = Angle(degrees: calculateDirection(middle, location) * 360)
    }

    /// Returns the screen-space offset for a given polar `(r, theta)` position.
    private func thumbOffset(_ proxy: GeometryProxy, r: Double, theta: Angle) -> CGSize {
        let radius = Double(min(proxy.size.width, proxy.size.height)) / 2
        let px = radius * r * cos(theta.radians)
        let py = radius * r * sin(theta.radians)
        return CGSize(width: px, height: py)
    }

    // MARK: - Previous-value affinity

    /// Applies previous-value affinity, potentially snapping `(offset, angle)` to the last
    /// committed position when the thumb is close and moving slowly.
    private func applyPreviousValueAffinity(_ proxy: GeometryProxy, velocity: CGSize) {
        guard showPreviousValue, let prev = previousValue else { return }

        let radius = Double(min(proxy.size.width, proxy.size.height)) / 2
        guard radius > 0 else { return }

        // Shortest arc distance in screen space between current and previous polar positions.
        // Arc length ≈ r·|Δθ| for the angular component; radial gap is r_track·|Δr|.
        let dR     = (offset - prev.radialOffset) * radius
        let dTheta = shortestArc(angle.radians, prev.angle.radians) * (offset * radius)
        let screenDist = (dR * dR + dTheta * dTheta).squareRoot()
        let normDist   = screenDist / radius

        let speed = (Double(velocity.width) * Double(velocity.width)
                   + Double(velocity.height) * Double(velocity.height)).squareRoot()

        let pullRadius   = previousValueAffinityRadius
        let resistRadius = previousValueAffinityRadius + previousValueAffinityResistance

        if isSnappedToPrevious {
            if normDist > resistRadius {
                isSnappedToPrevious = false
            } else {
                offset = prev.radialOffset
                angle  = prev.angle
            }
        } else {
            if normDist <= pullRadius && speed <= previousValueVelocityThreshold {
                isSnappedToPrevious = true
                offset = prev.radialOffset
                angle  = prev.angle
                playSnapHaptic()
            }
        }
    }

    // MARK: - Polar tick-mark affinity

    /// Applies tick-mark affinity, potentially snapping `(offset, angle)` to the nearest
    /// polar tick intersection (r-ring × θ-spoke).
    private func applyTickAffinity(_ proxy: GeometryProxy, velocity: CGSize) {
        let nr = tickCountR
        let nt = tickCountTheta
        guard nr > 0 || nt > 0 else { return }

        let radius = Double(min(proxy.size.width, proxy.size.height)) / 2
        guard radius > 0 else { return }

        let speed = (Double(velocity.width) * Double(velocity.width)
                   + Double(velocity.height) * Double(velocity.height)).squareRoot()
        let pullRadius   = tickAffinityRadius
        let resistRadius = tickAffinityRadius + tickAffinityResistance

        if isSnappedToTick, let snap = snappedTick {
            // Hold: stay snapped until drag escapes resistance zone
            let dR     = (offset - snap.r) * radius
            let dTheta = shortestArc(angle.radians, snap.theta.radians) * (offset * radius)
            let dist   = (dR * dR + dTheta * dTheta).squareRoot() / radius
            if dist > resistRadius {
                isSnappedToTick = false
                snappedTick = nil
            } else {
                offset = snap.r
                angle  = snap.theta
            }
        } else {
            // Pull: find nearest (r, θ) tick and snap if close enough + slow enough
            let nearR: Double = nr > 0
                ? (Double(Int((offset * Double(nr)).rounded())) / Double(nr)).clamped(to: 0...1)
                : offset
            let nearTheta: Double = nt > 0
                ? nearestSpokeAngle(angle.radians, spokeCount: nt)
                : angle.radians

            let dR     = (offset - nearR) * radius
            let dTheta = shortestArc(angle.radians, nearTheta) * (offset * radius)
            let dist   = (dR * dR + dTheta * dTheta).squareRoot() / radius

            if dist <= pullRadius && speed <= tickAffinityVelocityThreshold {
                isSnappedToTick = true
                snappedTick = (r: nearR, theta: Angle(radians: nearTheta))
                offset = nearR
                angle  = Angle(radians: nearTheta)
                playSnapHaptic()
            }
        }
    }

    // MARK: - Polar maths helpers

    /// Shortest signed angular distance from `a` to `b` (both in radians), result in `[−π, π]`.
    private func shortestArc(_ a: Double, _ b: Double) -> Double {
        let diff = (b - a).truncatingRemainder(dividingBy: 2 * .pi)
        if diff > .pi  { return diff - 2 * .pi }
        if diff < -.pi { return diff + 2 * .pi }
        return diff
    }

    /// Returns the angle (radians) of the nearest spoke out of `spokeCount` evenly-spaced spokes.
    private func nearestSpokeAngle(_ theta: Double, spokeCount: Int) -> Double {
        let step = 2.0 * Double.pi / Double(spokeCount)
        let index = (theta / step).rounded()
        return index * step
    }

    // MARK: - Haptics

    private func impactOccurred() {
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

                    // ── Polar tick marks ──────────────────────────────────────
                    if tickCountR > 0 || tickCountTheta > 0 {
                        style.makeTickMarks(configuration: makeConfiguration())
                            .frame(width: proxy.size.width, height: proxy.size.height)
                            .clipShape(Circle())
                    }

                    // ── Previous-value indicator ──────────────────────────────
                    if showPreviousValue, let prev = previousValue {
                        style.makePreviousValueIndicator(configuration: makeConfiguration())
                            .offset(thumbOffset(proxy, r: prev.radialOffset, theta: prev.angle))
                    }

                    // ── Thumb ─────────────────────────────────────────────────
                    style.makeThumb(configuration: makeConfiguration())
                        .offset(thumbOffset(proxy, r: offset, theta: angle))
                        .gesture(
                            DragGesture(minimumDistance: 0, coordinateSpace: .named(space))
                                .onChanged { drag in
                                    updatePosition(proxy, location: drag.location)
                                    applyTickAffinity(proxy, velocity: drag.velocity)
                                    applyPreviousValueAffinity(proxy, velocity: drag.velocity)
                                    isActive = true
                                }
                                .onEnded { drag in
                                    updatePosition(proxy, location: drag.location)
                                    applyTickAffinity(proxy, velocity: drag.velocity)
                                    applyPreviousValueAffinity(proxy, velocity: drag.velocity)
                                    isActive = false
                                    isSnappedToPrevious = false
                                    isSnappedToTick = false
                                    snappedTick = nil
                                    if showPreviousValue {
                                        previousValue = (radialOffset: offset, angle: angle)
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
