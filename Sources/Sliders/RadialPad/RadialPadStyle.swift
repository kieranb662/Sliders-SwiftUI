// Swift toolchain version 6.0
// Running macOS version 26.3
// Created on 3/13/26.
//
// Author: Kieran Brown
//

import SwiftUI

// MARK: - Style

public struct RadialPadConfiguration: Sendable {
    /// whether or not the slider is current disables
    public let isDisabled: Bool
    /// whether or not the thumb is dragging or not
    public let isActive: Bool
    /// Is true if the radial offset is equal to the pads radius
    public let isAtLimit: Bool
    /// The angle of the line between the pads center and the thumbs location, measured from the vector pointing in the trailing direction
    public let angle: Angle
    /// The Thumb's distance from the Track's center
    public let radialOffset: Double
    
    public init(_ isDisabled: Bool ,_ isActive: Bool , _ isAtLimit: Bool, _ angle: Angle, _ radialOffset: Double) {
        self.isDisabled = isDisabled
        self.isActive = isActive
        self.isAtLimit = isAtLimit
        self.angle = angle
        self.radialOffset = radialOffset
    }
}

public protocol RadialPadStyle: Sendable {
    associatedtype Track: View
    associatedtype Thumb: View
    
    func makeTrack(configuration: RadialPadConfiguration) -> Self.Track
    func makeThumb(configuration: RadialPadConfiguration) -> Self.Thumb
}

public extension RadialPadStyle {
    func makeTrackTypeErased(configuration: RadialPadConfiguration) -> AnyView {
        AnyView(self.makeTrack(configuration: configuration))
    }
    
    func makeThumbTypeErased(configuration: RadialPadConfiguration) -> AnyView {
        AnyView(self.makeThumb(configuration: configuration))
    }
}

public struct AnyRadialPadStyle: RadialPadStyle, Sendable {
    private let _makeTrack: @Sendable (RadialPadConfiguration) -> AnyView
    public func makeTrack(configuration: RadialPadConfiguration) -> some View {
        return _makeTrack(configuration)
    }
    
    private let _makeThumb: @Sendable (RadialPadConfiguration) -> AnyView
    public func makeThumb(configuration: RadialPadConfiguration) -> some View {
        return _makeThumb(configuration)
    }
    
    public init<S: RadialPadStyle>(_ style: S) {
        self._makeTrack = style.makeTrackTypeErased
        self._makeThumb = style.makeThumbTypeErased
    }
}

public struct DefaultRadialPadStyle: RadialPadStyle, Sendable {
    public init() { }
    
    public func makeTrack(configuration: RadialPadConfiguration) -> some View {
        Circle()
            .fill(Color.gray.opacity(0.4))
    }
    
    public func makeThumb(configuration: RadialPadConfiguration) -> some View {
        Circle()
            .fill(Color.blue)
            .frame(width: 45, height: 45)
        
    }
}

public struct RadialPadStyleKey: EnvironmentKey {
    public static let defaultValue: AnyRadialPadStyle  = AnyRadialPadStyle(DefaultRadialPadStyle())
}

extension EnvironmentValues {
    public var radialPadStyle: AnyRadialPadStyle {
        get {
            return self[RadialPadStyleKey.self]
        }
        set {
            self[RadialPadStyleKey.self] = newValue
        }
    }
}

extension View {
    public func radialPadStyle<S>(_ style: S) -> some View where S: RadialPadStyle {
        environment(\.radialPadStyle, AnyRadialPadStyle(style))
    }
}
