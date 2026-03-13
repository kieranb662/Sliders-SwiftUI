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

    /// Creates the draggable thumb.
    func makeThumb(configuration: TrackPadConfiguration) -> Self.Thumb

    /// Creates the track background.
    func makeTrack(configuration: TrackPadConfiguration) -> Self.Track

    /// Creates the view shown at the previous-value position.
    ///
    /// ``TrackPad`` places this view at the correct offset automatically; you only need to
    /// return the indicator's intrinsic appearance. A default implementation is provided.
    func makePreviousValueIndicator(configuration: TrackPadConfiguration) -> Self.PreviousValueIndicator
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
}

// MARK: - AnyTrackPadStyle

/// A type-erased ``TrackPadStyle``.
///
/// This allows any `TrackPadStyle` to be stored in the SwiftUI environment.
public struct AnyTrackPadStyle: TrackPadStyle, Sendable {
    private let _makeThumb: @Sendable (TrackPadConfiguration) -> AnyView
    private let _makeTrack: @Sendable (TrackPadConfiguration) -> AnyView
    private let _makePreviousValueIndicator: @Sendable (TrackPadConfiguration) -> AnyView

    public func makeThumb(configuration: TrackPadConfiguration) -> some View {
        _makeThumb(configuration)
    }
    public func makeTrack(configuration: TrackPadConfiguration) -> some View {
        _makeTrack(configuration)
    }
    public func makePreviousValueIndicator(configuration: TrackPadConfiguration) -> some View {
        _makePreviousValueIndicator(configuration)
    }

    public init<S: TrackPadStyle>(_ style: S) {
        self._makeThumb = style.makeThumbTypeErased
        self._makeTrack = style.makeTrackTypeErased
        self._makePreviousValueIndicator = style.makePreviousValueIndicatorTypeErased
    }
}

// MARK: - Environment

/// The environment key used to store the current ``TrackPadStyle``.
public struct TrackPadStyleKey: EnvironmentKey {
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
    ///
    /// Usage:
    /// ```swift
    /// TrackPad($point)
    ///     .trackPadStyle(.default(trackColor: .purple))
    /// ```
    static func `default`(
        trackColor: Color = Color(.sRGB, red: 0.55, green: 0.55, blue: 0.59).opacity(0.25),
        trackStrokeColor: Color = Color(.sRGB, red: 0.55, green: 0.55, blue: 0.59),
        thumbInactiveColor: Color = Color(.sRGB, red: 0.204, green: 0.648, blue: 0.855),
        thumbActiveColor: Color = Color.white,
        thumbSize: Double = 36
    ) -> DefaultTrackPadStyle {
        DefaultTrackPadStyle(
            trackColor: trackColor,
            trackStrokeColor: trackStrokeColor,
            thumbInactiveColor: thumbInactiveColor,
            thumbActiveColor: thumbActiveColor,
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
    let thumbSize: Double

    /// Creates the default track-pad style with customisable parameters.
    public init(
        trackColor: Color = Color(.sRGB, red: 0.55, green: 0.55, blue: 0.59).opacity(0.25),
        trackStrokeColor: Color = Color(.sRGB, red: 0.55, green: 0.55, blue: 0.59),
        thumbInactiveColor: Color = Color(.sRGB, red: 0.204, green: 0.648, blue: 0.855),
        thumbActiveColor: Color = Color.white,
        thumbSize: Double = 36
    ) {
        self.trackColor = trackColor
        self.trackStrokeColor = trackStrokeColor
        self.thumbInactiveColor = thumbInactiveColor
        self.thumbActiveColor = thumbActiveColor
        self.thumbSize = thumbSize
    }

    public func makeThumb(configuration: TrackPadConfiguration) -> some View {
        Circle()
            .fill(configuration.isActive ? thumbActiveColor : thumbInactiveColor)
            .frame(width: thumbSize, height: thumbSize)
            .shadow(
                color: Color.black.opacity(0.2),
                radius: configuration.isActive ? 6 : 2
            )
            .overlay(
                Circle()
                    .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
            )
    }

    public func makeTrack(configuration: TrackPadConfiguration) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(trackColor)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(trackStrokeColor.opacity(0.6), lineWidth: 1)
            )
    }
    // makePreviousValueIndicator uses the protocol default implementation
}
