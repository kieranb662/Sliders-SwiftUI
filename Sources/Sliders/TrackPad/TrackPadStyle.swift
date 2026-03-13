// Swift toolchain version 6.0
// Running macOS version 26.3
// Created on 3/13/26.
//
// Author: Kieran Brown
//

import SwiftUI

// MARK: - Configuration

/// A value type describing the current state of a ``TrackPad``.
///
/// Styles receive an instance of `TrackPadConfiguration` when building the thumb, track, and
/// optional previous-value indicator. Most styles will use `isActive`, `pctX`, and `pctY`.
///
/// ## Previous Value Indicator
/// When `showPreviousValue` is `true`, the ``TrackPad`` exposes the last committed position
/// via `previousPctX`/`previousPctY` (and their domain equivalents). The style is free to
/// render any indicator it likes via ``TrackPadStyle/makePreviousValueIndicator(configuration:)``.
/// When the thumb is near the previous position and moving slowly, `isSnappedToPrevious` is
/// `true` — the default style uses this to make the indicator pulse/highlight.
public struct TrackPadConfiguration: Sendable {
    // MARK: Core state
    /// Whether the trackpad is disabled.
    public let isDisabled: Bool
    /// Whether the user is actively dragging the thumb.
    public let isActive: Bool
    
    // MARK: Current position
    /// `(valueX − minX) / (maxX − minX)` — horizontal fill fraction in `[0, 1]`.
    public let pctX: Double
    /// `(valueY − minY) / (maxY − minY)` — vertical fill fraction in `[0, 1]`.
    public let pctY: Double
    /// The current value in the x direction.
    public let valueX: Double
    /// The current value in the y direction.
    public let valueY: Double
    
    // MARK: Range bounds
    /// The minimum value from `rangeX`.
    public let minX: Double
    /// The maximum value from `rangeX`.
    public let maxX: Double
    /// The minimum value from `rangeY`.
    public let minY: Double
    /// The maximum value from `rangeY`.
    public let maxY: Double
    
    // MARK: Previous value
    /// Whether the previous-value indicator should be shown.
    ///
    /// Controlled by ``TrackPad/showPreviousValue``. When `false`, the style's
    /// `makePreviousValueIndicator` is not called.
    public let showPreviousValue: Bool
    /// The normalised x fraction of the last committed position, or `nil` if unavailable.
    public let previousPctX: Double?
    /// The normalised y fraction of the last committed position, or `nil` if unavailable.
    public let previousPctY: Double?
    /// The domain value at the last committed x position, or `nil` if unavailable.
    public let previousValueX: Double?
    /// The domain value at the last committed y position, or `nil` if unavailable.
    public let previousValueY: Double?
    /// `true` while the thumb is magnetically snapped onto the previous-value position.
    ///
    /// Use this to visually distinguish the "locked" state — for example the default style
    /// enlarges and brightens the indicator ring.
    public let isSnappedToPrevious: Bool

    // MARK: Tick marks
    /// The number of tick intervals along the x-axis.  `0` means no tick marks.
    public let tickCountX: Int
    /// The number of tick intervals along the y-axis.  `0` means no tick marks.
    public let tickCountY: Int
    /// `true` while the thumb is snapped to a tick-mark intersection.
    public let isSnappedToTick: Bool
    /// The normalised x fraction `[0,1]` of the tick-mark position the thumb is currently
    /// snapped to, or `nil` when not snapped.
    public let snappedTickPctX: Double?
    /// The normalised y fraction `[0,1]` of the tick-mark position the thumb is currently
    /// snapped to, or `nil` when not snapped.
    public let snappedTickPctY: Double?
}

// MARK: - Style Protocol

/// A style that defines the appearance of a ``TrackPad``.
///
/// Conform to `TrackPadStyle` to provide a custom thumb, track, and optional previous-value
/// indicator for the track pad.
///
/// Apply a style using ``SwiftUI/View/trackPadStyle(_:)``.
public protocol TrackPadStyle: Sendable {
    /// The view used for the draggable thumb.
    associatedtype Thumb: View
    /// The view used for the track background.
    associatedtype Track: View
    /// The view used to mark the last committed position (previous value indicator).
    associatedtype PreviousValueIndicator: View
    /// The view used to render tick-mark intersections inside the track.
    associatedtype TickMarks: View
    /// The view used as a styled label container.
    associatedtype LabelContainer: View

    /// Creates the draggable thumb.
    func makeThumb(configuration: TrackPadConfiguration) -> Self.Thumb

    /// Creates the track background.
    func makeTrack(configuration: TrackPadConfiguration) -> Self.Track

    /// Creates the view shown at the previous-value position.
    ///
    /// ``TrackPad`` places this view at the correct offset automatically; you only need to
    /// return the indicator's intrinsic appearance. A default implementation is provided.
    func makePreviousValueIndicator(configuration: TrackPadConfiguration) -> Self.PreviousValueIndicator

    /// Creates the view rendered inside the track to show tick-mark intersections.
    ///
    /// ``TrackPad`` calls this method only when `tickCountX > 0 || tickCountY > 0`.
    /// The view is sized to fill the full track area, so you can use a `GeometryReader`
    /// inside to position individual marks. A default implementation is provided.
    func makeTickMarks(configuration: TrackPadConfiguration) -> Self.TickMarks

    /// Creates the styled container for a thumb label.
    func makeLabel(configuration: TrackPadConfiguration, content: AnyView) -> Self.LabelContainer
}

// MARK: - Default implementations

public extension TrackPadStyle {
    // Type-erasure helpers
    func makeThumbTypeErased(configuration: TrackPadConfiguration) -> AnyView {
        AnyView(self.makeThumb(configuration: configuration))
    }
    func makeTrackTypeErased(configuration: TrackPadConfiguration) -> AnyView {
        AnyView(self.makeTrack(configuration: configuration))
    }
    func makePreviousValueIndicatorTypeErased(configuration: TrackPadConfiguration) -> AnyView {
        AnyView(self.makePreviousValueIndicator(configuration: configuration))
    }
    func makeTickMarksTypeErased(configuration: TrackPadConfiguration) -> AnyView {
        AnyView(self.makeTickMarks(configuration: configuration))
    }
    func makeLabelTypeErased(configuration: TrackPadConfiguration, content: AnyView) -> AnyView {
        AnyView(self.makeLabel(configuration: configuration, content: content))
    }

    /// Default previous-value indicator: a dim ring with a small crosshair that brightens
    /// and scales up when `isSnappedToPrevious` is `true`.
    func makePreviousValueIndicator(configuration: TrackPadConfiguration) -> some View {
        let snapped = configuration.isSnappedToPrevious
        let ringSize: Double = snapped ? 22 : 16
        let ringOpacity: Double = snapped ? 0.90 : 0.45
        let crossSize: Double = snapped ? 8 : 5
        
        return ZStack {
            Circle()
                .strokeBorder(
                    Color(.sRGB, red: 0.204, green: 0.648, blue: 0.855).opacity(ringOpacity),
                    lineWidth: snapped ? 2.5 : 1.5
                )
                .frame(width: ringSize, height: ringSize)
            
            // Crosshair
            Rectangle()
                .fill(Color(.sRGB, red: 0.204, green: 0.648, blue: 0.855).opacity(ringOpacity))
                .frame(width: crossSize, height: 1)
            Rectangle()
                .fill(Color(.sRGB, red: 0.204, green: 0.648, blue: 0.855).opacity(ringOpacity))
                .frame(width: 1, height: crossSize)
        }
        .animation(.easeOut(duration: 0.15), value: snapped)
    }
    
    /// Default tick-mark view: small circles at every grid intersection, with snapped
    /// intersections shown as a larger, brighter dot.
    func makeTickMarks(configuration: TrackPadConfiguration) -> some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let nx = configuration.tickCountX
            let ny = configuration.tickCountY
            // Draw x-axis lines (vertical rules)
            if nx > 0 {
                ForEach(0...nx, id: \.self) { ix in
                    let fx = CGFloat(ix) / CGFloat(nx)
                    Rectangle()
                        .fill(Color.primary.opacity(0.10))
                        .frame(width: 1)
                        .frame(height: h)
                        .position(x: fx * w, y: h / 2)
                }
            }
            // Draw y-axis lines (horizontal rules)
            if ny > 0 {
                ForEach(0...ny, id: \.self) { iy in
                    let fy = CGFloat(iy) / CGFloat(ny)
                    Rectangle()
                        .fill(Color.primary.opacity(0.10))
                        .frame(width: w)
                        .frame(height: 1)
                        .position(x: w / 2, y: fy * h)
                }
            }
            // Draw intersection dots
            if nx > 0 && ny > 0 {
                ForEach(0...nx, id: \.self) { ix in
                    ForEach(0...ny, id: \.self) { iy in
                        let fx = CGFloat(ix) / CGFloat(nx)
                        let fy = CGFloat(iy) / CGFloat(ny)
                        let isSnapped = configuration.isSnappedToTick
                            && abs((configuration.snappedTickPctX ?? -1) - Double(fx)) < 0.001
                            && abs((configuration.snappedTickPctY ?? -1) - Double(fy)) < 0.001
                        Circle()
                            .fill(isSnapped
                                  ? Color(.sRGB, red: 0.204, green: 0.648, blue: 0.855).opacity(0.85)
                                  : Color.primary.opacity(0.22))
                            .frame(width: isSnapped ? 8 : 4, height: isSnapped ? 8 : 4)
                            .position(x: fx * w, y: fy * h)
                            .animation(.easeOut(duration: 0.12), value: isSnapped)
                    }
                }
            }
        }
    }
    
    /// Default label: the current value in a floating capsule that appears when active.
    func makeLabel(configuration: TrackPadConfiguration, content: AnyView) -> some View {
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

// MARK: - AnyTrackPadStyle

/// A type-erased ``TrackPadStyle``.
///
/// This allows any `TrackPadStyle` to be stored in the SwiftUI environment.
public struct AnyTrackPadStyle: TrackPadStyle, Sendable {
    private let _makeThumb: @Sendable (TrackPadConfiguration) -> AnyView
    private let _makeTrack: @Sendable (TrackPadConfiguration) -> AnyView
    private let _makePreviousValueIndicator: @Sendable (TrackPadConfiguration) -> AnyView
    private let _makeTickMarks: @Sendable (TrackPadConfiguration) -> AnyView
    private let _makeLabel: @Sendable (TrackPadConfiguration, AnyView) -> AnyView

    public func makeThumb(configuration: TrackPadConfiguration) -> some View {
        _makeThumb(configuration)
    }
    public func makeTrack(configuration: TrackPadConfiguration) -> some View {
        _makeTrack(configuration)
    }
    public func makePreviousValueIndicator(configuration: TrackPadConfiguration) -> some View {
        _makePreviousValueIndicator(configuration)
    }
    public func makeTickMarks(configuration: TrackPadConfiguration) -> some View {
        _makeTickMarks(configuration)
    }
    public func makeLabel(configuration: TrackPadConfiguration, content: AnyView) -> some View {
        _makeLabel(configuration, content)
    }

    /// Creates a type-erased wrapper around the given style.
    ///
    /// - Parameter style: Any concrete ``TrackPadStyle`` conformance to wrap.
    public init<S: TrackPadStyle>(_ style: S) {
        self._makeThumb = style.makeThumbTypeErased
        self._makeTrack = style.makeTrackTypeErased
        self._makePreviousValueIndicator = style.makePreviousValueIndicatorTypeErased
        self._makeTickMarks = style.makeTickMarksTypeErased
        self._makeLabel = style.makeLabelTypeErased
    }
}

// MARK: - Environment

/// The environment key used to store the current ``TrackPadStyle``.
public struct TrackPadStyleKey: EnvironmentKey {
    /// The default value — ``DefaultTrackPadStyle`` — used when no explicit style has been set.
    public static let defaultValue: AnyTrackPadStyle = AnyTrackPadStyle(DefaultTrackPadStyle())
}

extension EnvironmentValues {
    /// The current track-pad style stored in the environment.
    public var trackPadStyle: AnyTrackPadStyle {
        get { self[TrackPadStyleKey.self] }
        set { self[TrackPadStyleKey.self] = newValue }
    }
}

extension View {
    /// Sets the style for ``TrackPad`` instances within this view.
    ///
    /// Works like other SwiftUI style modifiers (e.g. `buttonStyle(_:)`).
    public func trackPadStyle<S: TrackPadStyle>(_ style: S) -> some View {
        environment(\.trackPadStyle, AnyTrackPadStyle(style))
    }
}

// MARK: - SwiftUI-style presets

public extension TrackPadStyle where Self == DefaultTrackPadStyle {
    /// The built-in default track-pad style.
    static var `default`: DefaultTrackPadStyle { DefaultTrackPadStyle() }
    
    /// The built-in default track-pad style with customisable colours.
    static func `default`(
        trackColor: Color = Color(.sRGB, red: 0.55, green: 0.55, blue: 0.59).opacity(0.25),
        trackStrokeColor: Color = Color(.sRGB, red: 0.55, green: 0.55, blue: 0.59),
        thumbInactiveColor: Color = Color(.sRGB, red: 0.204, green: 0.648, blue: 0.855),
        thumbActiveColor: Color = Color.white,
        thumbDisabledColor: Color = Color(.sRGB, red: 0.75, green: 0.75, blue: 0.75),
        trackDisabledColor: Color = Color(.sRGB, red: 0.75, green: 0.75, blue: 0.75),
        thumbSize: Double = 36
    ) -> DefaultTrackPadStyle {
        DefaultTrackPadStyle(
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

/// The built-in default style for ``TrackPad``.
///
/// Uses the same colour palette as ``DefaultRSliderStyle`` and ``DefaultLSliderStyle``:
/// - Track: a subtle grey fill with a matching stroke border.
/// - Thumb: a circle that switches from the accent blue when idle to white when active,
///   matching the thumb behaviour of the linear and radial sliders.
/// - Previous-value indicator: inherited from the protocol default — a blue ring + crosshair.
public struct DefaultTrackPadStyle: TrackPadStyle, Sendable {
    
    let trackColor: Color
    let trackStrokeColor: Color
    let thumbInactiveColor: Color
    let thumbActiveColor: Color
    let thumbDisabledColor: Color
    let trackDisabledColor: Color
    let thumbSize: Double
    
    /// Creates the default track-pad style with customisable parameters.
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
    
    /// Creates the thumb — a circle that fills with `thumbActiveColor` while dragging,
    /// `thumbInactiveColor` at rest, or `thumbDisabledColor` when disabled, with a drop
    /// shadow when active.
    public func makeThumb(configuration: TrackPadConfiguration) -> some View {
        let color: Color = configuration.isDisabled
            ? thumbInactiveColor.mix(with: thumbDisabledColor, by: 0.5)
            : (configuration.isActive ? thumbActiveColor : thumbInactiveColor)
        return Circle()
            .fill(color)
            .frame(width: thumbSize, height: thumbSize)
            .shadow(radius: configuration.isDisabled ? 0 : (configuration.isActive ? 3 : 0))
    }

    /// Creates the track — a rounded rectangle with a subtle fill and stroke border.
    /// When disabled, the stroke colour shifts to `trackDisabledColor`.
    public func makeTrack(configuration: TrackPadConfiguration) -> some View {
        let strokeColor = configuration.isDisabled ? trackDisabledColor : trackStrokeColor
        return RoundedRectangle(cornerRadius: 12)
            .fill(trackColor)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(strokeColor.opacity(0.6), lineWidth: 1)
            )
            .opacity(configuration.isDisabled ? 0.5 : 1.0)
    }
    // makePreviousValueIndicator uses the protocol default implementation
}
