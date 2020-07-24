//
//  LSlider.swift
//  MyExamples
//
//  Created by Kieran Brown on 4/6/20.
//  Copyright © 2020 BrownandSons. All rights reserved.
//

import SwiftUI
import Shapes
import CGExtender



// MARK: - LSlider Configuration
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public struct LSliderConfiguration {
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
}
// MARK: - LSlider Style
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public protocol LSliderStyle {
    associatedtype Thumb: View
    associatedtype Track: View
    
    func makeThumb(configuration:  LSliderConfiguration) -> Self.Thumb
    func makeTrack(configuration:  LSliderConfiguration) -> Self.Track
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public extension LSliderStyle {
    func makeThumbTypeErased(configuration:  LSliderConfiguration) -> AnyView {
        AnyView(self.makeThumb(configuration: configuration))
    }
    func makeTrackTypeErased(configuration:  LSliderConfiguration) -> AnyView {
        AnyView(self.makeTrack(configuration: configuration))
    }
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public struct AnyLSliderStyle: LSliderStyle {
    private let _makeThumb: (LSliderConfiguration) -> AnyView
    public func makeThumb(configuration: LSliderConfiguration) -> some View {
        self._makeThumb(configuration)
    }
    private let _makeTrack: (LSliderConfiguration) -> AnyView
    public func makeTrack(configuration: LSliderConfiguration) -> some View  {
        self._makeTrack(configuration)
    }
    
    public init<S: LSliderStyle>(_ style: S) {
        self._makeThumb = style.makeThumbTypeErased
        self._makeTrack = style.makeTrackTypeErased
    }
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public struct LSliderStyleKey: EnvironmentKey {
    public static let defaultValue: AnyLSliderStyle = AnyLSliderStyle(DefaultLSliderStyle())
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
extension EnvironmentValues {
    public var linearSliderStyle: AnyLSliderStyle {
        get {
            return self[LSliderStyleKey.self]
        }
        set {
            self[LSliderStyleKey] = newValue
        }
    }
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
extension View {
    public func linearSliderStyle<S>(_ style: S) -> some View where S: LSliderStyle {
        self.environment(\.linearSliderStyle, AnyLSliderStyle(style))
    }
}
// MARK: - Default LSlider Style
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public struct DefaultLSliderStyle: LSliderStyle {
    public init() {
        
    }
    public func makeThumb(configuration:  LSliderConfiguration) -> some View {
        Circle()
            .fill(configuration.isActive ? Color.yellow : Color.white)
            .frame(width: 40, height: 40)
    }
    
    public func makeTrack(configuration:  LSliderConfiguration) -> some View {
        let style: StrokeStyle = .init(lineWidth: 40, lineCap: .round, lineJoin: .round, miterLimit: 0, dash: [], dashPhase: 0)
        return AdaptiveLine(angle: configuration.angle)
            .stroke(Color.gray, style: style)
            .overlay(AdaptiveLine(angle: configuration.angle).trim(from: 0, to: CGFloat(configuration.pctFill)).stroke(Color.blue, style: style))
    }
}



// MARK: - LSlider
/// # Spatially Adaptive Linear Slider
///
/// While at on the surface this slider my seem like a copy of the already availlable `Slider`. I implore you to try and make a neat layout with a `Slider` in the vertical position.
/// After trying everything with SwiftUI's built in slider I realized making layouts with it just was not going to work. So I created the `LSlider`. It works just like a normal `Slider` except
/// You can provide a value for the angle parameter which rotates the slider and adaptively fits it to its containing view. Also Its fully customizable with cascading styles thanks to Environment variables.
///
/// - parameters:
///     - value: `Binding<Double>` The value the slider should control
///     - range: `ClosedRange<Double>` The minimum and maximum numbers that `value` can be
///     - angle: `Angle` The angle you would like the slider to be at
///     - isDisabled: `Bool` Whether or not the slider should be disabled 
///
/// ## Styling The Slider
///
/// To create a custom style for the slider you need to create a `LSliderStyle` conforming struct. Conformnance requires implementation of 2 methods
///     1. `makeThumb`: which creates the draggable portion of the slider
///     2. `makeTrack`: which creates the track which fills or emptys as the thumb is dragging within it
///
/// Both methods provide access to the sliders current state thru the `LSliderConfiguration` of the `LSlider `to be styled
///
///```
///        struct LSliderConfiguration {
///            let isDisabled: Bool // whether or not the slider is current disables
///            let isActive: Bool // whether or not the thumb is dragging or not
///            let pctFill: Double // The percentage of the sliders track that is filled
///            let value: Double // The current value of the slider
///            let angle: Angle // The angle of the slider
///            let min: Double // The minimum value of the sliders range
///            let max: Double // The maximum value of the sliders range
///        }
/// ```
///
/// To make this easier just copy and paste the following style based on the `DefaultLSliderStyle`. After creating your custom style
///  apply it by calling the `linearSliderStyle` method on the `LSlider` or a view containing it.
///
/// ```
///        struct <#My Slider Style#>: LSliderStyle {
///            func makeThumb(configuration:  LSliderConfiguration) -> some View {
///                Circle()
///                    .fill(configuration.isActive ? Color.yellow : Color.white)
///                    .frame(width: 40, height: 40)
///            }
///            func makeTrack(configuration:  LSliderConfiguration) -> some View {
///                let style: StrokeStyle = .init(lineWidth: 10, lineCap: .round, lineJoin: .round, miterLimit: 0, dash: [], dashPhase: 0)
///                return AdaptiveLine(angle: configuration.angle)
///                    .stroke(Color.gray, style: style)
///                    .overlay(AdaptiveLine(angle: configuration.angle).trim(from: 0, to: CGFloat(configuration.pctFill)).stroke(Color.blue, style: style))
///            }
///        }
///        
/// ```
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public struct LSlider: View {
    // MARK: State and Setup
    @Environment(\.linearSliderStyle) private var style: AnyLSliderStyle
    @State private var isActive: Bool = false
    @State private var atLimit: Bool = false
    private let space: String = "Slider"
    // MARK: Input
    @Binding public var value: Double
    public var range: ClosedRange<Double> = 0...1
    public var angle: Angle = .zero
    public var isDisabled: Bool = false

    public init(_ value: Binding<Double>, range: ClosedRange<Double>, angle: Angle, isDisabled: Bool = false) {
        self._value = value
        self.range = range
        self.angle = angle
        self.isDisabled = isDisabled
    }

    public init(_ value: Binding<Double>, range: ClosedRange<Double>, isDisabled: Bool = false) {
        self._value = value
        self.range = range
        self.isDisabled = isDisabled
    }

    public init(_ value: Binding<Double>, angle: Angle, isDisabled: Bool = false) {
        self._value = value
        self.angle = angle
        self.isDisabled = isDisabled
    }

    public init(_ value: Binding<Double>) {
        self._value = value
    }

    // MARK: Calculations
    // uses an arbitrarily large number to gesture a line segment that is guarenteed to intersect with the
    // bounding box, then finds those points of intersection to be used as the start and end points of the slider
    private func calculateEndPoints(_ proxy: GeometryProxy) -> (start: CGPoint, end: CGPoint) {
        let w = proxy.size.width
        let h = proxy.size.height
        let big: CGFloat = 50000000

        let x1 = w/2 + big*CGFloat(cos(self.angle.radians))
        let y1 = h/2 + big*CGFloat(sin(self.angle.radians))
        let x2 = w/2 - big*CGFloat(cos(self.angle.radians))
        let y2 = h/2 - big*CGFloat(sin(self.angle.radians))
        let points = lineRectIntersection(x1, y1, x2, y2, 0, 0, w, h)
        if points.count < 2 {
            return (.zero, .zero)
        }

        return (points[0], points[1])
    }
    private func thumbOffset(_ proxy: GeometryProxy) -> CGSize {
        let ends = self.calculateEndPoints(proxy)
        let value = (self.value-range.lowerBound)/(range.upperBound - range.lowerBound)
        let x = (1-value)*Double(ends.start.x) + value*Double(ends.end.x) - Double(proxy.size.width/2)
        let y = (1-value)*Double(ends.start.y) + value*Double(ends.end.y) - Double(proxy.size.height/2)
        return CGSize(width: x, height: y)
    }

    private var configuration: LSliderConfiguration {
        .init(isDisabled: isDisabled,
              isActive: isActive,
              pctFill: (value-range.lowerBound)/(range.upperBound-range.lowerBound),
              value: value,
              angle: angle,
              min: range.lowerBound,
              max: range.upperBound)
    }

    // MARK: Haptics
    private func impactOccured() {
        #if os(macOS)
        #else
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        #endif
    }

    private func impactHandler(_ parameterAtLimit: Bool) {
        if parameterAtLimit {
            if !atLimit {
                impactOccured()
            }
            atLimit = true
        } else {
            atLimit = false
        }
    }

    // MARK: - Gesture
    private func makeGesture(_ proxy: GeometryProxy) -> some Gesture {
        DragGesture(minimumDistance: 10, coordinateSpace: .named(self.space))
            .onChanged({ drag in
                let ends = self.calculateEndPoints(proxy)
                let parameter = Double(calculateParameter(ends.start, ends.end, drag.location))
                self.impactHandler(parameter == 1 || parameter == 0)
                self.value = (self.range.upperBound-self.range.lowerBound)*parameter + self.range.lowerBound
                self.isActive = true
            })
            .onEnded({ (drag) in
                let ends = self.calculateEndPoints(proxy)
                let parameter = Double(calculateParameter(ends.start, ends.end, drag.location))
                self.impactHandler(parameter == 1 || parameter == 0)
                self.value = (self.range.upperBound-self.range.lowerBound)*parameter + self.range.lowerBound
                self.isActive = false
            })
    }

    // MARK: View
    public var body: some View {
        ZStack {
            self.style.makeTrack(configuration: self.configuration)
                .overlay(GeometryReader { proxy in
                    ZStack(alignment: .center) {
                        self.style.makeThumb(configuration: self.configuration)
                            .offset(self.thumbOffset(proxy))
                            .gesture(self.makeGesture(proxy))
                            .allowsHitTesting(!self.isDisabled)
                    }.frame(width: proxy.size.width, height: proxy.size.height)
                })
        }
        .coordinateSpace(name: space)
    }
}


