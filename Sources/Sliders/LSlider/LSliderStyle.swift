// Swift toolchain version 6.0
// Running macOS version 26.3
// Created on 3/11/26.
//
// Author: Kieran Brown
//

import SwiftUI

// MARK: - LSlider Configuration

/// A value type describing the current state of an ``LSlider``.
///
/// Instances of ``LSliderConfiguration`` are provided to an ``LSliderStyle`` so your style can
/// render the thumb, track, and tick marks based on the slider's live interaction state.
public struct LSliderConfiguration: Sendable {
    /// Whether the slider is disabled.
    ///
    /// This is derived from SwiftUI's `\.isEnabled` environment value.
    public let isDisabled: Bool

    /// Whether the user is actively dragging the thumb.
    public let isActive: Bool

    /// The normalized fill percent in the range `[0, 1]`.
    ///
    /// This value is computed from ``value``, ``min``, and ``max``.
    public let pctFill: Double

    /// The current value of the slider.
    ///
    /// When tick-mark affinity is enabled, this may be set to a snapped tick value while
    /// the user is dragging.
    public let value: Double

    /// The angle of the slider's track.
    public let angle: Angle

    /// The minimum value of the slider's range.
    public let min: Double

    /// The maximum value of the slider's range.
    public let max: Double

    /// Whether the thumb is constrained to stay within the visual extent of the track.
    public let keepThumbInTrack: Bool

    /// The thickness of the track.
    ///
    /// This affects layout and is commonly used by styles to size the thumb.
    public let trackThickness: Double

    /// The tick-mark spacing configuration, or `nil` if tick marks are disabled.
    public let tickMarkSpacing: TickMarkSpacing?

    /// The resolved tick-mark values computed from ``tickMarkSpacing`` and clamped to `min...max`.
    ///
    /// Styles can use this array to render tick marks. The values are sorted in ascending order.
    public let tickValues: [Double]

    /// Whether tick-mark affinity (magnetic snap) is enabled.
    public let affinityEnabled: Bool

    /// The tick-mark value the thumb is currently snapped to, or `nil` when not snapped.
    ///
    /// Styles can use this to highlight the tick mark that is currently "captured".
    public let snappedTickValue: Double?
}

// MARK: - LSlider Style

/// A style that determines the appearance of an ``LSlider``.
///
/// Provide custom rendering for:
/// - the thumb (draggable control)
/// - the track (background and filled portion)
/// - optional tick marks
///
/// Apply a style using ``SwiftUI/View/linearSliderStyle(_:)``.
public protocol LSliderStyle: Sendable {
    associatedtype Thumb: View
    associatedtype Track: View
    associatedtype TickMark: View
    associatedtype LabelContainer: View

    /// Creates the draggable thumb view.
    ///
    /// - Parameter configuration: The current slider configuration.
    func makeThumb(configuration: LSliderConfiguration) -> Self.Thumb

    /// Creates the track view (including the filled portion if desired).
    ///
    /// - Parameter configuration: The current slider configuration.
    func makeTrack(configuration: LSliderConfiguration) -> Self.Track

    /// Creates the view rendered at a single tick-mark position.
    ///
    /// This method is called once per value in ``LSliderConfiguration/tickValues``.
    ///
    /// - Parameters:
    ///   - configuration: The current slider configuration.
    ///   - tickValue: The value (in the slider's domain) at which this tick mark sits.
    func makeTickMark(configuration: LSliderConfiguration, tickValue: Double) -> Self.TickMark

    /// Creates the styled container for a thumb label.
    ///
    /// - Parameters:
    ///   - configuration: The current slider configuration.
    ///   - content: The pre-styled label view provided by the caller.
    func makeLabel(configuration: LSliderConfiguration, content: AnyView) -> Self.LabelContainer
}

public extension LSliderStyle {
    /// Returns a type-erased ``AnyView`` wrapping the thumb produced by ``makeThumb(configuration:)``.
    ///
    /// Used internally by ``AnyLSliderStyle`` to store the style without a concrete type.
    func makeThumbTypeErased(configuration: LSliderConfiguration) -> AnyView {
        AnyView(self.makeThumb(configuration: configuration))
    }

    /// Returns a type-erased ``AnyView`` wrapping the track produced by ``makeTrack(configuration:)``.
    ///
    /// Used internally by ``AnyLSliderStyle`` to store the style without a concrete type.
    func makeTrackTypeErased(configuration: LSliderConfiguration) -> AnyView {
        AnyView(self.makeTrack(configuration: configuration))
    }

    /// Returns a type-erased ``AnyView`` wrapping the tick mark produced by ``makeTickMark(configuration:tickValue:)``.
    ///
    /// Used internally by ``AnyLSliderStyle`` to store the style without a concrete type.
    func makeTickMarkTypeErased(configuration: LSliderConfiguration, tickValue: Double) -> AnyView {
        AnyView(self.makeTickMark(configuration: configuration, tickValue: tickValue))
    }

    /// Returns a type-erased ``AnyView`` wrapping the label container produced by ``makeLabel(configuration:content:)``.
    ///
    /// Used internally by ``AnyLSliderStyle`` to store the style without a concrete type.
    func makeLabelTypeErased(configuration: LSliderConfiguration, content: AnyView) -> AnyView {
        AnyView(self.makeLabel(configuration: configuration, content: content))
    }

    /// Default label implementation: displays the current value in a floating capsule.
    ///
    /// The capsule fades in and scales up while the thumb is active, then fades out when
    /// the user lifts their finger. Override ``makeLabel(configuration:content:)`` in your
    /// style to provide a different container.
    func makeLabel(configuration: LSliderConfiguration, content: AnyView) -> some View {
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

// MARK: - AnyLSliderStyle

/// A type-erased ``LSliderStyle``.
///
/// ``LSlider`` stores its style in the SwiftUI environment, which requires a concrete type.
/// `AnyLSliderStyle` wraps any style and forwards the view-building calls.
public struct AnyLSliderStyle: LSliderStyle, Sendable {
    private let _makeThumb: @Sendable (LSliderConfiguration) -> AnyView
    private let _makeTrack: @Sendable (LSliderConfiguration) -> AnyView
    private let _makeTickMark: @Sendable (LSliderConfiguration, Double) -> AnyView
    private let _makeLabel: @Sendable (LSliderConfiguration, AnyView) -> AnyView

    /// Forwards to the wrapped style's ``LSliderStyle/makeThumb(configuration:)`` implementation.
    public func makeThumb(configuration: LSliderConfiguration) -> some View {
        _makeThumb(configuration)
    }

    /// Forwards to the wrapped style's ``LSliderStyle/makeTrack(configuration:)`` implementation.
    public func makeTrack(configuration: LSliderConfiguration) -> some View {
        _makeTrack(configuration)
    }

    /// Forwards to the wrapped style's ``LSliderStyle/makeTickMark(configuration:tickValue:)`` implementation.
    public func makeTickMark(configuration: LSliderConfiguration, tickValue: Double) -> some View {
        _makeTickMark(configuration, tickValue)
    }

    /// Forwards to the wrapped style's ``LSliderStyle/makeLabel(configuration:content:)`` implementation.
    public func makeLabel(configuration: LSliderConfiguration, content: AnyView) -> some View {
        _makeLabel(configuration, content)
    }

    /// Creates a type-erased wrapper around `style`.
    ///
    /// - Parameter style: Any concrete ``LSliderStyle`` to wrap.
    public init<S: LSliderStyle>(_ style: S) {
        self._makeThumb = style.makeThumbTypeErased
        self._makeTrack = style.makeTrackTypeErased
        self._makeTickMark = style.makeTickMarkTypeErased
        self._makeLabel = style.makeLabelTypeErased
    }
}

// MARK: - Environment

/// An environment key used to store the current ``LSliderStyle``.
///
/// The default value is ``AnyLSliderStyle`` wrapping ``DefaultLSliderStyle``.
public struct LSliderStyleKey: EnvironmentKey {
    /// The default style used when no custom style is provided.
    ///
    /// Defaults to ``DefaultLSliderStyle``.
    public static let defaultValue: AnyLSliderStyle = AnyLSliderStyle(DefaultLSliderStyle())
}

extension EnvironmentValues {
    /// The current linear slider style used by ``LSlider``.
    ///
    /// Set this value using ``SwiftUI/View/linearSliderStyle(_:)``.
    public var linearSliderStyle: AnyLSliderStyle {
        get { self[LSliderStyleKey.self] }
        set { self[LSliderStyleKey.self] = newValue }
    }
}

extension View {
    /// Sets the style for ``LSlider`` instances within this view hierarchy.
    ///
    /// - Parameter style: The style to apply. Must conform to ``LSliderStyle``.
    /// - Returns: A view that uses `style` to render any descendant ``LSlider``.
    public func linearSliderStyle<S>(_ style: S) -> some View where S: LSliderStyle {
        environment(\.linearSliderStyle, AnyLSliderStyle(style))
    }
}

// MARK: - Default LSlider Style

/// The default style used by ``LSlider``.
///
/// This style draws a rounded track with a filled portion and a circular thumb sized from
/// ``LSliderConfiguration/trackThickness``.
public struct DefaultLSliderStyle: LSliderStyle, Sendable {

    let trackColor: Color
    let trackFilledColor: Color
    let thumbInactiveColor: Color
    let thumbActiveColor: Color
    let thumbDisabledColor: Color
    let trackDisabledColor: Color
    let tickMarkBaseSize: Double
    let tickMarkMaxGrowth: Double
    let tickMarkBaseOpacity: Double
    let tickMarkMaxOpacity: Double
    let tickMarkProximityThreshold: Double

    /// Creates the default style with customizable colors and tick-mark appearance.
    public init(
        trackColor: Color = Color(.sRGB, red: 0.55, green: 0.55, blue: 0.59),
        trackFilledColor: Color = Color(.sRGB, red: 0.084, green: 0.247, blue: 0.602),
        thumbInactiveColor: Color = Color(.sRGB, red: 0.204, green: 0.648, blue: 0.855),
        thumbActiveColor: Color = Color.white,
        thumbDisabledColor: Color = Color(.sRGB, red: 0.75, green: 0.75, blue: 0.75),
        trackDisabledColor: Color = Color(.sRGB, red: 0.75, green: 0.75, blue: 0.75),
        tickMarkBaseSize: Double = 5,
        tickMarkMaxGrowth: Double = 7,
        tickMarkBaseOpacity: Double = 0.30,
        tickMarkMaxOpacity: Double = 1.00,
        tickMarkProximityThreshold: Double = 0.20
    ) {
        self.trackColor = trackColor
        self.trackFilledColor = trackFilledColor
        self.thumbInactiveColor = thumbInactiveColor
        self.thumbActiveColor = thumbActiveColor
        self.thumbDisabledColor = thumbDisabledColor
        self.trackDisabledColor = trackDisabledColor
        self.tickMarkBaseSize = tickMarkBaseSize
        self.tickMarkMaxGrowth = tickMarkMaxGrowth
        self.tickMarkBaseOpacity = tickMarkBaseOpacity
        self.tickMarkMaxOpacity = tickMarkMaxOpacity
        self.tickMarkProximityThreshold = tickMarkProximityThreshold
    }

    /// Creates the thumb: a circle that turns white while the user is dragging,
    /// or grey when the slider is disabled.
    public func makeThumb(configuration: LSliderConfiguration) -> some View {
        let color: Color = configuration.isDisabled
        ? thumbActiveColor.mix(with: thumbDisabledColor, by: 0.5)
            : (configuration.isActive ? thumbActiveColor : thumbInactiveColor)

        return Circle()
            .fill(color)
            .frame(width: configuration.trackThickness * 2, height: configuration.trackThickness * 2)
            .shadow(
                color: Color.black.opacity(configuration.isDisabled ? 0.0 : 0.2),
                radius: configuration.isActive ? 5 : 2
            )
    }

    /// Creates the track: a rounded capsule with a filled portion up to the current value.
    /// When disabled, both the empty and filled portions use `trackDisabledColor`.
    public func makeTrack(configuration: LSliderConfiguration) -> some View {
        let adjustment: Double = configuration.keepThumbInTrack
            ? configuration.trackThickness * (1 - configuration.pctFill)
            : configuration.trackThickness / 2

        let filledColor = configuration.isDisabled ? trackFilledColor.mix(with: trackDisabledColor, by: 0.5) : trackFilledColor

        return ZStack {
            AdaptiveLine(thickness: configuration.trackThickness, angle: configuration.angle)
                .fill(trackColor)

            AdaptiveLine(
                thickness: configuration.trackThickness,
                angle: configuration.angle,
                percentFilled: configuration.pctFill,
                adjustmentForThumb: adjustment
            )
            .fill(filledColor)
            .mask(AdaptiveLine(thickness: configuration.trackThickness, angle: configuration.angle))
        }
        .opacity(configuration.isDisabled ? 0.5 : 1.0)
    }

    /// Creates a tick-mark indicator: a small circle that grows and brightens as the thumb approaches.
    public func makeTickMark(configuration: LSliderConfiguration, tickValue: Double) -> some View {
        let range = configuration.max - configuration.min
        guard range > 0 else {
            return AnyView(Circle().fill(Color.white.opacity(tickMarkBaseOpacity)).frame(width: tickMarkBaseSize, height: tickMarkBaseSize))
        }
        // Normalised distance in [0, 1] between thumb and tick mark
        let thumbPct  = (configuration.value - configuration.min) / range
        let tickPct   = (tickValue          - configuration.min) / range
        let distance  = abs(thumbPct - tickPct)

        // Proximity is 1 when thumb is exactly on the tick, 0 when ≥ proximityThreshold away
        let proximity = max(0, 1 - distance / tickMarkProximityThreshold)

        let size = tickMarkBaseSize + tickMarkMaxGrowth * proximity
        let opacity = tickMarkBaseOpacity + (tickMarkMaxOpacity - tickMarkBaseOpacity) * proximity

        return AnyView(
            Circle()
                .fill(Color.white.opacity(opacity))
                .frame(width: size, height: size)
                .animation(.easeOut(duration: 0.1), value: proximity)
        )
    }
}

// MARK: - SwiftUI-style presets

public extension LSliderStyle where Self == DefaultLSliderStyle {
    /// The built-in default linear slider style.
    static var `default`: DefaultLSliderStyle { DefaultLSliderStyle() }

    /// The built-in default linear slider style, with customizable parameters.
    ///
    /// Usage:
    /// `LSlider($value).linearSliderStyle(.default(trackThickness: 12))`
    static func `default`(
        trackColor: Color = Color(.sRGB, red: 0.55, green: 0.55, blue: 0.59),
        trackFilledColor: Color = Color(.sRGB, red: 0.084, green: 0.247, blue: 0.602),
        thumbInactiveColor: Color = Color(.sRGB, red: 0.204, green: 0.648, blue: 0.855),
        thumbActiveColor: Color = Color.white,
        thumbDisabledColor: Color = Color(.sRGB, red: 0.75, green: 0.75, blue: 0.75),
        trackDisabledColor: Color = Color(.sRGB, red: 0.75, green: 0.75, blue: 0.75),
        tickMarkBaseSize: Double = 5,
        tickMarkMaxGrowth: Double = 7,
        tickMarkBaseOpacity: Double = 0.30,
        tickMarkMaxOpacity: Double = 1.00,
        tickMarkProximityThreshold: Double = 0.20
    ) -> DefaultLSliderStyle {
        DefaultLSliderStyle(
            trackColor: trackColor,
            trackFilledColor: trackFilledColor,
            thumbInactiveColor: thumbInactiveColor,
            thumbActiveColor: thumbActiveColor,
            thumbDisabledColor: thumbDisabledColor,
            trackDisabledColor: trackDisabledColor,
            tickMarkBaseSize: tickMarkBaseSize,
            tickMarkMaxGrowth: tickMarkMaxGrowth,
            tickMarkBaseOpacity: tickMarkBaseOpacity,
            tickMarkMaxOpacity: tickMarkMaxOpacity,
            tickMarkProximityThreshold: tickMarkProximityThreshold
        )
    }
}
