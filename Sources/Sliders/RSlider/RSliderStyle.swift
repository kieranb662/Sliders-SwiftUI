// Swift toolchain version 6.0
// Running macOS version 26.3
// Created on 3/12/26.
//
// Author: Kieran Brown
//

import SwiftUI

// MARK: - Configuration

public struct RSliderConfiguration {
    /// whether or not the slider is current disabled
    public let isDisabled: Bool
    /// whether or not the thumb is dragging or not
    public let isActive: Bool
    /// The current value of the slider
    public let value: Double
    /// The direction from the thumb to the slider center
    public let angle: Angle
    /// The angle on the slider that corresponds to the minimum value
    public let originAngle: Angle
    /// The minimum value of the sliders range
    public let min: Double
    /// The maximum value of the sliders range
    public let max: Double
    /// The fractional component within the current wind
    public let withinWind: Double
    /// The current number of full rotations completed (fractional winds are possible)
    public let currentWind: Double
    /// The maximum number of winds the slider spans
    public let maxWinds: Double
    /// How tick marks are spaced, or `nil` if tick marks are disabled.
    public let tickMarkSpacing: TickMarkSpacing?
    /// The resolved list of tick-mark values computed from `tickMarkSpacing`.
    public let tickValues: [Double]
    /// Whether tick-mark affinity (magnetic snap) is enabled.
    public let affinityEnabled: Bool
    /// The tick-mark value the thumb is currently snapped to, or `nil` when not snapped.
    public let snappedTickValue: Double?
    /// The current percent of total value
    public var percent: Double {
        (value - min) / (max - min)
    }
}

// MARK: - Style

public protocol RSliderStyle: Sendable {
    associatedtype Thumb: View
    associatedtype Track: View
    associatedtype TickMark: View
    
    func makeThumb(configuration: RSliderConfiguration) -> Self.Thumb
    func makeTrack(configuration: RSliderConfiguration) -> Self.Track
    /// Returns the view displayed at a single tick mark position around the radial track.
    /// - Parameters:
    ///   - configuration: The current slider configuration.
    ///   - tickValue: The value (in the slider's domain) at which this tick mark sits.
    func makeTickMark(configuration: RSliderConfiguration, tickValue: Double) -> Self.TickMark
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
}

public struct AnyRSliderStyle: RSliderStyle, Sendable {
    private let _makeThumb: @Sendable (RSliderConfiguration) -> AnyView
    private let _makeTrack: @Sendable (RSliderConfiguration) -> AnyView
    private let _makeTickMark: @Sendable (RSliderConfiguration, Double) -> AnyView
    
    public func makeThumb(configuration: RSliderConfiguration) -> some View {
        _makeThumb(configuration)
    }
    
    public func makeTrack(configuration: RSliderConfiguration) -> some View {
        _makeTrack(configuration)
    }
    
    public func makeTickMark(configuration: RSliderConfiguration, tickValue: Double) -> some View {
        _makeTickMark(configuration, tickValue)
    }
    
    public init<S: RSliderStyle>(_ style: S) {
        self._makeThumb = style.makeThumbTypeErased
        self._makeTrack = style.makeTrackTypeErased
        self._makeTickMark = style.makeTickMarkTypeErased
    }
}

public struct RSliderStyleKey: EnvironmentKey {
    public static let defaultValue: AnyRSliderStyle = AnyRSliderStyle(DefaultRSliderStyle())
}

extension EnvironmentValues {
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
    public func radialSliderStyle<S>(_ style: S) -> some View where S: RSliderStyle {
        environment(\.radialSliderStyle, AnyRSliderStyle(style))
    }
}

// MARK: - Default Style

public struct DefaultRSliderStyle: RSliderStyle, Sendable {
    
    let trackColor: Color
    let trackFilledColor: Color
    let thumbInactiveColor: Color
    let thumbActiveColor: Color
    let trackThickness: Double
    
    public init(
        trackColor: Color = Color(red: 0.55, green: 0.55, blue: 0.59),
        trackFilledColor: Color = Color(red: 0.084, green: 0.247, blue: 0.602),
        thumbInactiveColor: Color = Color.white,
        thumbActiveColor: Color = Color(red: 0.204, green: 0.648, blue: 0.855),
        trackThickness: Double = 24.0
    ) {
        self.trackColor = trackColor
        self.trackFilledColor = trackFilledColor
        self.thumbInactiveColor = thumbInactiveColor
        self.thumbActiveColor = thumbActiveColor
        self.trackThickness = trackThickness
    }
    
    public func makeThumb(configuration: RSliderConfiguration) -> some View {
        Circle()
            .fill(configuration.isActive ? thumbInactiveColor : thumbActiveColor)
            .frame(width: trackThickness * 2, height: trackThickness * 2)
            .shadow(
                color: Color.black.opacity(0.2),
                radius: configuration.isActive ? 5 : 2
            )
            .offset(x: -trackThickness * cos(configuration.angle.radians),
                    y: -trackThickness * sin(configuration.angle.radians))
    }
    
    public func makeTrack(configuration: RSliderConfiguration) -> some View {
        return ZStack {
            Circle()
                .strokeBorder(trackColor, lineWidth: trackThickness)
            
            CircularArc(
                percent: configuration.percent == 1 && configuration.maxWinds >= 1
                ? 1.0
                : configuration.withinWind
            )
            .strokeBorder(trackFilledColor, lineWidth: trackThickness)
        }
        .padding(trackThickness / 2)
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

public struct KnobStyle: RSliderStyle {
    let backgroundColor: Color
    let strokeColor: Color
    let thumbColor: Color
    let thumbSize: Double
    let thumbInset: Double
    
    // Color(red: 0, green: 0.3979960084, blue: 0.5352870226)
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
    
    /// Returns an empty view for now
    public func makeTickMark(configuration: RSliderConfiguration, tickValue: Double) -> some View {
        EmptyView()
    }
}
