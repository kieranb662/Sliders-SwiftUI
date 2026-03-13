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
/// Instances of `LSliderConfiguration` are provided to an ``LSliderStyle`` so your style can
/// render the thumb, track, and tick marks based on the slider’s live interaction state.
public struct LSliderConfiguration: Sendable {
    /// Whether the slider is disabled.
    ///
    /// This is derived from SwiftUI’s `\.isEnabled` environment value.
    public let isDisabled: Bool

    /// Whether the user is actively dragging the thumb.
    public let isActive: Bool

    /// The normalized fill percent in the range `[0, 1]`.
    ///
    /// This value is computed from `value`, `min`, and `max`.
    public let pctFill: Double

    /// The current value of the slider.
    ///
    /// When tick-mark affinity is enabled, this may be set to a snapped tick value while
    /// the user is dragging.
    public let value: Double

    /// The angle of the slider’s track.
    public let angle: Angle

    /// The minimum value of the slider’s range.
    public let min: Double

    /// The maximum value of the slider’s range.
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
    /// Styles can use this to highlight the tick mark that is currently “captured”.
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
}

public extension LSliderStyle {
    /// Type-erases ``makeThumb(configuration:)`` for storage in ``AnyLSliderStyle``.
    func makeThumbTypeErased(configuration: LSliderConfiguration) -> AnyView {
        AnyView(self.makeThumb(configuration: configuration))
    }

    /// Type-erases ``makeTrack(configuration:)`` for storage in ``AnyLSliderStyle``.
    func makeTrackTypeErased(configuration: LSliderConfiguration) -> AnyView {
        AnyView(self.makeTrack(configuration: configuration))
    }

    /// Type-erases ``makeTickMark(configuration:tickValue:)`` for storage in ``AnyLSliderStyle``.
    func makeTickMarkTypeErased(configuration: LSliderConfiguration, tickValue: Double) -> AnyView {
        AnyView(self.makeTickMark(configuration: configuration, tickValue: tickValue))
    }
}

// MARK: - AnyLSliderStyle

/// A type-erased ``LSliderStyle``.
///
/// `LSlider` stores its style in the SwiftUI environment, which requires a concrete type.
/// `AnyLSliderStyle` wraps any style and forwards the view-building calls.
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

    /// Creates a type-erased wrapper around `style`.
    public init<S: LSliderStyle>(_ style: S) {
        self._makeThumb = style.makeThumbTypeErased
        self._makeTrack = style.makeTrackTypeErased
        self._makeTickMark = style.makeTickMarkTypeErased
    }
}

// MARK: - Environment

/// An environment key used to store the current ``LSliderStyle``.
public struct LSliderStyleKey: EnvironmentKey {
    /// The default style used when no custom style is provided.
    public static let defaultValue: AnyLSliderStyle = AnyLSliderStyle(DefaultLSliderStyle())
}

extension EnvironmentValues {
    /// The current linear slider style used by ``LSlider``.
    public var linearSliderStyle: AnyLSliderStyle {
        get { self[LSliderStyleKey.self] }
        set { self[LSliderStyleKey.self] = newValue }
    }
}

extension View {
    /// Sets the style for ``LSlider`` instances within this view hierarchy.
    ///
    /// - Parameter style: The style to apply.
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

    /// Creates the default style.
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
