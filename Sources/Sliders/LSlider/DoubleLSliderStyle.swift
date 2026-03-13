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
    func makeLowerThumb(configuration: DoubleLSliderConfiguration) -> Self.LowerThumb

    /// Creates the upper (end) draggable thumb view.
    func makeUpperThumb(configuration: DoubleLSliderConfiguration) -> Self.UpperThumb

    /// Creates the track view, including the filled portion between the two thumbs.
    func makeTrack(configuration: DoubleLSliderConfiguration) -> Self.Track

    /// Creates the view rendered at a single tick-mark position.
    func makeTickMark(configuration: DoubleLSliderConfiguration, tickValue: Double) -> Self.TickMark

    /// Creates the styled container for the lower thumb label.
    func makeLowerLabel(configuration: DoubleLSliderConfiguration, content: AnyView) -> Self.LowerLabel

    /// Creates the styled container for the upper thumb label.
    func makeUpperLabel(configuration: DoubleLSliderConfiguration, content: AnyView) -> Self.UpperLabel
}

// MARK: - Default TickMark

public extension DoubleLSliderStyle {
    func makeLowerThumbTypeErased(configuration: DoubleLSliderConfiguration) -> AnyView {
        AnyView(self.makeLowerThumb(configuration: configuration))
    }
    func makeUpperThumbTypeErased(configuration: DoubleLSliderConfiguration) -> AnyView {
        AnyView(self.makeUpperThumb(configuration: configuration))
    }
    func makeTrackTypeErased(configuration: DoubleLSliderConfiguration) -> AnyView {
        AnyView(self.makeTrack(configuration: configuration))
    }
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
public struct AnyDoubleLSliderStyle: DoubleLSliderStyle, Sendable {
    private let _makeLowerThumb: @Sendable (DoubleLSliderConfiguration) -> AnyView
    private let _makeUpperThumb: @Sendable (DoubleLSliderConfiguration) -> AnyView
    private let _makeTrack: @Sendable (DoubleLSliderConfiguration) -> AnyView
    private let _makeTickMark: @Sendable (DoubleLSliderConfiguration, Double) -> AnyView
    private let _makeLowerLabel: @Sendable (DoubleLSliderConfiguration, AnyView) -> AnyView
    private let _makeUpperLabel: @Sendable (DoubleLSliderConfiguration, AnyView) -> AnyView

    public func makeLowerThumb(configuration: DoubleLSliderConfiguration) -> some View {
        _makeLowerThumb(configuration)
    }
    public func makeUpperThumb(configuration: DoubleLSliderConfiguration) -> some View {
        _makeUpperThumb(configuration)
    }
    public func makeTrack(configuration: DoubleLSliderConfiguration) -> some View {
        _makeTrack(configuration)
    }
    public func makeTickMark(configuration: DoubleLSliderConfiguration, tickValue: Double) -> some View {
        _makeTickMark(configuration, tickValue)
    }
    public func makeLowerLabel(configuration: DoubleLSliderConfiguration, content: AnyView) -> some View {
        _makeLowerLabel(configuration, content)
    }
    public func makeUpperLabel(configuration: DoubleLSliderConfiguration, content: AnyView) -> some View {
        _makeUpperLabel(configuration, content)
    }

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
public struct DoubleLSliderStyleKey: EnvironmentKey {
    public static let defaultValue: AnyDoubleLSliderStyle = AnyDoubleLSliderStyle(DefaultDoubleLSliderStyle())
}

extension EnvironmentValues {
    /// The current double linear slider style used by ``DoubleLSlider``.
    public var doubleLSliderStyle: AnyDoubleLSliderStyle {
        get { self[DoubleLSliderStyleKey.self] }
        set { self[DoubleLSliderStyleKey.self] = newValue }
    }
}

extension View {
    /// Sets the style for ``DoubleLSlider`` instances within this view hierarchy.
    public func doubleLSliderStyle<S: DoubleLSliderStyle>(_ style: S) -> some View {
        environment(\.doubleLSliderStyle, AnyDoubleLSliderStyle(style))
    }
}

// MARK: - Static Presets

public extension DoubleLSliderStyle where Self == DefaultDoubleLSliderStyle {
    /// The built-in default double linear slider style.
    static var `default`: DefaultDoubleLSliderStyle { DefaultDoubleLSliderStyle() }

    /// The built-in default double linear slider style with customisable parameters.
    static func `default`(
        trackColor: Color = Color(.sRGB, red: 0.55, green: 0.55, blue: 0.59),
        trackFilledColor: Color = Color(.sRGB, red: 0.084, green: 0.247, blue: 0.602),
        lowerThumbColor: Color = Color(.sRGB, red: 0.204, green: 0.648, blue: 0.855),
        upperThumbColor: Color = Color(.sRGB, red: 0.204, green: 0.648, blue: 0.855),
        activeThumbColor: Color = Color.white,
        trackThickness: Double = 20.0
    ) -> DefaultDoubleLSliderStyle {
        DefaultDoubleLSliderStyle(
            trackColor: trackColor,
            trackFilledColor: trackFilledColor,
            lowerThumbColor: lowerThumbColor,
            upperThumbColor: upperThumbColor,
            activeThumbColor: activeThumbColor,
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
    let trackThickness: Double

    public init(
        trackColor: Color = Color(.sRGB, red: 0.55, green: 0.55, blue: 0.59),
        trackFilledColor: Color = Color(.sRGB, red: 0.084, green: 0.247, blue: 0.602),
        lowerThumbColor: Color = Color(.sRGB, red: 0.204, green: 0.648, blue: 0.855),
        upperThumbColor: Color = Color(.sRGB, red: 0.204, green: 0.648, blue: 0.855),
        activeThumbColor: Color = Color.white,
        trackThickness: Double = 20.0
    ) {
        self.trackColor = trackColor
        self.trackFilledColor = trackFilledColor
        self.lowerThumbColor = lowerThumbColor
        self.upperThumbColor = upperThumbColor
        self.activeThumbColor = activeThumbColor
        self.trackThickness = trackThickness
    }

    public func makeLowerThumb(configuration: DoubleLSliderConfiguration) -> some View {
        let isActive = configuration.isLowerActive || configuration.isRangeActive
        return Circle()
            .fill(isActive ? activeThumbColor : lowerThumbColor)
            .frame(width: trackThickness * 2, height: trackThickness * 2)
            .shadow(color: Color.black.opacity(0.2), radius: isActive ? 5 : 2)
    }

    public func makeUpperThumb(configuration: DoubleLSliderConfiguration) -> some View {
        let isActive = configuration.isUpperActive || configuration.isRangeActive
        return Circle()
            .fill(isActive ? activeThumbColor : upperThumbColor)
            .frame(width: trackThickness * 2, height: trackThickness * 2)
            .shadow(color: Color.black.opacity(0.2), radius: isActive ? 5 : 2)
    }

    public func makeTrack(configuration: DoubleLSliderConfiguration) -> some View {
        let lo = configuration.lowerPercent
        let hi = configuration.upperPercent

        // The active-range fill is inset by half a thumb width on each side so it
        // visually sits between the thumb centres (matching LSlider's behaviour).
        let thumbAdjustment: Double = configuration.keepThumbInTrack
            ? trackThickness * (1 - hi)  // same idea as DefaultLSliderStyle for the end cap
            : trackThickness / 2

        let _ = thumbAdjustment // used below in AdaptiveLine

        return ZStack {
            // Full unfilled track
            AdaptiveLine(thickness: trackThickness, angle: configuration.angle)
                .fill(trackColor)

            // Filled portion: draw from lowerPercent to upperPercent.
            // We achieve this by drawing a filled segment of length (hi - lo) starting at lo.
            // AdaptiveLine draws from one end; we rotate 180° and use (1 - hi) as the start
            // offset. Simpler: use two masks.
            //
            // Approach: use a clip mask that keeps only the [lo, hi] window.
            AdaptiveLine(
                thickness: trackThickness,
                angle: configuration.angle,
                percentFilled: hi,
                adjustmentForThumb: configuration.keepThumbInTrack ? trackThickness * (1 - hi) : trackThickness / 2
            )
            .fill(trackFilledColor)
            // Clip off the [0, lo] portion by overlaying the background colour.
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
    }

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
