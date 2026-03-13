// Swift toolchain version 6.0
// Running macOS version 26.3
// Created on 3/12/26.
//
// Author: Kieran Brown
//

import SwiftUI

// MARK: - Configuration

/// A value type describing the current state of an ``RSlider``.
///
/// Styles receive an instance of `RSliderConfiguration` when creating the thumb, track, and
/// tick marks. Most styles will use `value`, `percent`, `angle`, and `isActive`.
///
/// ## Winds
/// When `maxWinds` is greater than `1`, the slider’s full value range spans multiple rotations.
/// Use `currentWind` and `withinWind` to render progress for the current rotation.
///
/// ## Tick marks and affinity
/// When tick marks are enabled, `tickValues` contains the resolved values that will be rendered.
/// If affinity is enabled, `snappedTickValue` is the tick the thumb is currently snapped to.
public struct RSliderConfiguration {
    /// Whether the slider is currently disabled.
    public let isDisabled: Bool
    /// Whether the user is actively dragging the thumb.
    public let isActive: Bool
    /// The current value of the slider.
    public let value: Double
    /// The direction from the thumb to the slider’s center.
    ///
    /// Styles typically use this for thumb placement/orientation.
    public let angle: Angle
    /// The angle on the slider that corresponds to the minimum value.
    public let originAngle: Angle
    /// The minimum value of the slider’s range.
    public let min: Double
    /// The maximum value of the slider’s range.
    public let max: Double
    /// The fractional component within the current wind.
    ///
    /// This value is in the range `[0, 1)` when `maxWinds` is positive.
    public let withinWind: Double
    /// The current number of full rotations completed.
    public let currentWind: Double
    /// The maximum number of winds the slider spans.
    public let maxWinds: Double
    /// How tick marks are spaced, or `nil` if tick marks are disabled.
    public let tickMarkSpacing: TickMarkSpacing?
    /// The resolved list of tick-mark values computed from `tickMarkSpacing`.
    public let tickValues: [Double]
    /// Whether tick-mark affinity (magnetic snap) is enabled.
    public let affinityEnabled: Bool
    /// The tick-mark value the thumb is currently snapped to, or `nil` when not snapped.
    public let snappedTickValue: Double?

    /// The slider’s normalized value in the range `0...1`.
    ///
    /// - Important: If `min == max`, this will divide by zero. ``RSlider`` is designed for
    ///   non-empty ranges.
    public var percent: Double {
        (value - min) / (max - min)
    }
}

// MARK: - Style

/// A style that defines the appearance of an ``RSlider``.
///
/// Conform to `RSliderStyle` to provide a custom thumb and track for the radial slider.
/// Tick marks are optional.
///
/// Apply a style using ``SwiftUI/View/radialSliderStyle(_:)``.
public protocol RSliderStyle: Sendable {
    /// The view used for the draggable thumb.
    associatedtype Thumb: View
    /// The view used for the slider track.
    associatedtype Track: View
    /// The view used for each tick mark.
    associatedtype TickMark: View
    /// The view used as a styled label container.
    associatedtype LabelContainer: View

    /// Creates the draggable thumb.
    /// - Parameter configuration: The current slider state.
    func makeThumb(configuration: RSliderConfiguration) -> Self.Thumb

    /// Creates the track behind the thumb.
    /// - Parameter configuration: The current slider state.
    func makeTrack(configuration: RSliderConfiguration) -> Self.Track

    /// Creates the view shown for a single tick mark.
    ///
    /// ``RSlider`` calls this once for each value in `configuration.tickValues`.
    /// - Parameters:
    ///   - configuration: The current slider state.
    ///   - tickValue: The value (in the slider’s domain) at which this tick mark sits.
    func makeTickMark(configuration: RSliderConfiguration, tickValue: Double) -> Self.TickMark

    /// Creates the styled container for a thumb label.
    func makeLabel(configuration: RSliderConfiguration, content: AnyView) -> Self.LabelContainer
}

// MARK: - SwiftUI-style presets

public extension RSliderStyle where Self == DefaultRSliderStyle {
    /// The built-in default radial slider style.
    static var `default`: DefaultRSliderStyle { DefaultRSliderStyle() }

    /// The built-in default radial slider style, with customizable parameters.
    ///
    /// Usage:
    /// `RSlider($value).radialSliderStyle(.default(trackThickness: 18))`
    static func `default`(
        trackColor: Color = Color(red: 0.55, green: 0.55, blue: 0.59),
        trackFilledColor: Color = Color(red: 0.084, green: 0.247, blue: 0.602),
        thumbInactiveColor: Color = Color.white,
        thumbActiveColor: Color = Color(red: 0.204, green: 0.648, blue: 0.855),
        thumbDisabledColor: Color = Color(.sRGB, red: 0.75, green: 0.75, blue: 0.75),
        trackDisabledColor: Color = Color(.sRGB, red: 0.75, green: 0.75, blue: 0.75),
        trackThickness: Double = 24.0
    ) -> DefaultRSliderStyle {
        DefaultRSliderStyle(
            trackColor: trackColor,
            trackFilledColor: trackFilledColor,
            thumbInactiveColor: thumbInactiveColor,
            thumbActiveColor: thumbActiveColor,
            thumbDisabledColor: thumbDisabledColor,
            trackDisabledColor: trackDisabledColor,
            trackThickness: trackThickness
        )
    }
}

public extension RSliderStyle where Self == KnobStyle {
    /// A knob-style radial slider.
    ///
    /// Usage:
    /// `RSlider($value).radialSliderStyle(.knob)`
    ///
    /// Or with customization:
    /// `RSlider($value).radialSliderStyle(.knob(thumbSize: 26))`
    static func knob(
        backgroundColor: Color = Color(red: 0, green: 0.1148955151, blue: 0.3572945595),
        strokeColor: Color = Color.white,
        thumbColor: Color = Color.white,
        thumbSize: Double = 30,
        thumbInset: Double = 30
    ) -> KnobStyle {
        KnobStyle(
            backgroundColor: backgroundColor,
            strokeColor: strokeColor,
            thumbColor: thumbColor,
            thumbSize: thumbSize,
            thumbInset: thumbInset
        )
    }

    /// The knob preset with default parameters.
    static var knob: KnobStyle { KnobStyle() }
}

public extension RSliderStyle {
    func makeThumbTypeErased(configuration: RSliderConfiguration) -> AnyView {
        AnyView(self.makeThumb(configuration: configuration))
    }
    func makeTrackTypeErased(configuration: RSliderConfiguration) -> AnyView {
        AnyView(self.makeTrack(configuration: configuration))
    }
    func makeTickMarkTypeErased(configuration: RSliderConfiguration, tickValue: Double) -> AnyView {
        AnyView(self.makeTickMark(configuration: configuration, tickValue: tickValue))
    }
    func makeLabelTypeErased(configuration: RSliderConfiguration, content: AnyView) -> AnyView {
        AnyView(self.makeLabel(configuration: configuration, content: content))
    }
    
    /// Default tick mark: a small white circle that brightens near the thumb.
    func makeTickMark(configuration: RSliderConfiguration, tickValue: Double) -> some View {
        let range = configuration.max - configuration.min
        let thumbPct = range > 0 ? (configuration.value - configuration.min) / range : 0
        let tickPct  = range > 0 ? (tickValue          - configuration.min) / range : 0
        let proximity = max(0, 1 - abs(thumbPct - tickPct) / 0.20)
        let size    = 4.0 + 6.0 * proximity
        let opacity = 0.35 + 0.65 * proximity
        return Circle()
            .fill(Color.white.opacity(opacity))
            .frame(width: size, height: size)
            .animation(.easeOut(duration: 0.1), value: proximity)
    }
    
    /// Default label: the current value in a floating capsule.
    func makeLabel(configuration: RSliderConfiguration, content: AnyView) -> some View {
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

/// A type-erased radix slider style.
///
/// This is used to store an `RSliderStyle` in the SwiftUI environment.
public struct AnyRSliderStyle: RSliderStyle, Sendable {
    private let _makeThumb: @Sendable (RSliderConfiguration) -> AnyView
    private let _makeTrack: @Sendable (RSliderConfiguration) -> AnyView
    private let _makeTickMark: @Sendable (RSliderConfiguration, Double) -> AnyView
    private let _makeLabel: @Sendable (RSliderConfiguration, AnyView) -> AnyView
    
    public func makeThumb(configuration: RSliderConfiguration) -> some View {
        _makeThumb(configuration)
    }
    
    public func makeTrack(configuration: RSliderConfiguration) -> some View {
        _makeTrack(configuration)
    }
    
    public func makeTickMark(configuration: RSliderConfiguration, tickValue: Double) -> some View {
        _makeTickMark(configuration, tickValue)
    }

    public func makeLabel(configuration: RSliderConfiguration, content: AnyView) -> some View {
        _makeLabel(configuration, content)
    }
    
    /// Creates an environment-storable wrapper around `style`.
    public init<S: RSliderStyle>(_ style: S) {
        self._makeThumb = style.makeThumbTypeErased
        self._makeTrack = style.makeTrackTypeErased
        self._makeTickMark = style.makeTickMarkTypeErased
        self._makeLabel = style.makeLabelTypeErased
    }
}

/// The environment key used by ``AnyRSliderStyle``.
public struct RSliderStyleKey: EnvironmentKey {
    /// The default style used when no custom style is provided.
    public static let defaultValue: AnyRSliderStyle = AnyRSliderStyle(DefaultRSliderStyle())
}

extension EnvironmentValues {
    /// The current radial slider style stored in the environment.
    public var radialSliderStyle: AnyRSliderStyle {
        get {
            return self[RSliderStyleKey.self]
        }
        set {
            self[RSliderStyleKey.self] = newValue
        }
    }
}

extension View {
    /// Sets the style for ``RSlider`` instances within this view.
    ///
    /// This works like other SwiftUI style modifiers (for example, `buttonStyle(_:)`).
    public func radialSliderStyle<S>(_ style: S) -> some View where S: RSliderStyle {
        environment(\.radialSliderStyle, AnyRSliderStyle(style))
    }
}

// MARK: - Default Style

/// The built-in default style for ``RSlider``.
///
/// This style draws a circular track with a filled arc and a circular thumb.
public struct DefaultRSliderStyle: RSliderStyle, Sendable {
    
    let trackColor: Color
    let trackFilledColor: Color
    let thumbInactiveColor: Color
    let thumbActiveColor: Color
    let thumbDisabledColor: Color
    let trackDisabledColor: Color
    let trackThickness: Double
    
    /// Creates the default style with customizable colors and track thickness.
    /// - Parameter trackThickness: The stroke width of the circular track.
    public init(
        trackColor: Color = Color(red: 0.55, green: 0.55, blue: 0.59),
        trackFilledColor: Color = Color(red: 0.084, green: 0.247, blue: 0.602),
        thumbInactiveColor: Color = Color.white,
        thumbActiveColor: Color = Color(red: 0.204, green: 0.648, blue: 0.855),
        thumbDisabledColor: Color = Color(.sRGB, red: 0.75, green: 0.75, blue: 0.75),
        trackDisabledColor: Color = Color(.sRGB, red: 0.75, green: 0.75, blue: 0.75),
        trackThickness: Double = 24.0
    ) {
        self.trackColor = trackColor
        self.trackFilledColor = trackFilledColor
        self.thumbInactiveColor = thumbInactiveColor
        self.thumbActiveColor = thumbActiveColor
        self.thumbDisabledColor = thumbDisabledColor
        self.trackDisabledColor = trackDisabledColor
        self.trackThickness = trackThickness
    }
    
    public func makeThumb(configuration: RSliderConfiguration) -> some View {
        let color: Color = configuration.isDisabled
            ? thumbInactiveColor.mix(with: thumbDisabledColor, by: 0.5)
            : (configuration.isActive ? thumbInactiveColor : thumbActiveColor)
        return Circle()
            .fill(color)
            .frame(width: trackThickness * 2, height: trackThickness * 2)
            .shadow(
                color: Color.black.opacity(configuration.isDisabled ? 0.0 : 0.2),
                radius: configuration.isActive ? 5 : 2
            )
            .offset(x: -trackThickness * cos(configuration.angle.radians),
                    y: -trackThickness * sin(configuration.angle.radians))
    }
    
    public func makeTrack(configuration: RSliderConfiguration) -> some View {
        let filledColor = configuration.isDisabled ? trackDisabledColor : trackFilledColor
        return ZStack {
            Circle()
                .strokeBorder(trackColor, lineWidth: trackThickness)
            
            if configuration.maxWinds > 1 {
                ForEach(0..<Int(configuration.maxWinds), id: \.self) { wind in
                    CircularArc(
                        percent: configuration.percent == 1 && configuration.maxWinds >= 1 || configuration.currentWind > Double(wind)
                        ? 1.0
                        : configuration.withinWind
                    )
                    .strokeBorder(filledColor.mix(with: Color.black.opacity(0.2), by: Double(wind)/configuration.maxWinds), lineWidth: trackThickness)
                    .rotationEffect(configuration.originAngle)
                }
            } else {
                CircularArc(
                    percent: configuration.percent == 1 && configuration.maxWinds >= 1
                    ? 1.0
                    : configuration.withinWind
                )
                .strokeBorder(filledColor, lineWidth: trackThickness)
                .rotationEffect(configuration.originAngle)
            }

        }
        .padding(trackThickness / 2)
        .opacity(configuration.isDisabled ? 0.5 : 1.0)
    }
    
    /// A small circle that grows and brightens as the thumb approaches this tick mark.
    public func makeTickMark(configuration: RSliderConfiguration, tickValue: Double) -> some View {
        let range = configuration.max - configuration.min
        guard range > 0 else {
            return AnyView(Circle().fill(Color.white.opacity(0.3)).frame(width: 5, height: 5))
        }
        let thumbPct = (configuration.value - configuration.min) / range
        let tickPct  = (tickValue          - configuration.min) / range
        let distance = abs(thumbPct - tickPct)
        let proximity = max(0, 1 - distance / 0.20)
        
        let baseSize:  Double = 4
        let maxGrowth: Double = 6
        let size = baseSize + maxGrowth * proximity
        
        let baseOpacity:  Double = 0.35
        let maxOpacity:   Double = 1.00
        let opacity = baseOpacity + (maxOpacity - baseOpacity) * proximity
        
        return AnyView(
            Circle()
                .fill(Color.white.opacity(opacity))
                .frame(width: size, height: size)
                .animation(.easeOut(duration: 0.1), value: proximity)
        )
    }
}

// MARK: - Knob Style

/// A knob-like ``RSliderStyle`` with a circular face and a pointer indicator.
///
/// - Note: This style currently returns `EmptyView` for tick marks.
public struct KnobStyle: RSliderStyle, Sendable {
    let backgroundColor: Color
    let strokeColor: Color
    let thumbColor: Color
    let thumbSize: Double
    let thumbInset: Double
    
    /// Creates a knob style.
    ///
    /// - Parameters:
    ///   - backgroundColor: The knob face fill color.
    ///   - strokeColor: The dashed stroke color around the face.
    ///   - thumbColor: The thumb fill color.
    ///   - thumbSize: The thumb circle diameter.
    ///   - thumbInset: How far the thumb is inset toward the center.
    public init(
        backgroundColor: Color = Color(red: 0, green: 0.1148955151, blue: 0.3572945595),
        strokeColor: Color = Color.white,
        thumbColor: Color = Color.white,
        thumbSize: Double = 30,
        thumbInset: Double = 30
    ) {
        self.backgroundColor = backgroundColor
        self.strokeColor = strokeColor
        self.thumbColor = thumbColor
        self.thumbSize = thumbSize
        self.thumbInset = thumbInset
    }
    
    public func makeThumb(configuration: RSliderConfiguration) -> some View {
        return Circle()
            .fill(thumbColor)
            .frame(width: thumbSize)
            .shadow(radius: 1)
            .overlay(
                Image(systemName: "triangle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(backgroundColor)
                    .padding(.horizontal, 4)
                    .offset(y: -2)
                    .rotationEffect(
                        configuration.angle + configuration.originAngle + .degrees(90)
                    )
            )
            .offset(
                x: -thumbInset * cos(configuration.angle.radians),
                y: -thumbInset * sin(configuration.angle.radians)
            )
    }
    
    public func makeTrack(configuration: RSliderConfiguration) -> some View {
        return Circle()
            .foregroundStyle(backgroundColor)
            .overlay(
                Circle()
                    .strokeBorder(
                        strokeColor,
                        style: StrokeStyle(lineWidth: 1, dash: [3,3])
                    )
                    .rotationEffect(configuration.angle)
            )
    }
    
    /// Returns an empty view (tick marks aren’t rendered by this style).
    public func makeTickMark(configuration: RSliderConfiguration, tickValue: Double) -> some View {
        EmptyView()
    }
}
