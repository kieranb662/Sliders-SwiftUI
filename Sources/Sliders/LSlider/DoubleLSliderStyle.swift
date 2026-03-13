// Swift toolchain version 6.0
// Running macOS version 26.3
// Created on 3/13/26.
//
// Author: Kieran Brown
//

import SwiftUI

// MARK: - DoubleLSlider Configuration

/// A value type describing the current state of a ``DoubleLSlider``.
///
/// Instances of `DoubleLSliderConfiguration` are provided to a ``DoubleLSliderStyle`` so your
/// style can render the thumbs, track, and tick marks based on the slider's live interaction state.
public struct DoubleLSliderConfiguration: Sendable {
    /// Whether the slider is disabled.
    public let isDisabled: Bool

    /// Whether the user is actively dragging the lower (start) thumb.
    public let isLowerActive: Bool

    /// Whether the user is actively dragging the upper (end) thumb.
    public let isUpperActive: Bool

    /// Whether the user is actively dragging the active track range.
    public let isRangeActive: Bool

    /// The current lower (start) value.
    public let lowerValue: Double

    /// The current upper (end) value.
    public let upperValue: Double

    /// The angle of the slider's track.
    public let angle: Angle

    /// The minimum value of the slider's range.
    public let min: Double

    /// The maximum value of the slider's range.
    public let max: Double

    /// Whether the thumbs are constrained to stay within the visual extent of the track.
    public let keepThumbInTrack: Bool

    /// The thickness of the track.
    public let trackThickness: Double

    /// The tick-mark spacing configuration, or `nil` if tick marks are disabled.
    public let tickMarkSpacing: TickMarkSpacing?

    /// The resolved tick-mark values computed from ``tickMarkSpacing`` and clamped to `min...max`.
    public let tickValues: [Double]

    /// Whether tick-mark affinity (magnetic snap) is enabled.
    public let affinityEnabled: Bool

    /// The tick-mark value the lower thumb is currently snapped to, or `nil` when not snapped.
    public let snappedLowerTickValue: Double?

    /// The tick-mark value the upper thumb is currently snapped to, or `nil` when not snapped.
    public let snappedUpperTickValue: Double?

    /// The lower value normalised to `0...1`.
    public var lowerPercent: Double {
        guard max > min else { return 0 }
        return (lowerValue - min) / (max - min)
    }

    /// The upper value normalised to `0...1`.
    public var upperPercent: Double {
        guard max > min else { return 0 }
        return (upperValue - min) / (max - min)
    }
}

// MARK: - DoubleLSlider Style Protocol

/// A style that determines the appearance of a ``DoubleLSlider``.
///
/// Conform to `DoubleLSliderStyle` to provide custom rendering for the lower thumb, upper thumb,
/// track, and optional tick marks.
///
/// Apply a style using ``SwiftUI/View/doubleLSliderStyle(_:)``.
public protocol DoubleLSliderStyle: Sendable {
    associatedtype LowerThumb: View
    associatedtype UpperThumb: View
    associatedtype Track: View
    associatedtype TickMark: View
    associatedtype LowerLabel: View
    associatedtype UpperLabel: View

    /// Creates the lower (start) draggable thumb view.
    ///
    /// - Parameter configuration: The current slider configuration.
    func makeLowerThumb(configuration: DoubleLSliderConfiguration) -> Self.LowerThumb

    /// Creates the upper (end) draggable thumb view.
    ///
    /// - Parameter configuration: The current slider configuration.
    func makeUpperThumb(configuration: DoubleLSliderConfiguration) -> Self.UpperThumb

    /// Creates the track view, including the filled portion between the two thumbs.
    ///
    /// - Parameter configuration: The current slider configuration.
    func makeTrack(configuration: DoubleLSliderConfiguration) -> Self.Track

    /// Creates the view rendered at a single tick-mark position.
    ///
    /// This method is called once per value in ``DoubleLSliderConfiguration/tickValues``.
    ///
    /// - Parameters:
    ///   - configuration: The current slider configuration.
    ///   - tickValue: The value (in the slider's domain) at which this tick mark sits.
    func makeTickMark(configuration: DoubleLSliderConfiguration, tickValue: Double) -> Self.TickMark

    /// Creates the styled container for the lower thumb label.
    ///
    /// - Parameters:
    ///   - configuration: The current slider configuration.
    ///   - content: The pre-styled label view provided by the caller.
    func makeLowerLabel(configuration: DoubleLSliderConfiguration, content: AnyView) -> Self.LowerLabel

    /// Creates the styled container for the upper thumb label.
    ///
    /// - Parameters:
    ///   - configuration: The current slider configuration.
    ///   - content: The pre-styled label view provided by the caller.
    func makeUpperLabel(configuration: DoubleLSliderConfiguration, content: AnyView) -> Self.UpperLabel
}

// MARK: - Default TickMark

public extension DoubleLSliderStyle {
    /// Returns a type-erased ``AnyView`` wrapping the lower thumb produced by ``makeLowerThumb(configuration:)``.
    ///
    /// Used internally by ``AnyDoubleLSliderStyle`` to store the style without a concrete type.
    func makeLowerThumbTypeErased(configuration: DoubleLSliderConfiguration) -> AnyView {
        AnyView(self.makeLowerThumb(configuration: configuration))
    }

    /// Returns a type-erased ``AnyView`` wrapping the upper thumb produced by ``makeUpperThumb(configuration:)``.
    ///
    /// Used internally by ``AnyDoubleLSliderStyle`` to store the style without a concrete type.
    func makeUpperThumbTypeErased(configuration: DoubleLSliderConfiguration) -> AnyView {
        AnyView(self.makeUpperThumb(configuration: configuration))
    }

    /// Returns a type-erased ``AnyView`` wrapping the track produced by ``makeTrack(configuration:)``.
    ///
    /// Used internally by ``AnyDoubleLSliderStyle`` to store the style without a concrete type.
    func makeTrackTypeErased(configuration: DoubleLSliderConfiguration) -> AnyView {
        AnyView(self.makeTrack(configuration: configuration))
    }

    /// Returns a type-erased ``AnyView`` wrapping the tick mark produced by ``makeTickMark(configuration:tickValue:)``.
    ///
    /// Used internally by ``AnyDoubleLSliderStyle`` to store the style without a concrete type.
    func makeTickMarkTypeErased(configuration: DoubleLSliderConfiguration, tickValue: Double) -> AnyView {
        AnyView(self.makeTickMark(configuration: configuration, tickValue: tickValue))
    }

    /// Type-erases ``makeLowerLabel(configuration:content:)`` for storage in ``AnyDoubleLSliderStyle``.
    func makeLowerLabelTypeErased(configuration: DoubleLSliderConfiguration, content: AnyView) -> AnyView {
        AnyView(self.makeLowerLabel(configuration: configuration, content: content))
    }

    /// Type-erases ``makeUpperLabel(configuration:content:)`` for storage in ``AnyDoubleLSliderStyle``.
    func makeUpperLabelTypeErased(configuration: DoubleLSliderConfiguration, content: AnyView) -> AnyView {
        AnyView(self.makeUpperLabel(configuration: configuration, content: content))
    }

    /// Default tick mark: a small white circle that grows and brightens as either thumb approaches.
    func makeTickMark(configuration: DoubleLSliderConfiguration, tickValue: Double) -> some View {
        let range = configuration.max - configuration.min
        guard range > 0 else {
            return AnyView(Circle().fill(Color.white.opacity(0.3)).frame(width: 6, height: 6))
        }
        let lowerPct = (configuration.lowerValue - configuration.min) / range
        let upperPct = (configuration.upperValue - configuration.min) / range
        let tickPct  = (tickValue - configuration.min) / range
        let proximityLower = max(0.0, 1.0 - abs(lowerPct - tickPct) / 0.20)
        let proximityUpper = max(0.0, 1.0 - abs(upperPct - tickPct) / 0.20)
        let proximity = max(proximityLower, proximityUpper)
        let size    = 5.0 + 7.0 * proximity
        let opacity = 0.30 + 0.70 * proximity
        return AnyView(
            Circle()
                .fill(Color.white.opacity(opacity))
                .frame(width: size, height: size)
                .animation(.easeOut(duration: 0.1), value: proximity)
        )
    }

    /// Default lower label: the current lower value in a floating capsule.
    ///
    /// The capsule fades in and scales up while the lower thumb (or range) is active.
    /// Override ``makeLowerLabel(configuration:content:)`` in your style to provide a different container.
    func makeLowerLabel(configuration: DoubleLSliderConfiguration, content: AnyView) -> some View {
        let isActive = configuration.isLowerActive || configuration.isRangeActive
        return content
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .shadow(color: Color.black.opacity(0.15), radius: 2, y: 1)
            )
            .scaleEffect(isActive ? 1.0 : 0.8)
            .opacity(isActive ? 1.0 : 0.0)
            .animation(.easeOut(duration: 0.15), value: isActive)
    }

    /// Default upper label: the current upper value in a floating capsule.
    ///
    /// The capsule fades in and scales up while the upper thumb (or range) is active.
    /// Override ``makeUpperLabel(configuration:content:)`` in your style to provide a different container.
    func makeUpperLabel(configuration: DoubleLSliderConfiguration, content: AnyView) -> some View {
        let isActive = configuration.isUpperActive || configuration.isRangeActive
        return content
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .shadow(color: Color.black.opacity(0.15), radius: 2, y: 1)
            )
            .scaleEffect(isActive ? 1.0 : 0.8)
            .opacity(isActive ? 1.0 : 0.0)
            .animation(.easeOut(duration: 0.15), value: isActive)
    }
}

// MARK: - AnyDoubleLSliderStyle

/// A type-erased ``DoubleLSliderStyle``.
///
/// ``DoubleLSlider`` stores its style in the SwiftUI environment, which requires a concrete type.
/// `AnyDoubleLSliderStyle` wraps any style and forwards the view-building calls.
public struct AnyDoubleLSliderStyle: DoubleLSliderStyle, Sendable {
    private let _makeLowerThumb: @Sendable (DoubleLSliderConfiguration) -> AnyView
    private let _makeUpperThumb: @Sendable (DoubleLSliderConfiguration) -> AnyView
    private let _makeTrack: @Sendable (DoubleLSliderConfiguration) -> AnyView
    private let _makeTickMark: @Sendable (DoubleLSliderConfiguration, Double) -> AnyView
    private let _makeLowerLabel: @Sendable (DoubleLSliderConfiguration, AnyView) -> AnyView
    private let _makeUpperLabel: @Sendable (DoubleLSliderConfiguration, AnyView) -> AnyView

    /// Forwards to the wrapped style's ``DoubleLSliderStyle/makeLowerThumb(configuration:)`` implementation.
    public func makeLowerThumb(configuration: DoubleLSliderConfiguration) -> some View {
        _makeLowerThumb(configuration)
    }

    /// Forwards to the wrapped style's ``DoubleLSliderStyle/makeUpperThumb(configuration:)`` implementation.
    public func makeUpperThumb(configuration: DoubleLSliderConfiguration) -> some View {
        _makeUpperThumb(configuration)
    }

    /// Forwards to the wrapped style's ``DoubleLSliderStyle/makeTrack(configuration:)`` implementation.
    public func makeTrack(configuration: DoubleLSliderConfiguration) -> some View {
        _makeTrack(configuration)
    }

    /// Forwards to the wrapped style's ``DoubleLSliderStyle/makeTickMark(configuration:tickValue:)`` implementation.
    public func makeTickMark(configuration: DoubleLSliderConfiguration, tickValue: Double) -> some View {
        _makeTickMark(configuration, tickValue)
    }

    /// Forwards to the wrapped style's ``DoubleLSliderStyle/makeLowerLabel(configuration:content:)`` implementation.
    public func makeLowerLabel(configuration: DoubleLSliderConfiguration, content: AnyView) -> some View {
        _makeLowerLabel(configuration, content)
    }

    /// Forwards to the wrapped style's ``DoubleLSliderStyle/makeUpperLabel(configuration:content:)`` implementation.
    public func makeUpperLabel(configuration: DoubleLSliderConfiguration, content: AnyView) -> some View {
        _makeUpperLabel(configuration, content)
    }

    /// Creates a type-erased wrapper around `style`.
    ///
    /// - Parameter style: Any concrete ``DoubleLSliderStyle`` to wrap.
    public init<S: DoubleLSliderStyle>(_ style: S) {
        self._makeLowerThumb = style.makeLowerThumbTypeErased
        self._makeUpperThumb = style.makeUpperThumbTypeErased
        self._makeTrack = style.makeTrackTypeErased
        self._makeTickMark = style.makeTickMarkTypeErased
        self._makeLowerLabel = style.makeLowerLabelTypeErased
        self._makeUpperLabel = style.makeUpperLabelTypeErased
    }
}

// MARK: - Environment

/// The environment key used to store the current ``DoubleLSliderStyle``.
///
/// The default value is ``AnyDoubleLSliderStyle`` wrapping ``DefaultDoubleLSliderStyle``.
public struct DoubleLSliderStyleKey: EnvironmentKey {
    /// The default style used when no custom style is provided.
    ///
    /// Defaults to ``DefaultDoubleLSliderStyle``.
    public static let defaultValue: AnyDoubleLSliderStyle = AnyDoubleLSliderStyle(DefaultDoubleLSliderStyle())
}

extension EnvironmentValues {
    /// The current double linear slider style used by ``DoubleLSlider``.
    ///
    /// Set this value using ``SwiftUI/View/doubleLSliderStyle(_:)``.
    public var doubleLSliderStyle: AnyDoubleLSliderStyle {
        get { self[DoubleLSliderStyleKey.self] }
        set { self[DoubleLSliderStyleKey.self] = newValue }
    }
}

extension View {
    /// Sets the style for ``DoubleLSlider`` instances within this view hierarchy.
    ///
    /// - Parameter style: The style to apply. Must conform to ``DoubleLSliderStyle``.
    /// - Returns: A view that uses `style` to render any descendant ``DoubleLSlider``.
    public func doubleLSliderStyle<S: DoubleLSliderStyle>(_ style: S) -> some View {
        environment(\.doubleLSliderStyle, AnyDoubleLSliderStyle(style))
    }
}

// MARK: - Static Presets

public extension DoubleLSliderStyle where Self == DefaultDoubleLSliderStyle {
    /// The built-in default double linear slider style.
    static var `default`: DefaultDoubleLSliderStyle { DefaultDoubleLSliderStyle() }

    /// Returns the built-in default style with customisable colours and thickness.
    static func `default`(
        trackColor: Color = Color(.sRGB, red: 0.55, green: 0.55, blue: 0.59),
        trackFilledColor: Color = Color(.sRGB, red: 0.084, green: 0.247, blue: 0.602),
        lowerThumbColor: Color = Color(.sRGB, red: 0.204, green: 0.648, blue: 0.855),
        upperThumbColor: Color = Color(.sRGB, red: 0.204, green: 0.648, blue: 0.855),
        activeThumbColor: Color = Color.white,
        thumbDisabledColor: Color = Color(.sRGB, red: 0.75, green: 0.75, blue: 0.75),
        trackDisabledColor: Color = Color(.sRGB, red: 0.75, green: 0.75, blue: 0.75),
        trackThickness: Double = 20.0
    ) -> DefaultDoubleLSliderStyle {
        DefaultDoubleLSliderStyle(
            trackColor: trackColor,
            trackFilledColor: trackFilledColor,
            lowerThumbColor: lowerThumbColor,
            upperThumbColor: upperThumbColor,
            activeThumbColor: activeThumbColor,
            thumbDisabledColor: thumbDisabledColor,
            trackDisabledColor: trackDisabledColor,
            trackThickness: trackThickness
        )
    }
}

// MARK: - Default Style

/// The built-in default style for ``DoubleLSlider``.
///
/// Draws a rounded track with a filled portion between the two thumb positions and two circular
/// thumbs that highlight when active, matching the visual language of ``DefaultLSliderStyle``.
public struct DefaultDoubleLSliderStyle: DoubleLSliderStyle, Sendable {

    let trackColor: Color
    let trackFilledColor: Color
    let lowerThumbColor: Color
    let upperThumbColor: Color
    let activeThumbColor: Color
    let thumbDisabledColor: Color
    let trackDisabledColor: Color
    let trackThickness: Double

    /// Creates the default style with customisable colours and track thickness.
    ///
    /// - Parameters:
    ///   - trackColor: The colour of the unfilled track portion.
    ///   - trackFilledColor: The colour of the filled portion between the two thumbs.
    ///   - lowerThumbColor: The resting colour of the lower thumb.
    ///   - upperThumbColor: The resting colour of the upper thumb.
    ///   - activeThumbColor: The colour of a thumb (or both) while being dragged.
    ///   - thumbDisabledColor: The colour of a thumb when the slider is disabled.
    ///   - trackDisabledColor: The colour of the track when the slider is disabled.
    ///   - trackThickness: The thickness used when sizing the thumbs and track.
    public init(
        trackColor: Color = Color(.sRGB, red: 0.55, green: 0.55, blue: 0.59),
        trackFilledColor: Color = Color(.sRGB, red: 0.084, green: 0.247, blue: 0.602),
        lowerThumbColor: Color = Color(.sRGB, red: 0.204, green: 0.648, blue: 0.855),
        upperThumbColor: Color = Color(.sRGB, red: 0.204, green: 0.648, blue: 0.855),
        activeThumbColor: Color = Color.white,
        thumbDisabledColor: Color = Color(.sRGB, red: 0.75, green: 0.75, blue: 0.75),
        trackDisabledColor: Color = Color(.sRGB, red: 0.75, green: 0.75, blue: 0.75),
        trackThickness: Double = 20.0
    ) {
        self.trackColor = trackColor
        self.trackFilledColor = trackFilledColor
        self.lowerThumbColor = lowerThumbColor
        self.upperThumbColor = upperThumbColor
        self.activeThumbColor = activeThumbColor
        self.thumbDisabledColor = thumbDisabledColor
        self.trackDisabledColor = trackDisabledColor
        self.trackThickness = trackThickness
    }

    /// Creates the lower thumb: a circle that turns white while the user is dragging it (or the range),
    /// or grey when the slider is disabled.
    public func makeLowerThumb(configuration: DoubleLSliderConfiguration) -> some View {
        let isActive = configuration.isLowerActive || configuration.isRangeActive
        let color: Color = configuration.isDisabled
            ? lowerThumbColor.mix(with: thumbDisabledColor, by: 0.5)
            : (isActive ? activeThumbColor : lowerThumbColor)
        return Circle()
            .fill(color)
            .frame(width: trackThickness * 2, height: trackThickness * 2)
            .shadow(color: Color.black.opacity(configuration.isDisabled ? 0.0 : 0.2), radius: isActive ? 5 : 2)
    }

    /// Creates the upper thumb: a circle that turns white while the user is dragging it (or the range),
    /// or grey when the slider is disabled.
    public func makeUpperThumb(configuration: DoubleLSliderConfiguration) -> some View {
        let isActive = configuration.isUpperActive || configuration.isRangeActive
        let color: Color = configuration.isDisabled
            ? upperThumbColor.mix(with: thumbDisabledColor, by: 0.5)
            : (isActive ? activeThumbColor : upperThumbColor)
        return Circle()
            .fill(color)
            .frame(width: trackThickness * 2, height: trackThickness * 2)
            .shadow(color: Color.black.opacity(configuration.isDisabled ? 0.0 : 0.2), radius: isActive ? 5 : 2)
    }

    /// Creates the track: a rounded capsule with a filled portion spanning the lower to upper value.
    /// When disabled, the filled portion uses `trackDisabledColor`.
    public func makeTrack(configuration: DoubleLSliderConfiguration) -> some View {
        let lo = configuration.lowerPercent
        let hi = configuration.upperPercent
        let filledColor = configuration.isDisabled ? trackDisabledColor : trackFilledColor

        return ZStack {
            AdaptiveLine(thickness: trackThickness, angle: configuration.angle)
                .fill(trackColor)

            AdaptiveLine(
                thickness: trackThickness,
                angle: configuration.angle,
                percentFilled: hi,
                adjustmentForThumb: configuration.keepThumbInTrack ? trackThickness * (1 - hi) : trackThickness / 2
            )
            .fill(filledColor)
            .mask(
                AdaptiveLine(
                    thickness: trackThickness,
                    angle: configuration.angle,
                    percentFilled: 1 - lo,
                    adjustmentForThumb: configuration.keepThumbInTrack ? trackThickness * lo : trackThickness / 2
                )
                .fill(Color.white)
                .rotationEffect(.degrees(180))
            )
            .mask(AdaptiveLine(thickness: trackThickness, angle: configuration.angle))
        }
        .opacity(configuration.isDisabled ? 0.5 : 1.0)
    }

    /// Creates a tick-mark indicator: a small circle that grows and brightens as either thumb approaches.
    public func makeTickMark(configuration: DoubleLSliderConfiguration, tickValue: Double) -> some View {
        let range = configuration.max - configuration.min
        guard range > 0 else {
            return AnyView(Circle().fill(Color.white.opacity(0.3)).frame(width: 6, height: 6))
        }
        let lowerPct = (configuration.lowerValue - configuration.min) / range
        let upperPct = (configuration.upperValue - configuration.min) / range
        let tickPct  = (tickValue - configuration.min) / range
        let proximityLower = max(0.0, 1.0 - abs(lowerPct - tickPct) / 0.20)
        let proximityUpper = max(0.0, 1.0 - abs(upperPct - tickPct) / 0.20)
        let proximity = max(proximityLower, proximityUpper)
        let size    = 5.0 + 7.0 * proximity
        let opacity = 0.30 + 0.70 * proximity
        return AnyView(
            Circle()
                .fill(Color.white.opacity(opacity))
                .frame(width: size, height: size)
                .animation(.easeOut(duration: 0.1), value: proximity)
        )
    }

    /// Creates the lower thumb label container: the lower value in a floating capsule.
    public func makeLowerLabel(configuration: DoubleLSliderConfiguration, content: AnyView) -> some View {
        let isActive = configuration.isLowerActive || configuration.isRangeActive
        return content
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .shadow(color: Color.black.opacity(0.15), radius: 2, y: 1)
            )
            .scaleEffect(isActive ? 1.0 : 0.8)
            .opacity(isActive ? 1.0 : 0.0)
            .animation(.easeOut(duration: 0.15), value: isActive)
    }

    /// Creates the upper thumb label container: the upper value in a floating capsule.
    public func makeUpperLabel(configuration: DoubleLSliderConfiguration, content: AnyView) -> some View {
        let isActive = configuration.isUpperActive || configuration.isRangeActive
        return content
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .shadow(color: Color.black.opacity(0.15), radius: 2, y: 1)
            )
            .scaleEffect(isActive ? 1.0 : 0.8)
            .opacity(isActive ? 1.0 : 0.0)
            .animation(.easeOut(duration: 0.15), value: isActive)
    }
}
