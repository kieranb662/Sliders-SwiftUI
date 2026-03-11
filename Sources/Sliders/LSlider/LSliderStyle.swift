// Swift toolchain version 6.0
// Running macOS version 26.3
// Created on 3/11/26.
//
// Author: Kieran Brown
//

import SwiftUI

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
}

// MARK: - LSlider Style

public protocol LSliderStyle: Sendable {
    associatedtype Thumb: View
    associatedtype Track: View
    
    func makeThumb(configuration:  LSliderConfiguration) -> Self.Thumb
    func makeTrack(configuration:  LSliderConfiguration) -> Self.Track
}

public extension LSliderStyle {
    func makeThumbTypeErased(configuration:  LSliderConfiguration) -> AnyView {
        AnyView(self.makeThumb(configuration: configuration))
    }
    func makeTrackTypeErased(configuration:  LSliderConfiguration) -> AnyView {
        AnyView(self.makeTrack(configuration: configuration))
    }
}

public struct AnyLSliderStyle: LSliderStyle, Sendable {
    private let _makeThumb: @Sendable (LSliderConfiguration) -> AnyView
    
    public func makeThumb(configuration: LSliderConfiguration) -> some View {
        _makeThumb(configuration)
    }
    
    private let _makeTrack: @Sendable (LSliderConfiguration) -> AnyView
    
    public func makeTrack(configuration: LSliderConfiguration) -> some View  {
        _makeTrack(configuration)
    }
    
    public init<S: LSliderStyle>(_ style: S) {
        self._makeThumb = style.makeThumbTypeErased
        self._makeTrack = style.makeTrackTypeErased
    }
}

public struct LSliderStyleKey: EnvironmentKey {
    public static let defaultValue: AnyLSliderStyle = AnyLSliderStyle(DefaultLSliderStyle())
}

extension EnvironmentValues {
    public var linearSliderStyle: AnyLSliderStyle {
        get {
            return self[LSliderStyleKey.self]
        }
        set {
            self[LSliderStyleKey.self] = newValue
        }
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
    
    public func makeThumb(configuration:  LSliderConfiguration) -> some View {
        Circle()
            .fill(configuration.isActive ? Color.yellow : Color.cyan)
            .frame(width: configuration.trackThickness, height: configuration.trackThickness)
    }
    
    public func makeTrack(configuration:  LSliderConfiguration) -> some View {
        // When keepThumbInTrack is true, the thumb travels over a shorter range (inset by
        // thickness/2 on each end). The filled region must end at the thumb's trailing edge,
        // which is at: thumbCenter + thumbRadius
        //   = (inset + pctFill*(L - 2*inset)) + inset
        //   = 2*inset + pctFill*(L - 2*inset)
        // The difference vs. pctFill*L is: 2*inset*(1 - pctFill)
        // When keepThumbInTrack is false the thumb already travels the full range so we
        // only need the standard half-thumb offset.
        let adjustment: Double = configuration.keepThumbInTrack
        ? configuration.trackThickness * (1 - configuration.pctFill)
        : configuration.trackThickness / 2

        return ZStack {
            AdaptiveLine(thickness: configuration.trackThickness, angle: configuration.angle)
                .fill(.gray)
            
            AdaptiveLine(
                thickness: configuration.trackThickness,
                angle: configuration.angle,
                percentFilled: configuration.pctFill,
                adjustmentForThumb: adjustment
            )
            .fill(Color.blue)
            .mask(AdaptiveLine(thickness: configuration.trackThickness, angle: configuration.angle))
        }
    }
}
