//
//  TrackPad.swift
//  MyExamples
//
//  Created by Kieran Brown on 4/6/20.
//  Copyright © 2020 BrownandSons. All rights reserved.
//

import SwiftUI
// MARK: - Configuration
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public struct TrackPadConfiguration {
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
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public protocol TrackPadStyle {
    associatedtype Thumb: View
    associatedtype Track: View
    
    func makeThumb(configuration:  TrackPadConfiguration) -> Self.Thumb
    func makeTrack(configuration:  TrackPadConfiguration) -> Self.Track
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public extension TrackPadStyle {
    func makeThumbTypeErased(configuration:  TrackPadConfiguration) -> AnyView {
        AnyView(self.makeThumb(configuration: configuration))
    }
    func makeTrackTypeErased(configuration:  TrackPadConfiguration) -> AnyView {
        AnyView(self.makeTrack(configuration: configuration))
    }
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public struct AnyTrackPadStyle: TrackPadStyle {
    private let _makeThumb: (TrackPadConfiguration) -> AnyView
    public func makeThumb(configuration: TrackPadConfiguration) -> some View {
        self._makeThumb(configuration)
    }
    private let _makeTrack: (TrackPadConfiguration) -> AnyView
    public func makeTrack(configuration: TrackPadConfiguration) -> some View  {
        self._makeTrack(configuration)
    }
    
    public init<S: TrackPadStyle>(_ style: S) {
        self._makeThumb = style.makeThumbTypeErased
        self._makeTrack = style.makeTrackTypeErased
    }
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public struct TrackPadStyleKey: EnvironmentKey {
    public static let defaultValue: AnyTrackPadStyle = AnyTrackPadStyle(DefaultTrackPadStyle())
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
extension EnvironmentValues {
    public var trackPadStyle: AnyTrackPadStyle {
        get {
            return self[TrackPadStyleKey.self]
        }
        set {
            self[TrackPadStyleKey] = newValue
        }
    }
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
extension View {
    public func trackPadStyle<S>(_ style: S) -> some View where S: TrackPadStyle {
        self.environment(\.trackPadStyle, AnyTrackPadStyle(style))
    }
}
// MARK: Default Style
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
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



// MARK: - TrackPad

/// # Track Pad
///
/// Essentially the 2D equaivalent of a normal `Slider`, This creates a draggable thumb and a rectangular area that the thumbs translation is restricted within
///
/// - parameters:
///     - value: A `CGPoint ` representing the two values being controlled by the trackpad in the x, and y directions
///     - rangeX: A `ClosedRange<CGFloat>` defining the minimum and maximum of  the `value` parameters  x component
///     - rangeY: A `ClosedRange<CGFloat>` defining the minimum and maximum of  the `value` parameters  y component
///     - isDisabled: A `Bool` value describing whether the track pad responds to user input or not
///
/// ## Styling
///  To create a custom style for the `TrackPad` you need to create a `TrackPadStyle` conforming struct. Conformance requires implementation of 2 methods
///  1.  `makeThumb`: which creates the draggable portion of the trackpad
///  2.  `makeTrack`: which creates view containing the thumb
///
///  Both methods provide access to state values of the track pad thru the `TrackPadConfiguration` struct
///
///         struct TrackPadConfiguration {
///             let isDisabled: Bool // Whether or not the trackpad is disabled
///             let isActive: Bool // whether or not the thumb is dragging
///             let pctX: Double // (valueX-minX)/(maxX-minX)
///             let pctY: Double // (valueY-minY)/(maxY-minY)
///             let valueX: Double // The current value in the x direction
///             let valueY: Double // The current value in the y direction
///             let minX: Double // The minimum value from rangeX
///             let maxX: Double // The maximum value from rangeX
///             let minY: Double // The minimum value from rangeY
///             let maxY: Double // The maximum value from rangeY
///         }
///
///  To make this easier just copy and paste the following style based on the `DefaultTrackPadStyle`. After creating your custom style
///  apply it by calling the `trackPadStyle` method on the `TrackPad` or a view containing it.
///
/// ```
///   struct <#My TrackPad Style #>: TrackPadStyle {
///       func makeThumb(configuration:  TrackPadConfiguration) -> some View {
///           Circle()
///               .fill(configuration.isActive ? Color.yellow : Color.black)
///               .frame(width: 40, height: 40)
///       }
///
///       func makeTrack(configuration:  TrackPadConfiguration) -> some View {
///           RoundedRectangle(cornerRadius: 5)
///               .fill(Color.gray)
///               .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.blue))
///       }
///   }
/// ```
///
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public struct TrackPad: View {
    // MARK: State and Setup
    @Environment(\.trackPadStyle) private var style: AnyTrackPadStyle
    private let space: String = "Track Pad"
    @State private var isActive: Bool = false
    @State private var atXLimit: Bool = false
    @State private var atYLimit: Bool = false
    // MARK: Inputs
    @Binding public var value: CGPoint
    public var rangeX: ClosedRange<CGFloat> = 0...1
    public var rangeY: ClosedRange<CGFloat> = 0...1
    public var isDisabled: Bool = false
    public init(value: Binding<CGPoint>, rangeX: ClosedRange<CGFloat>, rangeY: ClosedRange<CGFloat>, isDisabled: Bool = false){
        self._value = value
        self.rangeX = rangeX
        self.rangeY = rangeY
        self.isDisabled = isDisabled
    }

    public init(_ value: Binding<CGPoint>){
        self._value = value
    }
    /// Use this initializer for when the x and y ranges are the same
    public init(_ value: Binding<CGPoint>, range: ClosedRange<CGFloat>){
        self._value = value
        self.rangeX = range
        self.rangeY = range
    }


    private var configuration: TrackPadConfiguration {
        .init(isDisabled: isDisabled,
              isActive: isActive,
              pctX: Double((value.x - rangeX.lowerBound)/(rangeX.upperBound - rangeX.lowerBound)),
              pctY: Double((value.y - rangeY.lowerBound)/(rangeY.upperBound - rangeY.lowerBound)),
              valueX: Double(value.x),
              valueY: Double(value.y),
              minX: Double(rangeX.lowerBound),
              maxX: Double(rangeX.upperBound),
              minY: Double(rangeY.lowerBound),
              maxY: Double(rangeY.upperBound))
    }

    // MARK: Calculations
    // Limits the value of the drag gesture to be within the frame of the trackpad
    // If the gesture hits an edge of the trackpad a haptic impact is played, an state
    // variable for whether or not the impact has been played prevents the impact from
    // being played multiple times while dragging along an edge
    private func constrainValue(_ proxy: GeometryProxy, _ location: CGPoint) {
        let w = proxy.size.width
        let h = proxy.size.height
        // convert location to percentage form [0,1]
        let pctX = (location.x/w).clamped(to: 0...1)
        let pctY = (location.y/h).clamped(to: 0...1)
        // Horizontal haptic handling
        if pctX == 1 || pctX == 0 {
            if !self.atXLimit {
                self.impactOccured()
            }
            self.atXLimit = true
        } else {
            self.atXLimit = false
        }
        // vertical haptic handling
        if pctY == 1 || pctY == 0 {
            if !self.atYLimit {
                self.impactOccured()
            }
            self.atYLimit = true
        } else {
            self.atYLimit = false
        }
        // convert percentage to a value within the ranges provided
        let newX = pctX*(rangeX.upperBound-rangeX.lowerBound) + rangeX.lowerBound
        let newY = pctY*(rangeY.upperBound-rangeY.lowerBound) + rangeY.lowerBound
        self.value = CGPoint(x: newX, y: newY)
    }
    private func thumbOffset(_ proxy: GeometryProxy) -> CGSize {
        let w = proxy.size.width
        let h = proxy.size.height
        let pctX = (value.x - rangeX.lowerBound)/(rangeX.upperBound - rangeX.lowerBound)
        let pctY = (value.y - rangeY.lowerBound)/(rangeY.upperBound - rangeY.lowerBound)
        return CGSize(width: w*(pctX-0.5), height: h*(pctY-0.5))
    }

    // MARK: Haptics
    private func impactOccured() {
        #if os(macOS)
        #else
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        #endif
    }
    // MARK: View
    public var body: some View {
        ZStack {
            style.makeTrack(configuration: configuration)
            GeometryReader { proxy in
                ZStack(alignment: .center) {
                    self.style.makeThumb(configuration: self.configuration)
                        .offset(self.thumbOffset(proxy))
                        .gesture(
                            DragGesture(minimumDistance: 0, coordinateSpace: .named(self.space))
                                .onChanged({
                                    self.constrainValue(proxy, $0.location)
                                    self.isActive = true
                                })
                                .onEnded({
                                    self.constrainValue(proxy, $0.location)
                                    self.isActive = false
                                }))

                }.frame(width: proxy.size.width, height: proxy.size.height)
            }
        }.coordinateSpace(name: space)
    }
}
