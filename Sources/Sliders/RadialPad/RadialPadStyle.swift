// Swift toolchain version 6.0
// Running macOS version 26.3
// Created on 3/13/26.
//
// Author: Kieran Brown
//

import SwiftUI

// MARK: - Configuration

/// A value type describing the current state of a ``RadialPad``.
///
/// Styles receive an instance of `RadialPadConfiguration` when building the track, thumb,
/// optional previous-value indicator, and optional polar tick marks.
public struct RadialPadConfiguration: Sendable {
    // MARK: Core state
    /// Whether the radial pad is disabled.
    public let isDisabled: Bool
    /// Whether the user is actively dragging the thumb.
    public let isActive: Bool
    /// `true` when `radialOffset == 1` (thumb is at the track boundary).
    public let isAtLimit: Bool

    // MARK: Current position
    /// The angle of the line from the pad's centre to the thumb, measured from the trailing direction.
    public let angle: Angle
    /// The thumb's normalised distance from the track centre in `[0, 1]`.
    public let radialOffset: Double

    // MARK: Previous value
    /// Whether the previous-value indicator should be rendered.
    public let showPreviousValue: Bool
    /// The angle of the last committed position, or `nil` if not yet available.
    public let previousAngle: Angle?
    /// The normalised radial offset of the last committed position, or `nil` if not yet available.
    public let previousRadialOffset: Double?
    /// `true` while the thumb is magnetically snapped onto the previous-value position.
    public let isSnappedToPrevious: Bool

    // MARK: Tick marks
    /// Number of equal radial intervals (concentric rings).  `0` disables r-tick marks.
    public let tickCountR: Int
    /// Number of equal angular sectors (spoke lines).  `0` disables θ-tick marks.
    public let tickCountTheta: Int
    /// `true` while the thumb is snapped to a polar tick intersection.
    public let isSnappedToTick: Bool
    /// The normalised r-fraction `[0, 1]` of the current tick snap position, or `nil`.
    public let snappedTickR: Double?
    /// The angle of the current θ-tick snap position, or `nil`.
    public let snappedTickTheta: Angle?

    public init(
        isDisabled: Bool,
        isActive: Bool,
        isAtLimit: Bool,
        angle: Angle,
        radialOffset: Double,
        showPreviousValue: Bool = false,
        previousAngle: Angle? = nil,
        previousRadialOffset: Double? = nil,
        isSnappedToPrevious: Bool = false,
        tickCountR: Int = 0,
        tickCountTheta: Int = 0,
        isSnappedToTick: Bool = false,
        snappedTickR: Double? = nil,
        snappedTickTheta: Angle? = nil
    ) {
        self.isDisabled = isDisabled
        self.isActive = isActive
        self.isAtLimit = isAtLimit
        self.angle = angle
        self.radialOffset = radialOffset
        self.showPreviousValue = showPreviousValue
        self.previousAngle = previousAngle
        self.previousRadialOffset = previousRadialOffset
        self.isSnappedToPrevious = isSnappedToPrevious
        self.tickCountR = tickCountR
        self.tickCountTheta = tickCountTheta
        self.isSnappedToTick = isSnappedToTick
        self.snappedTickR = snappedTickR
        self.snappedTickTheta = snappedTickTheta
    }
}

// MARK: - Style Protocol

/// A style that defines the appearance of a ``RadialPad``.
///
/// Conform to `RadialPadStyle` to provide a custom thumb, track, optional previous-value
/// indicator, and optional polar tick marks.
///
/// Apply a style using ``SwiftUI/View/radialPadStyle(_:)``.
public protocol RadialPadStyle: Sendable {
    associatedtype Track: View
    associatedtype Thumb: View
    associatedtype PreviousValueIndicator: View
    associatedtype TickMarks: View
    associatedtype LabelContainer: View

    func makeTrack(configuration: RadialPadConfiguration) -> Self.Track
    func makeThumb(configuration: RadialPadConfiguration) -> Self.Thumb
    /// Creates the view shown at the previous-value polar position.
    ///
    /// ``RadialPad`` places this view at the correct polar offset automatically.
    /// A default implementation is provided.
    func makePreviousValueIndicator(configuration: RadialPadConfiguration) -> Self.PreviousValueIndicator
    /// Creates the view rendered inside the track to show polar tick marks.
    ///
    /// The view is sized to fill the full circular track area.
    /// A default implementation is provided.
    func makeTickMarks(configuration: RadialPadConfiguration) -> Self.TickMarks

    /// Creates the styled container for a thumb label.
    func makeLabel(configuration: RadialPadConfiguration, content: AnyView) -> Self.LabelContainer
}

// MARK: - Default implementations

public extension RadialPadStyle {
    // Type-erasure helpers
    func makeTrackTypeErased(configuration: RadialPadConfiguration) -> AnyView {
        AnyView(self.makeTrack(configuration: configuration))
    }
    func makeThumbTypeErased(configuration: RadialPadConfiguration) -> AnyView {
        AnyView(self.makeThumb(configuration: configuration))
    }
    func makePreviousValueIndicatorTypeErased(configuration: RadialPadConfiguration) -> AnyView {
        AnyView(self.makePreviousValueIndicator(configuration: configuration))
    }
    func makeTickMarksTypeErased(configuration: RadialPadConfiguration) -> AnyView {
        AnyView(self.makeTickMarks(configuration: configuration))
    }
    func makeLabelTypeErased(configuration: RadialPadConfiguration, content: AnyView) -> AnyView {
        AnyView(self.makeLabel(configuration: configuration, content: content))
    }

    /// Default previous-value indicator: a dim radial ring + crosshair that brightens
    /// and scales up when `isSnappedToPrevious` is `true` — matching the TrackPad style.
    func makePreviousValueIndicator(configuration: RadialPadConfiguration) -> some View {
        let snapped = configuration.isSnappedToPrevious
        let ringSize: Double = snapped ? 22 : 16
        let ringOpacity: Double = snapped ? 0.90 : 0.45
        let crossSize: Double = snapped ? 8 : 5
        let accent = Color(.sRGB, red: 0.204, green: 0.648, blue: 0.855)
        return ZStack {
            Circle()
                .strokeBorder(accent.opacity(ringOpacity), lineWidth: snapped ? 2.5 : 1.5)
                .frame(width: ringSize, height: ringSize)
            // Crosshair
            Rectangle()
                .fill(accent.opacity(ringOpacity))
                .frame(width: crossSize, height: 1)
            Rectangle()
                .fill(accent.opacity(ringOpacity))
                .frame(width: 1, height: crossSize)
        }
        .animation(.easeOut(duration: 0.15), value: snapped)
    }

    /// Default polar tick-mark view.
    ///
    /// Draws concentric partial-circle rings for r-ticks and radial spoke lines for θ-ticks.
    /// Intersections are shown as small dots, with the currently-snapped intersection
    /// highlighted in blue.
    func makeTickMarks(configuration: RadialPadConfiguration) -> some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let radius = size / 2
            let cx = geo.size.width / 2
            let cy = geo.size.height / 2
            let nr = configuration.tickCountR
            let nt = configuration.tickCountTheta
            let accent = Color(.sRGB, red: 0.204, green: 0.648, blue: 0.855)

            ZStack {
                // ── Concentric rings (r-ticks) ────────────────────────────────
                if nr > 0 {
                    ForEach(1...nr, id: \.self) { ir in
                        let fr = CGFloat(ir) / CGFloat(nr)
                        Circle()
                            .strokeBorder(Color.primary.opacity(0.10), lineWidth: 1)
                            .frame(width: fr * size, height: fr * size)
                            .position(x: cx, y: cy)
                    }
                }

                // ── Radial spokes (θ-ticks) ───────────────────────────────────
                if nt > 0 {
                    ForEach(0..<nt, id: \.self) { it in
                        let theta = 2.0 * Double.pi * Double(it) / Double(nt)
                        let ex = cx + radius * CGFloat(cos(theta))
                        let ey = cy + radius * CGFloat(sin(theta))
                        Path { p in
                            p.move(to: CGPoint(x: cx, y: cy))
                            p.addLine(to: CGPoint(x: ex, y: ey))
                        }
                        .stroke(Color.primary.opacity(0.10), lineWidth: 1)
                    }
                }

                // ── Intersection dots ─────────────────────────────────────────
                if nr > 0 && nt > 0 {
                    ForEach(1...nr, id: \.self) { ir in
                        let fr = Double(ir) / Double(nr)
                        ForEach(0..<nt, id: \.self) { it in
                            let theta = 2.0 * Double.pi * Double(it) / Double(nt)
                            let px = cx + CGFloat(fr) * radius * CGFloat(cos(theta))
                            let py = cy + CGFloat(fr) * radius * CGFloat(sin(theta))
                            let isSnapped = configuration.isSnappedToTick
                                && abs((configuration.snappedTickR ?? -1) - fr) < 0.001
                                && abs(angularDifference(
                                    configuration.snappedTickTheta?.radians ?? -999,
                                    theta) ) < 0.001
                            Circle()
                                .fill(isSnapped ? accent.opacity(0.85) : Color.primary.opacity(0.22))
                                .frame(width: isSnapped ? 8 : 4, height: isSnapped ? 8 : 4)
                                .position(x: px, y: py)
                                .animation(.easeOut(duration: 0.12), value: isSnapped)
                        }
                    }
                }
            }
        }
    }

    /// Default label: the current value in a floating capsule that appears when active.
    func makeLabel(configuration: RadialPadConfiguration, content: AnyView) -> some View {
        content
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .shadow(color: Color.black.opacity(0.15), radius: 2, y: 1)
            )
            .scaleEffect(configuration.isActive ? 1.0 : 0.8)
            .opacity(configuration.isActive ? 1.0 : 0.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isActive)
    }
}

// MARK: - Angular helpers (file-private)

/// Returns the unsigned shortest angular distance between two radian values.
private func angularDifference(_ a: Double, _ b: Double) -> Double {
    let diff = (a - b).truncatingRemainder(dividingBy: 2 * .pi)
    let wrapped = diff < 0 ? diff + 2 * .pi : diff
    return Swift.min(wrapped, 2 * .pi - wrapped)
}

// MARK: - AnyRadialPadStyle

/// A type-erased ``RadialPadStyle``.
public struct AnyRadialPadStyle: RadialPadStyle, Sendable {
    private let _makeTrack: @Sendable (RadialPadConfiguration) -> AnyView
    private let _makeThumb: @Sendable (RadialPadConfiguration) -> AnyView
    private let _makePreviousValueIndicator: @Sendable (RadialPadConfiguration) -> AnyView
    private let _makeTickMarks: @Sendable (RadialPadConfiguration) -> AnyView
    private let _makeLabel: @Sendable (RadialPadConfiguration, AnyView) -> AnyView

    public func makeTrack(configuration: RadialPadConfiguration) -> some View {
        _makeTrack(configuration)
    }
    public func makeThumb(configuration: RadialPadConfiguration) -> some View {
        _makeThumb(configuration)
    }
    public func makePreviousValueIndicator(configuration: RadialPadConfiguration) -> some View {
        _makePreviousValueIndicator(configuration)
    }
    public func makeTickMarks(configuration: RadialPadConfiguration) -> some View {
        _makeTickMarks(configuration)
    }
    public func makeLabel(configuration: RadialPadConfiguration, content: AnyView) -> some View {
        _makeLabel(configuration, content)
    }

    public init<S: RadialPadStyle>(_ style: S) {
        self._makeTrack = style.makeTrackTypeErased
        self._makeThumb = style.makeThumbTypeErased
        self._makePreviousValueIndicator = style.makePreviousValueIndicatorTypeErased
        self._makeTickMarks = style.makeTickMarksTypeErased
        self._makeLabel = style.makeLabelTypeErased
    }
}

// MARK: - Environment

public struct RadialPadStyleKey: EnvironmentKey {
    public static let defaultValue: AnyRadialPadStyle = AnyRadialPadStyle(DefaultRadialPadStyle())
}

extension EnvironmentValues {
    public var radialPadStyle: AnyRadialPadStyle {
        get { self[RadialPadStyleKey.self] }
        set { self[RadialPadStyleKey.self] = newValue }
    }
}

extension View {
    public func radialPadStyle<S: RadialPadStyle>(_ style: S) -> some View {
        environment(\.radialPadStyle, AnyRadialPadStyle(style))
    }
}

// MARK: - Static preset shortcut

public extension RadialPadStyle where Self == DefaultRadialPadStyle {
    /// The built-in default radial-pad style.
    static var `default`: DefaultRadialPadStyle { DefaultRadialPadStyle() }

    /// The built-in default radial-pad style with customisable colours.
    ///
    /// Usage:
    /// ```swift
    /// RadialPad(offset: $r, angle: $theta)
    ///     .radialPadStyle(.default(thumbSize: 40))
    /// ```
    static func `default`(
        trackColor: Color = Color(.sRGB, red: 0.55, green: 0.55, blue: 0.59).opacity(0.25),
        trackStrokeColor: Color = Color(.sRGB, red: 0.55, green: 0.55, blue: 0.59),
        thumbInactiveColor: Color = Color(.sRGB, red: 0.204, green: 0.648, blue: 0.855),
        thumbActiveColor: Color = Color.white,
        thumbDisabledColor: Color = Color(.sRGB, red: 0.75, green: 0.75, blue: 0.75),
        trackDisabledColor: Color = Color(.sRGB, red: 0.75, green: 0.75, blue: 0.75),
        thumbSize: Double = 36
    ) -> DefaultRadialPadStyle {
        DefaultRadialPadStyle(
            trackColor: trackColor,
            trackStrokeColor: trackStrokeColor,
            thumbInactiveColor: thumbInactiveColor,
            thumbActiveColor: thumbActiveColor,
            thumbDisabledColor: thumbDisabledColor,
            trackDisabledColor: trackDisabledColor,
            thumbSize: thumbSize
        )
    }
}

// MARK: - Default Style

/// The built-in default style for ``RadialPad``.
///
/// Uses the same colour palette as ``DefaultTrackPadStyle``:
/// - Track: circular fill with a subtle grey stroke border.
/// - Thumb: a circle that switches from accent blue at rest to white when active, with a
///   drop shadow while dragging.
/// - Previous-value indicator: inherited from the protocol default — a blue ring + crosshair.
/// - Tick marks: inherited from the protocol default — concentric rings + radial spokes.
public struct DefaultRadialPadStyle: RadialPadStyle, Sendable {

    let trackColor: Color
    let trackStrokeColor: Color
    let thumbInactiveColor: Color
    let thumbActiveColor: Color
    let thumbDisabledColor: Color
    let trackDisabledColor: Color
    let thumbSize: Double

    public init(
        trackColor: Color = Color(.sRGB, red: 0.55, green: 0.55, blue: 0.59).opacity(0.25),
        trackStrokeColor: Color = Color(.sRGB, red: 0.55, green: 0.55, blue: 0.59),
        thumbInactiveColor: Color = Color(.sRGB, red: 0.204, green: 0.648, blue: 0.855),
        thumbActiveColor: Color = Color.white,
        thumbDisabledColor: Color = Color(.sRGB, red: 0.75, green: 0.75, blue: 0.75),
        trackDisabledColor: Color = Color(.sRGB, red: 0.75, green: 0.75, blue: 0.75),
        thumbSize: Double = 36
    ) {
        self.trackColor = trackColor
        self.trackStrokeColor = trackStrokeColor
        self.thumbInactiveColor = thumbInactiveColor
        self.thumbActiveColor = thumbActiveColor
        self.thumbDisabledColor = thumbDisabledColor
        self.trackDisabledColor = trackDisabledColor
        self.thumbSize = thumbSize
    }

    public func makeTrack(configuration: RadialPadConfiguration) -> some View {
        let strokeColor = configuration.isDisabled ? trackDisabledColor : trackStrokeColor
        return Circle()
            .fill(trackColor)
            .overlay(
                Circle()
                    .strokeBorder(strokeColor.opacity(0.6), lineWidth: 1)
            )
            .opacity(configuration.isDisabled ? 0.5 : 1.0)
    }

    public func makeThumb(configuration: RadialPadConfiguration) -> some View {
        let color: Color = configuration.isDisabled
            ? thumbInactiveColor.mix(with: thumbDisabledColor, by: 0.5)
            : (configuration.isActive ? thumbActiveColor : thumbInactiveColor)
        return Circle()
            .fill(color)
            .frame(width: thumbSize, height: thumbSize)
            .shadow(radius: configuration.isDisabled ? 0 : (configuration.isActive ? 3 : 0))
            .opacity(configuration.isDisabled ? 0.6 : 1.0)
    }

    // makePreviousValueIndicator and makeTickMarks use the protocol default implementations
}
