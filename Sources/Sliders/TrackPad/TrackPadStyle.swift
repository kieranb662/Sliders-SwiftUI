// Swift toolchain version 6.0
// Running macOS version 26.3
// Created on 3/13/26.
//
// Author: Kieran Brown
//

import SwiftUI

// MARK: - Configuration

public struct TrackPadConfiguration: Sendable {
    /// Whether or not the trackpad is disabled
    public let isDisabled: Bool
    /// whether or not the thumb is dragging
    public let isActive: Bool
    /// `(valueX-minX)/(maxX-minX)`
    public let pctX: Double
    /// `(valueY-minY)/(maxY-minY)`
    public let pctY: Double
    /// The current value in the x direction
    public let valueX: Double
    /// The current value in the y direction
    public let valueY: Double
    /// The minimum value from rangeX
    public let minX: Double
    /// The maximum value from rangeX
    public let maxX: Double
    /// The minimum value from rangeY
    public let minY: Double
    /// The maximum value from rangeY
    public let maxY: Double
}

// MARK: - Style

public protocol TrackPadStyle: Sendable {
    associatedtype Thumb: View
    associatedtype Track: View
    
    func makeThumb(configuration:  TrackPadConfiguration) -> Self.Thumb
    func makeTrack(configuration:  TrackPadConfiguration) -> Self.Track
}

public extension TrackPadStyle {
    func makeThumbTypeErased(configuration:  TrackPadConfiguration) -> AnyView {
        AnyView(self.makeThumb(configuration: configuration))
    }
    
    func makeTrackTypeErased(configuration:  TrackPadConfiguration) -> AnyView {
        AnyView(self.makeTrack(configuration: configuration))
    }
}

public struct AnyTrackPadStyle: TrackPadStyle, Sendable {
    private let _makeThumb: @Sendable (TrackPadConfiguration) -> AnyView
    public func makeThumb(configuration: TrackPadConfiguration) -> some View {
        _makeThumb(configuration)
    }
    
    private let _makeTrack: @Sendable (TrackPadConfiguration) -> AnyView
    public func makeTrack(configuration: TrackPadConfiguration) -> some View  {
        _makeTrack(configuration)
    }
    
    public init<S: TrackPadStyle>(_ style: S) {
        self._makeThumb = style.makeThumbTypeErased
        self._makeTrack = style.makeTrackTypeErased
    }
}

public struct TrackPadStyleKey: EnvironmentKey {
    public static let defaultValue: AnyTrackPadStyle = AnyTrackPadStyle(DefaultTrackPadStyle())
}

extension EnvironmentValues {
    public var trackPadStyle: AnyTrackPadStyle {
        get {
            return self[TrackPadStyleKey.self]
        }
        set {
            self[TrackPadStyleKey.self] = newValue
        }
    }
}

extension View {
    public func trackPadStyle<S>(_ style: S) -> some View where S: TrackPadStyle {
        environment(\.trackPadStyle, AnyTrackPadStyle(style))
    }
}

// MARK: Default Style

public struct DefaultTrackPadStyle: TrackPadStyle {
    public init() { }
    
    public func makeThumb(configuration:  TrackPadConfiguration) -> some View {
        Circle()
            .fill(configuration.isActive ? Color.yellow : Color.black)
            .frame(width: 40, height: 40)
    }
    
    public func makeTrack(configuration:  TrackPadConfiguration) -> some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(Color.gray)
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.blue))
    }
}
