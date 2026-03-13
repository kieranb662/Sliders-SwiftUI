// Swift toolchain version 6.0
// Running macOS version 26.3
// Created on 3/13/26.
//
// Author: Kieran Brown
//

import SwiftUI

// MARK: - Configuration

/// A value type describing the current state of a ``DoubleRSlider``.
///
/// Styles receive an instance of `DoubleRSliderConfiguration` when creating the thumbs, track, and
/// tick marks. Most styles will use `lowerValue`, `upperValue`, `lowerAngle`, `upperAngle`,
/// `isLowerActive`, `isUpperActive`, and `isRangeActive`.
public struct DoubleRSliderConfiguration {
    /// Whether the slider is currently disabled.
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
    /// The angle on the circle that corresponds to `lowerValue`.
    public let lowerAngle: Angle
    /// The angle on the circle that corresponds to `upperValue`.
    public let upperAngle: Angle
    /// The angle on the slider that corresponds to the minimum value.
    public let originAngle: Angle
    /// The minimum value of the slider's range.
    public let min: Double
    /// The maximum value of the slider's range.
    public let max: Double
    /// How tick marks are spaced, or `nil` if tick marks are disabled.
    public let tickMarkSpacing: TickMarkSpacing?
    /// The resolved list of tick-mark values computed from `tickMarkSpacing`.
    public let tickValues: [Double]
    /// Whether tick-mark affinity (magnetic snap) is enabled.
    public let affinityEnabled: Bool
    /// The tick-mark value the lower thumb is currently snapped to, or `nil` when not snapped.
    public let snappedLowerTickValue: Double?
    /// The tick-mark value the upper thumb is currently snapped to, or `nil` when not snapped.
    public let snappedUpperTickValue: Double?

    /// The lower value normalized to the range `0...1`.
    public var lowerPercent: Double {
        guard max > min else { return 0 }
        return (lowerValue - min) / (max - min)
    }

    /// The upper value normalized to the range `0...1`.
    public var upperPercent: Double {
        guard max > min else { return 0 }
        return (upperValue - min) / (max - min)
    }
}

// MARK: - Style Protocol

/// A style that defines the appearance of a ``DoubleRSlider``.
///
/// Conform to `DoubleRSliderStyle` to provide custom thumbs, a track, and optional tick marks.
/// Apply a style using ``SwiftUI/View/doubleRadialSliderStyle(_:)``.
public protocol DoubleRSliderStyle: Sendable {
    /// The view used for the lower (start) draggable thumb.
    associatedtype LowerThumb: View
    /// The view used for the upper (end) draggable thumb.
    associatedtype UpperThumb: View
    /// The view used for the slider track.
    associatedtype Track: View
    /// The view used for each tick mark.
    associatedtype TickMark: View

    /// Creates the lower (start) draggable thumb.
    func makeLowerThumb(configuration: DoubleRSliderConfiguration) -> Self.LowerThumb

    /// Creates the upper (end) draggable thumb.
    func makeUpperThumb(configuration: DoubleRSliderConfiguration) -> Self.UpperThumb

    /// Creates the track behind the thumbs.
    ///
    /// The track is expected to visually represent the full range as well as the filled arc
    /// between `lowerAngle` and `upperAngle`.
    func makeTrack(configuration: DoubleRSliderConfiguration) -> Self.Track

    /// Creates the view shown for a single tick mark.
    func makeTickMark(configuration: DoubleRSliderConfiguration, tickValue: Double) -> Self.TickMark
}

// MARK: - Default tick mark

public extension DoubleRSliderStyle {
    func makeTickMarkTypeErased(configuration: DoubleRSliderConfiguration, tickValue: Double) -> AnyView {
        AnyView(self.makeTickMark(configuration: configuration, tickValue: tickValue))
    }
    func makeLowerThumbTypeErased(configuration: DoubleRSliderConfiguration) -> AnyView {
        AnyView(self.makeLowerThumb(configuration: configuration))
    }
    func makeUpperThumbTypeErased(configuration: DoubleRSliderConfiguration) -> AnyView {
        AnyView(self.makeUpperThumb(configuration: configuration))
    }
    func makeTrackTypeErased(configuration: DoubleRSliderConfiguration) -> AnyView {
        AnyView(self.makeTrack(configuration: configuration))
    }

    /// Default tick mark: a small white circle.
    func makeTickMark(configuration: DoubleRSliderConfiguration, tickValue: Double) -> some View {
        let range = configuration.max - configuration.min
        let lowerPct = range > 0 ? (configuration.lowerValue - configuration.min) / range : 0
        let upperPct = range > 0 ? (configuration.upperValue - configuration.min) / range : 0
        let tickPct  = range > 0 ? (tickValue - configuration.min) / range : 0
        let proximityLower = max(0, 1 - abs(lowerPct - tickPct) / 0.20)
        let proximityUpper = max(0, 1 - abs(upperPct - tickPct) / 0.20)
        let proximity = max(proximityLower, proximityUpper)
        let size    = 4.0 + 6.0 * proximity
        let opacity = 0.35 + 0.65 * proximity
        return Circle()
            .fill(Color.white.opacity(opacity))
            .frame(width: size, height: size)
            .animation(.easeOut(duration: 0.1), value: proximity)
    }
}

// MARK: - Type-Eraser

/// A type-erased double radial slider style.
public struct AnyDoubleRSliderStyle: DoubleRSliderStyle, Sendable {
    private let _makeLowerThumb: @Sendable (DoubleRSliderConfiguration) -> AnyView
    private let _makeUpperThumb: @Sendable (DoubleRSliderConfiguration) -> AnyView
    private let _makeTrack: @Sendable (DoubleRSliderConfiguration) -> AnyView
    private let _makeTickMark: @Sendable (DoubleRSliderConfiguration, Double) -> AnyView

    public func makeLowerThumb(configuration: DoubleRSliderConfiguration) -> some View {
        _makeLowerThumb(configuration)
    }
    public func makeUpperThumb(configuration: DoubleRSliderConfiguration) -> some View {
        _makeUpperThumb(configuration)
    }
    public func makeTrack(configuration: DoubleRSliderConfiguration) -> some View {
        _makeTrack(configuration)
    }
    public func makeTickMark(configuration: DoubleRSliderConfiguration, tickValue: Double) -> some View {
        _makeTickMark(configuration, tickValue)
    }

    public init<S: DoubleRSliderStyle>(_ style: S) {
        self._makeLowerThumb = style.makeLowerThumbTypeErased
        self._makeUpperThumb = style.makeUpperThumbTypeErased
        self._makeTrack = style.makeTrackTypeErased
        self._makeTickMark = style.makeTickMarkTypeErased
    }
}

// MARK: - Environment

/// The environment key used by ``AnyDoubleRSliderStyle``.
public struct DoubleRSliderStyleKey: EnvironmentKey {
    public static let defaultValue: AnyDoubleRSliderStyle = AnyDoubleRSliderStyle(DefaultDoubleRSliderStyle())
}

extension EnvironmentValues {
    /// The current double radial slider style stored in the environment.
    public var doubleRadialSliderStyle: AnyDoubleRSliderStyle {
        get { self[DoubleRSliderStyleKey.self] }
        set { self[DoubleRSliderStyleKey.self] = newValue }
    }
}

extension View {
    /// Sets the style for ``DoubleRSlider`` instances within this view.
    public func doubleRadialSliderStyle<S>(_ style: S) -> some View where S: DoubleRSliderStyle {
        environment(\.doubleRadialSliderStyle, AnyDoubleRSliderStyle(style))
    }
}

// MARK: - Static Presets

public extension DoubleRSliderStyle where Self == DefaultDoubleRSliderStyle {
    /// The built-in default double radial slider style.
    static var `default`: DefaultDoubleRSliderStyle { DefaultDoubleRSliderStyle() }

    /// The built-in default double radial slider style with customisable parameters.
    static func `default`(
        trackColor: Color = Color(red: 0.55, green: 0.55, blue: 0.59),
        trackFilledColor: Color = Color(red: 0.084, green: 0.247, blue: 0.602),
        lowerThumbColor: Color = Color.white,
        upperThumbColor: Color = Color.white,
        activeThumbColor: Color = Color(red: 0.204, green: 0.648, blue: 0.855),
        trackThickness: Double = 24.0
    ) -> DefaultDoubleRSliderStyle {
        DefaultDoubleRSliderStyle(
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

/// The built-in default style for ``DoubleRSlider``.
///
/// Draws a full circular track with a filled arc between the two thumbs and two circular thumbs.
public struct DefaultDoubleRSliderStyle: DoubleRSliderStyle, Sendable {

    let trackColor: Color
    let trackFilledColor: Color
    let lowerThumbColor: Color
    let upperThumbColor: Color
    let activeThumbColor: Color
    let trackThickness: Double

    public init(
        trackColor: Color = Color(red: 0.55, green: 0.55, blue: 0.59),
        trackFilledColor: Color = Color(red: 0.084, green: 0.247, blue: 0.602),
        lowerThumbColor: Color = Color.white,
        upperThumbColor: Color = Color.white,
        activeThumbColor: Color = Color(red: 0.204, green: 0.648, blue: 0.855),
        trackThickness: Double = 24.0
    ) {
        self.trackColor = trackColor
        self.trackFilledColor = trackFilledColor
        self.lowerThumbColor = lowerThumbColor
        self.upperThumbColor = upperThumbColor
        self.activeThumbColor = activeThumbColor
        self.trackThickness = trackThickness
    }

    public func makeLowerThumb(configuration: DoubleRSliderConfiguration) -> some View {
        let isActive = configuration.isLowerActive || configuration.isRangeActive
        return Circle()
            .fill(isActive ? activeThumbColor : lowerThumbColor)
            .frame(width: trackThickness * 2, height: trackThickness * 2)
            .shadow(color: Color.black.opacity(0.2), radius: isActive ? 5 : 2)
            .offset(x: -trackThickness * cos(configuration.lowerAngle.radians),
                    y: -trackThickness * sin(configuration.lowerAngle.radians))
    }

    public func makeUpperThumb(configuration: DoubleRSliderConfiguration) -> some View {
        let isActive = configuration.isUpperActive || configuration.isRangeActive
        return Circle()
            .fill(isActive ? activeThumbColor : upperThumbColor)
            .frame(width: trackThickness * 2, height: trackThickness * 2)
            .shadow(color: Color.black.opacity(0.2), radius: isActive ? 5 : 2)
            .offset(x: -trackThickness * cos(configuration.upperAngle.radians),
                    y: -trackThickness * sin(configuration.upperAngle.radians))
    }

    public func makeTrack(configuration: DoubleRSliderConfiguration) -> some View {
        let loPct = configuration.lowerPercent
        let hiPct = configuration.upperPercent

        // We draw the filled arc from lowerAngle to upperAngle.
        // CircularArc draws from 0 → percent. To draw from loPct → hiPct we:
        //   • rotate the whole shape by loPct * 360°
        //   • trim to (hiPct - loPct)
        let arcLength = hiPct - loPct

        return ZStack {
            // Full unfilled track
            Circle()
                .strokeBorder(trackColor, lineWidth: trackThickness)

            // Filled arc between lower and upper
            CircularArc(percent: arcLength)
                .strokeBorder(trackFilledColor, lineWidth: trackThickness)
                .rotationEffect(configuration.lowerAngle)
        }
        .padding(trackThickness / 2)
    }

    public func makeTickMark(configuration: DoubleRSliderConfiguration, tickValue: Double) -> some View {
        let range = configuration.max - configuration.min
        guard range > 0 else {
            return AnyView(Circle().fill(Color.white.opacity(0.3)).frame(width: 5, height: 5))
        }
        let lowerPct = (configuration.lowerValue - configuration.min) / range
        let upperPct = (configuration.upperValue - configuration.min) / range
        let tickPct  = (tickValue - configuration.min) / range
        let proximityLower = max(0, 1 - abs(lowerPct - tickPct) / 0.20)
        let proximityUpper = max(0, 1 - abs(upperPct - tickPct) / 0.20)
        let proximity = max(proximityLower, proximityUpper)
        let size = 4.0 + 6.0 * proximity
        let opacity = 0.35 + (1.0 - 0.35) * proximity
        return AnyView(
            Circle()
                .fill(Color.white.opacity(opacity))
                .frame(width: size, height: size)
                .animation(.easeOut(duration: 0.1), value: proximity)
        )
    }
}
