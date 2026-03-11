// Swift toolchain version 6.0
// Running macOS version 26.3
// Created on 3/11/26.
//
// Author: Kieran Brown
//

import SwiftUI

// MARK: - TickMarkSpacing

/// Describes how tick marks should be spaced along the LSlider's dragging axis.
public enum TickMarkSpacing: Sendable, Equatable {
    /// Place a tick mark every `spacing` units in the slider's value domain.
    case spacing(Double)
    /// Distribute exactly `count` tick marks evenly across the slider's range (including endpoints).
    case count(Int)
    /// Place tick marks at the specified values within the slider's range.
    case values([Double])
}

// MARK: - LSlider Configuration

public struct LSliderConfiguration: Sendable {
    /// whether or not the slider is current disables
    public let isDisabled: Bool
    /// whether or not the thumb is dragging or not
    public let isActive: Bool
    /// The percentage of the sliders track that is filled
    public let pctFill: Double
    /// The current value of the slider
    public let value: Double
    /// Angle of the slider
    public let angle: Angle
    /// The minimum value of the sliders range
    public let min: Double
    /// The maximum value of the sliders range
    public let max: Double
    /// Whether the thumb is constrained to stay within the track's extent
    public let keepThumbInTrack: Bool
    /// The thickness of the track, used to compute how far the thumb center is inset from the track ends
    public let trackThickness: Double
    /// How tick marks are spaced, or `nil` if tick marks are disabled.
    public let tickMarkSpacing: TickMarkSpacing?
    /// The resolved list of tick-mark values computed from `tickMarkSpacing`.
    public let tickValues: [Double]
}

// MARK: - LSlider Style

public protocol LSliderStyle: Sendable {
    associatedtype Thumb: View
    associatedtype Track: View
    associatedtype TickMark: View
    
    func makeThumb(configuration: LSliderConfiguration) -> Self.Thumb
    func makeTrack(configuration: LSliderConfiguration) -> Self.Track
    /// Returns the view displayed at a single tick mark position.
    /// - Parameters:
    ///   - configuration: The current slider configuration.
    ///   - tickValue: The value (in the slider's domain) at which this tick mark sits.
    func makeTickMark(configuration: LSliderConfiguration, tickValue: Double) -> Self.TickMark
}

public extension LSliderStyle {
    func makeThumbTypeErased(configuration: LSliderConfiguration) -> AnyView {
        AnyView(self.makeThumb(configuration: configuration))
    }
    func makeTrackTypeErased(configuration: LSliderConfiguration) -> AnyView {
        AnyView(self.makeTrack(configuration: configuration))
    }
    func makeTickMarkTypeErased(configuration: LSliderConfiguration, tickValue: Double) -> AnyView {
        AnyView(self.makeTickMark(configuration: configuration, tickValue: tickValue))
    }
}

// MARK: - AnyLSliderStyle

public struct AnyLSliderStyle: LSliderStyle, Sendable {
    private let _makeThumb: @Sendable (LSliderConfiguration) -> AnyView
    private let _makeTrack: @Sendable (LSliderConfiguration) -> AnyView
    private let _makeTickMark: @Sendable (LSliderConfiguration, Double) -> AnyView
    
    public func makeThumb(configuration: LSliderConfiguration) -> some View {
        _makeThumb(configuration)
    }
    public func makeTrack(configuration: LSliderConfiguration) -> some View {
        _makeTrack(configuration)
    }
    public func makeTickMark(configuration: LSliderConfiguration, tickValue: Double) -> some View {
        _makeTickMark(configuration, tickValue)
    }
    
    public init<S: LSliderStyle>(_ style: S) {
        self._makeThumb = style.makeThumbTypeErased
        self._makeTrack = style.makeTrackTypeErased
        self._makeTickMark = style.makeTickMarkTypeErased
    }
}

// MARK: - Environment

public struct LSliderStyleKey: EnvironmentKey {
    public static let defaultValue: AnyLSliderStyle = AnyLSliderStyle(DefaultLSliderStyle())
}

extension EnvironmentValues {
    public var linearSliderStyle: AnyLSliderStyle {
        get { self[LSliderStyleKey.self] }
        set { self[LSliderStyleKey.self] = newValue }
    }
}

extension View {
    public func linearSliderStyle<S>(_ style: S) -> some View where S: LSliderStyle {
        environment(\.linearSliderStyle, AnyLSliderStyle(style))
    }
}

// MARK: - Default LSlider Style

public struct DefaultLSliderStyle: LSliderStyle, Sendable {
    
    public init() {}
    
    public func makeThumb(configuration: LSliderConfiguration) -> some View {
        Circle()
            .fill(configuration.isActive ? Color.white : Color(.sRGB, red: 0.204, green: 0.648, blue: 0.855))
            .frame(width: configuration.trackThickness * 2, height: configuration.trackThickness * 2)
            .shadow(
                color: Color.black.opacity(0.2),
                radius: configuration.isActive ? 5 : 2
            )
    }
    
    public func makeTrack(configuration: LSliderConfiguration) -> some View {
        let adjustment: Double = configuration.keepThumbInTrack
        ? configuration.trackThickness * (1 - configuration.pctFill)
        : configuration.trackThickness / 2
        
        return ZStack {
            AdaptiveLine(thickness: configuration.trackThickness, angle: configuration.angle)
                .fill(Color(.sRGB, red: 0.55, green: 0.55, blue: 0.59))
            
            AdaptiveLine(
                thickness: configuration.trackThickness,
                angle: configuration.angle,
                percentFilled: configuration.pctFill,
                adjustmentForThumb: adjustment
            )
            .fill(Color(.sRGB, red: 0.084, green: 0.247, blue: 0.602))
            .mask(AdaptiveLine(thickness: configuration.trackThickness, angle: configuration.angle))
        }
    }
    
    /// A small circle that grows and brightens as the thumb approaches this tick mark.
    public func makeTickMark(configuration: LSliderConfiguration, tickValue: Double) -> some View {
        let range = configuration.max - configuration.min
        guard range > 0 else {
            return AnyView(Circle().fill(Color.white.opacity(0.3)).frame(width: 6, height: 6))
        }
        // Normalised distance in [0, 1] between thumb and tick mark
        let thumbPct  = (configuration.value - configuration.min) / range
        let tickPct   = (tickValue          - configuration.min) / range
        let distance  = abs(thumbPct - tickPct)
        
        // Proximity is 1 when thumb is exactly on the tick, 0 when ≥ 20 % away
        let proximity = max(0, 1 - distance / 0.20)
        
        let baseSize:  Double = 5
        let maxGrowth: Double = 7
        let size = baseSize + maxGrowth * proximity
        
        let baseOpacity:  Double = 0.30
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
