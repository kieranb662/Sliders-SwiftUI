//
//  Joystick.swift
//  MyExamples
//
//  Created by Kieran Brown on 3/27/20.
//  Copyright © 2020 BrownandSons. All rights reserved.
//

import SwiftUI


// MARK: - Style
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public struct JoystickConfiguration {
    /// whether or not the slider is current disables
    public let isDisabled: Bool
    /// True if the joystick thumb is dragging or if the joystick is locked
    public let isActive: Bool
    /// whether the offset of the thumb reached the radius of the circle
    public let isAtLimit: Bool
    /// Whether the joystick is locked or not
    public let isLocked: Bool
    /// The angle of the line between the pads center and the thumbs location, measured from the vector pointing in the trailing direction
    public let angle: Angle
    /// The current displacement of the thumb from the track's center
    public let radialOffset: Double
    
    public init(_ isDisabled: Bool, _ isActive: Bool , _ isAtLimit: Bool, _ isLocked: Bool, _ angle: Angle, _ radialOffset: Double) {
        self.isDisabled = isDisabled
        self.isActive = isActive
        self.isAtLimit = isAtLimit
        self.isLocked = isLocked
        self.angle = angle
        self.radialOffset = radialOffset
    }
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public protocol JoystickStyle {
    associatedtype HitBox: View
    associatedtype LockBox: View
    associatedtype Track: View
    associatedtype Thumb: View
    
    func makeHitBox(configuration: JoystickConfiguration) -> Self.HitBox
    func makeLockBox(configuration: JoystickConfiguration) -> Self.LockBox
    func makeTrack(configuration: JoystickConfiguration) -> Self.Track
    func makeThumb(configuration: JoystickConfiguration) -> Self.Thumb
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public extension JoystickStyle {
    
    func makeHitBoxTypeErased(configuration: JoystickConfiguration) -> AnyView {
        AnyView(self.makeHitBox(configuration: configuration))
    }
    func makeLockBoxTypeErased(configuration: JoystickConfiguration) -> AnyView {
        AnyView(self.makeLockBox(configuration: configuration))
    }
    func makeTrackTypeErased(configuration: JoystickConfiguration) -> AnyView {
        AnyView(self.makeTrack(configuration: configuration))
    }
    func makeThumbTypeErased(configuration: JoystickConfiguration) -> AnyView {
        AnyView(self.makeThumb(configuration: configuration))
    }
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public struct AnyJoystickStyle: JoystickStyle {
    private let _makeHitBox: (JoystickConfiguration) -> AnyView
    public func makeHitBox(configuration: JoystickConfiguration) -> some View {
        return self._makeHitBox(configuration)
    }
    
    private let _makeLockBox: (JoystickConfiguration) -> AnyView
    public func makeLockBox(configuration: JoystickConfiguration) -> some View {
        return self._makeLockBox(configuration)
    }
    
    private let _makeTrack: (JoystickConfiguration) -> AnyView
    public func makeTrack(configuration: JoystickConfiguration) -> some View {
        return self._makeTrack(configuration)
    }
    
    private let _makeThumb: (JoystickConfiguration) -> AnyView
    public func makeThumb(configuration: JoystickConfiguration) -> some View {
        return self._makeThumb(configuration)
    }
    
    public init<ST: JoystickStyle>(_ style: ST) {
        self._makeHitBox = style.makeHitBoxTypeErased
        self._makeLockBox = style.makeLockBoxTypeErased
        self._makeTrack = style.makeTrackTypeErased
        self._makeThumb = style.makeThumbTypeErased
        
    }
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public struct DefaultJoystickStyle: JoystickStyle {
    public init() { }
    
    public func makeHitBox(configuration: JoystickConfiguration) -> some View {
        Rectangle()
            .fill(Color.white.opacity(0.05))
    }
    public func makeLockBox(configuration: JoystickConfiguration) -> some View {
        ZStack {
            Circle()
                .fill(Color.black)
            Circle()
                .fill(Color.yellow)
                .scaleEffect(0.7)
        }.frame(width: 25, height: 25)
    }
    public func makeTrack(configuration: JoystickConfiguration) -> some View {
        Circle()
            .fill(Color.gray.opacity(0.4))
    }
    public func makeThumb(configuration: JoystickConfiguration) -> some View {
        Circle()
            .fill(Color.blue)
            .frame(width: 45, height: 45)
        
    }
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public struct JoystickStyleKey: EnvironmentKey {
    public static let defaultValue: AnyJoystickStyle  = AnyJoystickStyle(DefaultJoystickStyle())
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
extension EnvironmentValues {
    public var joystickStyle: AnyJoystickStyle {
        get {
            return self[JoystickStyleKey.self]
        }
        set {
            self[JoystickStyleKey.self] = newValue
        }
    }
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
extension View {
    public func joystickStyle<S>(_ style: S) -> some View where S: JoystickStyle {
        self.environment(\.joystickStyle, AnyJoystickStyle(style))
    }
}


// MARK: - State
/// An Enumeration used to represent the state of a `Joystick`
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public enum JoyState {
    case inactive
    case locked
    case dragging(time: Date, translation: CGSize, startLocation: CGPoint, velocity: CGSize, acceleration: CGSize)
    
    public var isLocked: Bool {
        switch self {
        case .locked: return true
        default: return false
        }
    }
    public var isDragging: Bool {
        switch self {
        case .dragging(_, _, _, _, _): return true
        default: return false
        }
    }
    public var isActive: Bool {
        switch self {
        case .inactive: return false
        default: return true
        }
    }
    public var time: Date? {
        switch self {
        case .dragging( let time, _ , _, _, _):
            return time
        default: return nil
        }
    }
    public var translation: CGSize {
        switch self {
        case .dragging(_, let translation , _, _, _):
            return translation
        default: return .zero
        }
    }
    public var startLocation: CGPoint? {
        switch self {
        case .dragging(_, _ , let start, _, _):
            return start
        default: return nil
        }
    }
    public var velocity: CGSize {
        switch self {
        case .dragging(_ , _ , _, let velocity, _):
            return velocity
        default: return .zero
        }
    }
    public var acceleration: CGSize {
        switch self {
        case .dragging(_ , _ , _, _, let acceleration):
            return acceleration
        default: return .zero
        }
    }
    public var angle: Angle {
        switch self {
        case .dragging(_, let trans , _, _, _):
            return Angle(radians: atan2(Double(trans.height), Double(trans.width)) )
        default: return .zero
        }
    }
    public var radialOffset: Double {
        switch self {
        case .dragging(_, let trans , _, _, _):
            return sqrt(trans.magnitudeSquared)
        default: return 0
        }
    }
    
}

// MARK: - Joystick

/// # Joystick
///
/// Joystick view used to control various activities such as moving a character on the screen.
/// The View creates a Rectangular region to act as a hitbox for drag gestures. Once a drag
/// is initiated the joystick appears on screen centered at the start location of the gesture. While
/// dragging, the thumb of the joystick is limited be within the `radius` of the sticks background circle.
///
/// - parameters:
///     - state: `Binding<JoyState>`  you provide a binding to a Joystate  value which allows you to maintain access to all of the Joysticks state values
///     - radius: `Double` The radius of the track
///     - canLock: A boolean value describing whether the joystick has locking behavior (**default: true**)
///     - isDisabled: `Bool` whether the joystick allows hit testing or not (**default: false**)
///
///
/// ## Style
///
/// The Joystick can be themed and styled by making a custom struct conforming to the `JoystickStyle`
/// protocol. Conformance requires that you implement 4 methods
///     1.  `makeHitBox` - Creates the rectangular region that responds the the users touch
///     2. `makeLockBox` - Creates a view such that if the drag gestures location is contained within the lockbox, the joystick goes into the locked state
///     3.  `makeTrack` - Creates the circular track that contains the joystick thumb
///     4   `makeThumb` - Creates the part of the joystick the moves when dragging
///
///  These 3 methods all provide access to the `JoystickConfiguration` .
///  Make use of the various state values to customize the Joystick to your liking.
///
///         struct JoystickConfiguration {
///             let isDisabled: Bool // whether or not the slider is current disables
///             let isActive: Bool // True if the joystick thumb is dragging or if the joystick is locked
///             let isAtLimit: Bool // whether the offset of the thumb reached the radius of the circle
///             let isLocked: Bool // Whether the joystick is locked or not
///             let angle: Angle // The angle of the line between the pads center and the thumbs location, measured from the vector pointing in the trailing direction
///             let radialOffset: Double // The current displacement of the thumb from the track's center
///          }
///
/// Once your custom style has been created, implement it by calling the `joystickStyle(_ :)` method on the `Joystick` or
/// a view containing the `Joystick` to be styled. To make it easier try using the follow example based upon the `DefaultJoystickStyle`
///
///          struct <#My Joystick Style#>: JoystickStyle {
///              func makeHitBox(configuration: JoystickConfiguration) -> some View {
///                  Rectangle()
///                      .fill(Color.white.opacity(0.05))
///              }
///              func makeLockBox(configuration: JoystickConfiguration) -> some View {
///                  Circle()
///                      .fill(Color.black)
///                      .overlay(Circle().fill(Color.yellow).scaleEffect(0.7))
///                      .frame(width: 25, height: 25)
///              }
///              func makeTrack(configuration: JoystickConfiguration) -> some View {
///                  Circle()
///                      .fill(Color.gray.opacity(0.4))
///              }
///              func makeThumb(configuration: JoystickConfiguration) -> some View {
///                  Circle()
///                      .fill(Color.blue)
///                      .frame(width: 45, height: 45)
///
///              }
///          }
///
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public struct Joystick: View {
    typealias Key = JoyStickKey
    struct JoyStickKey: PreferenceKey {
        static var defaultValue: [Int:Anchor<CGRect>] { [:] }
        static func reduce(value: inout [Int:Anchor<CGRect>], nextValue: () -> [Int:Anchor<CGRect>]) {
            value.merge(nextValue(), uniquingKeysWith: {$1})
        }
    }
    @Environment(\.joystickStyle) private var style: AnyJoystickStyle
    let radius: Double
    let canLock: Bool
    let isDisabled: Bool
    @Binding public var state: JoyState
    
    public init(state: Binding<JoyState>, radius: Double, canLock: Bool, isDisabled: Bool) {
        self._state = state
        self.radius = radius
        self.canLock = canLock
        self.isDisabled = isDisabled
    }
    public init(state: Binding<JoyState>, radius: Double) {
        self._state = state
        self.radius = radius
        self.canLock = true
        self.isDisabled = false
    }
    public init(state: Binding<JoyState>, radius: Double, isDisabled: Bool) {
        self._state = state
        self.radius = radius
        self.canLock = true
        self.isDisabled = isDisabled
    }
    
    @State private var lastPlacement: CGPoint = .zero
    @State private var isInsideLockBox = false
    private var config: JoystickConfiguration {
        .init(isDisabled,
              state.isActive,
              state.radialOffset == radius,
              state.isLocked,
              state.angle,
              state.radialOffset)
    }
    // MARK:  Calculations
    private func calculateVelocity(translation: CGSize, time: Date) -> CGSize {
        guard let last = state.time else {return .zero}
        let dx = translation.width-state.translation.width
        let dy = translation.height-state.translation.height
        let dt = CGFloat(1/last.timeIntervalSince(time))
        return CGSize(width: dx*dt, height: dy*dt)
    }
    private func calculateAcceleration(velocity: CGSize, time: Date) -> CGSize {
        guard let last = state.time else {return .zero}
        let dx = velocity.width-state.velocity.width
        let dy = velocity.height-state.velocity.height
        let dt = CGFloat(1/last.timeIntervalSince(time))
        return CGSize(width: dx*dt, height: dy*dt)
    }
    private func limitTranslation(_ translation: CGSize) -> CGSize {
        if translation.magnitudeSquared < radius*radius {return translation}
        let magnitude = sqrt(translation.magnitudeSquared)
        let w = Double(translation.width)*radius/magnitude
        let h = Double(translation.height)*radius/magnitude
        return CGSize(width: w, height: h)
    }
    
    // MARK: Haptics
    private func impactOccured() {
        #if os(macOS)
        #else
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        #endif
    }
    private func locked() {
        #if os(macOS)
        #else
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
    }
    private func enteredLockBoxHandler(_ isInside: Bool) {
        if self.canLock {
            if isInside {
                if !self.isInsideLockBox {
                    self.impactOccured()
                }
                self.isInsideLockBox = true
            } else {
                self.isInsideLockBox = false
            }
        }
    }
    private func lock(_ shouldLock: Bool) {
        if canLock {
            if shouldLock {
                state = .locked
                locked()
            } else {
                state = .inactive
            }
        } else {
            self.state = .inactive
        }
    }
    
    // MARK: Views
    private var draggingViews: some View {
        Group {
            style.makeLockBox(configuration: config)
                .position(state.startLocation!)
                .offset(x: 0, y: -CGFloat(radius+50))
                .transition(AnyTransition.opacity.animation(.easeIn))
                .opacity(canLock ? 1 : 0)
            
            
            style.makeThumb(configuration: config)
                .offset(x: state.translation.width, y: state.translation.height)
                .background(style.makeTrack(configuration: config)
                    .frame(width: CGFloat(2*radius), height: CGFloat(2*radius)))
                .position(state.startLocation!)
                .transition(AnyTransition.opacity.animation(.easeIn))
        }
    }
    private var lockedViews: some View {
        Group {
            style.makeLockBox(configuration: config)
                .position(lastPlacement)
                .offset(x: 0, y: -CGFloat(radius+50))
            
            style.makeThumb(configuration: config)
                .offset(x: state.translation.width, y: state.translation.height)
                .background(style.makeTrack(configuration: config)
                    .frame(width: CGFloat(2*radius), height: CGFloat(2*radius)))
                .position(lastPlacement)
        }
    }
    private var joystick: some View {
        Group {
            if state.isDragging {
                self.draggingViews
            } else if state.isLocked {
                self.lockedViews
            }
        }
    }
    
    public var body: some View {
        ZStack {
            style.makeLockBox(configuration: config)
                .anchorPreference(key: Key.self, value: .bounds, transform: { [1: $0]})
                .opacity(0)
                .position(state.startLocation ?? .zero)
                .offset(x: 0, y: -CGFloat(radius+50))
            style.makeHitBox(configuration: config)
                .opacity(0)
                .allowsHitTesting(!self.isDisabled)
        }.overlayPreferenceValue(Key.self) { (bounds: [Int: Anchor<CGRect>]) in
            GeometryReader { proxy in
                ZStack(alignment: .center) {
                    self.style.makeHitBox(configuration: self.config)
                        .gesture(DragGesture()
                            .onChanged({ (value) in
                                self.lastPlacement = .zero
                                let translation = self.limitTranslation(value.translation)
                                let velocity = self.calculateVelocity(translation: translation, time: value.time)
                                self.state = .dragging(time: value.time,
                                                       translation: translation,
                                                       startLocation: value.startLocation,
                                                       velocity: velocity,
                                                       acceleration: self.calculateAcceleration(velocity: velocity, time: value.time))
                                guard let bound = bounds[1] else { return }
                                self.enteredLockBoxHandler(proxy[bound].contains(value.location))
                            })
                            .onEnded({ (value) in
                                self.lastPlacement = value.startLocation
                                guard let bound = bounds[1] else { return }
                                self.lock(proxy[bound].contains(value.location))
                            }))
                    self.joystick.allowsHitTesting(false)
                }.frame(width: proxy.size.width, height: proxy.size.height)
            }
        }
    }
}



