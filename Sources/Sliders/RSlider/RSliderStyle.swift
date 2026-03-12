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
    public init() { }

    public func makeThumb(configuration: RSliderConfiguration) -> some View {
        Circle()
            .frame(width: 30, height: 30)
            .foregroundColor(configuration.isActive ? Color.yellow : Color.white)
    }

    public func makeTrack(configuration: RSliderConfiguration) -> some View {
        // How far around the circle the thumb is within the current wind (0–1)
        let withinWind = configuration.maxWinds > 0
            ? (configuration.currentWind + (configuration.value - configuration.min) / (configuration.max - configuration.min) * configuration.maxWinds)
                .truncatingRemainder(dividingBy: 1.0)
            : 0.0
        return ZStack {
            Circle()
                .stroke(Color.gray, style: StrokeStyle(lineWidth: 10, lineCap: .round))
            Circle()
                .trim(from: 0, to: CGFloat(withinWind))
                .stroke(Color.purple, style: StrokeStyle(lineWidth: 12, lineCap: .round))
        }
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
    public init() { }

    public func makeThumb(configuration: RSliderConfiguration) -> some View {
        let gradient = RadialGradient(gradient: Gradient(colors: [.gray, .white]), center: .center, startRadius: 0, endRadius: 80)
        return Circle()
            .fill(gradient)
            .frame(width: 40)
            .shadow(radius: 1)
    }

    public func makeTrack(configuration: RSliderConfiguration) -> some View {
        // Total rotation in degrees across all completed winds plus position in current wind
        let totalDegrees = configuration.maxWinds > 0
            ? 360.0 * (configuration.currentWind + (configuration.value - configuration.min) / (configuration.max - configuration.min) * configuration.maxWinds)
                .truncatingRemainder(dividingBy: 1.0) / configuration.maxWinds
                + 360.0 * configuration.currentWind / configuration.maxWinds
            : 0.0
        return Circle().frame(width: 150)
            .foregroundColor(.clear)
            .overlay(ZStack {
                Circle()
                    .fill(
                        RadialGradient(gradient: Gradient(colors: [.blue, Color(white: 0.2)]),
                                       center: .center,
                                       startRadius: 0,
                                       endRadius: 300)
                    )
                    .drawingGroup(opaque: false, colorMode: .extendedLinear)
                    .overlay(
                        Circle()
                            .stroke(Color.white, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round, miterLimit: 0, dash: [6], dashPhase: 0))
                    )
            }
            .rotationEffect(Angle(degrees: totalDegrees))
            .scaleEffect(1.50))
    }

    /// Returns a simple tick mark: a small white circle.
    public func makeTickMark(configuration: RSliderConfiguration, tickValue: Double) -> some View {
        Circle()
            .fill(Color.white)
            .frame(width: 4, height: 4)
    }
}
