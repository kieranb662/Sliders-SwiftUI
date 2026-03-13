// Swift toolchain version 6.0
// Running macOS version 26.3
// Created on 4/7/20.
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

/// # Radial Track Pad
///
/// A control that constrains the drag gesture of the thumb to be contained within the radius of the track.
/// Similar to a joystick, with the difference being that the thumb stays fixed at the  gestures end location when the drag is finished.
/// - parameters:
///  - offset: `Binding<Double>` The distance measured from the tracks center to the thumbs location
///  - angle: `Binding<Angle>`  The angle of the line between the pads center and the thumbs location, measured from the vector pointing in the trailing direction
///  - isDisabled: `Bool`  value describing if the sliders state is disabled (default is `false`)
///
/// - note: There is no need to define the radius of the track because the `RadialPad` automatically adjusts to the geometry of its container.
///
/// ## Styling
///
/// To create a custom style for the `RadialPad` you need to create a `RadialPadStyle` conforming struct.
/// Conformance requires implementation of 2 methods
///     1. `makeThumb`: which creates the draggable portion of the `RadialPad`
///     2. `makeTrack`: which creates the background that the thumb will be contained in.
///
/// Both methods provide read access to the state values of the `RadialPad` thru the `RadialPadConfiguration` struct
///
///         struct RadialPadConfiguration {
///              let isDisabled: Bool // whether or not the slider is current disables
///              let isActive: Bool // whether or not the thumb is dragging or not
///              let isAtLimit: Bool // Is true if the radial offset is equal to the pads radius
///              let angle: Angle // The angle of the line between the pads center and the thumbs location, measured from the vector pointing in the trailing direction
///              let radialOffset: Double // The Thumb's distance from the Track's center
///          }
///
/// To make this easier just copy and paste the following style based on the `DefaultRadialPadStyle`. After creating your custom style
/// apply it by calling the `radialPadStyle` method on the `RadialPad` or a view containing it.
///
///       struct <#My RadialPad Style#>: RadialPadStyle {
///           func makeTrack(configuration: RadialPadConfiguration) -> some View {
///               Circle()
///                   .fill(Color.gray.opacity(0.4))
///           }
///           func makeThumb(configuration: RadialPadConfiguration) -> some View {
///               Circle()
///                   .fill(Color.blue)
///                   .frame(width: 45, height: 45)
///           }
///       }
///

public struct RadialPad: View {
    @Environment(\.radialPadStyle) private var style: AnyRadialPadStyle
    private let space: String = "Radial Pad"
    @Binding public var offset: Double
    @Binding public var angle: Angle
    @State private var isActive: Bool = false
    public var isDisabled: Bool = false
    
    public init(offset: Binding<Double>, angle: Binding<Angle>) {
        self._offset = offset
        self._angle = angle
    }
    
    public init(offset: Binding<Double>, angle: Binding<Angle>, isDisabled: Bool) {
        self._offset = offset
        self._angle = angle
        self.isDisabled = isDisabled
    }
    
    private func thumbOffset(_ proxy: GeometryProxy) -> CGSize {
        let radius = Double(proxy.size.width > proxy.size.height ? proxy.size.height/2 : proxy.size.width/2)
        let pX = radius*offset*cos(angle.radians)
        let pY = radius*offset*sin(angle.radians)
        return CGSize(width: pX, height: pY)
    }
    
    private var configuration: RadialPadConfiguration {
        return .init(isDisabled, isActive, offset == 1, angle, offset)
    }
    
    private func makeGesture(_ proxy: GeometryProxy) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named(space))
            .onChanged({
                let middle = CGPoint(x: proxy.size.width/2, y: proxy.size.height/2)
                let radius = Double(proxy.size.width > proxy.size.height ? proxy.size.height/2 : proxy.size.width/2)
                let off = sqrt((middle - $0.location).magnitudeSquared)
                offset = min(radius, off)/radius
                angle = Angle(degrees: calculateDirection(middle, $0.location)*360)
                isActive = true
            })
            .onEnded({
                let middle = CGPoint(x: proxy.size.width/2, y: proxy.size.height/2)
                let radius = Double(proxy.size.width > proxy.size.height ? proxy.size.height/2 : proxy.size.width/2)
                let off = sqrt((middle - $0.location).magnitudeSquared)
                offset = min(radius, off)/radius
                angle = Angle(degrees: calculateDirection(middle, $0.location)*360)
                isActive = false
            })
    }
    
    public var body: some View {
        ZStack {
            style.makeTrack(configuration: configuration)
                .overlay(
                    GeometryReader { proxy in
                        ZStack(alignment: .center) {
                            style.makeThumb(configuration: configuration)
                                .offset(thumbOffset(proxy))
                                .gesture(makeGesture(proxy))
                        }
                        .frame(width: proxy.size.width, height: proxy.size.height)
                    }
                )
        }
        .coordinateSpace(name: space)
    }
}

