//
//  RadialSlider.swift
//  MyExamples
//
//  Created by Kieran Brown on 3/25/20.
//  Copyright © 2020 BrownandSons. All rights reserved.
//

import SwiftUI

// MARK: - Configuration

public struct RSliderConfiguration {
    /// whether or not the slider is current disables
    public let isDisabled: Bool
    /// whether or not the thumb is dragging or not
    public let isActive: Bool
    /// The percentage of the sliders track that is filled
    public let pctFill: Double
    /// The current value of the slider
    public let value: Double
    ///  The direction from the thumb to the slider center
    public let angle: Angle
    /// The minimum value of the sliders range
    public let min: Double
    /// The maximum value of the sliders range
    public let max: Double
}

// MARK: - Style

public protocol RSliderStyle: Sendable {
    associatedtype Thumb: View
    associatedtype Track: View
    
    func makeThumb(configuration:  RSliderConfiguration) -> Self.Thumb
    func makeTrack(configuration:  RSliderConfiguration) -> Self.Track
}

public extension RSliderStyle {
    func makeThumbTypeErased(configuration:  RSliderConfiguration) -> AnyView {
        AnyView(self.makeThumb(configuration: configuration))
    }
    func makeTrackTypeErased(configuration:  RSliderConfiguration) -> AnyView {
        AnyView(self.makeTrack(configuration: configuration))
    }
}

public struct AnyRSliderStyle: RSliderStyle, Sendable {
    private let _makeThumb: @Sendable (RSliderConfiguration) -> AnyView
    
    public func makeThumb(configuration: RSliderConfiguration) -> some View {
        _makeThumb(configuration)
    }
    
    private let _makeTrack: @Sendable (RSliderConfiguration) -> AnyView
    
    public func makeTrack(configuration: RSliderConfiguration) -> some View  {
        _makeTrack(configuration)
    }
    
    public init<S: RSliderStyle>(_ style: S) {
        self._makeThumb = style.makeThumbTypeErased
        self._makeTrack = style.makeTrackTypeErased
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
    
    public func makeThumb(configuration:  RSliderConfiguration) -> some View {
        Circle()
            .frame(width: 30, height:30)
            .foregroundColor(configuration.isActive ? Color.yellow : Color.white)
    }
    
    public func makeTrack(configuration:  RSliderConfiguration) -> some View {
        ZStack {
            Circle()
                .stroke(Color.gray, style: StrokeStyle(lineWidth: 10, lineCap: .round))
            Circle()
                .trim(from: 0, to: CGFloat(configuration.pctFill))
                .stroke(Color.purple, style: StrokeStyle(lineWidth: 12, lineCap: .round))
        }
    }
}

// MARK: - Knob Style

public struct KnobStyle: RSliderStyle {
    public init() { }
    
    public func makeThumb(configuration: RSliderConfiguration) -> some View {
        let gradient = RadialGradient(gradient: Gradient(colors: [.gray, .white]), center: .center, startRadius: 0 , endRadius: 80)
        return Circle()
            .fill(gradient)
            .frame(width: 40)
            .shadow(radius: 1)
    }
    
    public func makeTrack(configuration: RSliderConfiguration) -> some View {
        Circle().frame(width: 150)
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
                .rotationEffect(Angle(degrees: Double(360*configuration.pctFill)))
                .scaleEffect(1.50))
    }
    
}
// MARK:  Radial Slider


/// # Radial Slider
///  A Circular slider whose thumb is dragged causing it to follow the path of the circle
///
///  - parameters:
///     - value: a  `Binding<Double>` value to be controlled.
///     - range: a `ClosedRange<Double>` denoting the minimum and maximum values of the slider (default is `0...1`)
///     - isDisabled: a `Bool` value describing if the sliders state is disabled (default is `false`)
///
///  ## Styling The Slider
///
///  To create a custom style for the slider you need to create a `RSliderStyle` conforming struct. Conformance requires implementation of 2 methods
///  1.  `makeThumb`: which creates the draggable portion of the slider
///  2.  `makeTrack`: which creates the track which fills or emptys as the thumb is dragging within it
///
/// Both methods provide access to state values of the radial slider thru the  `RSliderConfiguration` struct
///   ```
///        struct RSliderConfiguration {
///            let isDisabled: Bool // whether or not the slider is current disables
///            let isActive: Bool // whether or not the thumb is dragging or not
///            let pctFill: Double // The percentage of the sliders track that is filled
///            let value: Double // The current value of the slider
///            let angle: Angle //  The direction from the thumb to the slider center
///            let min: Double // The minimum value of the sliders range
///            let max: Double // The maximum value of the sliders range
///        }
/// ```
///  To make this easier just copy and paste the following style based on the `DefaultRSliderStyle`. After creating your custom style
///  apply it by calling the `radialSliderStyle` method on the `RSlider` or a view containing it.
///
///    ```
///          struct <#My Slider Style #>: RSliderStyle {
///              func makeThumb(configuration:  RSliderConfiguration) -> some View {
///                  Circle()
///                  .frame(width: 30, height:30)
///                  .foregroundColor(configuration.isActive ? Color.yellow : Color.white)
///              }
///
///              func makeTrack(configuration:  RSliderConfiguration) -> some View {
///                  Circle()
///                  .stroke(Color.gray, style: StrokeStyle(lineWidth: 10, lineCap: .round))
///                  .overlay(Circle()
///                  .trim(from: 0, to: CGFloat(configuration.pctFill))
///                  .stroke(Color.purple, style: StrokeStyle(lineWidth: 12, lineCap: .round)))
///
///              }
///          }
///  ```
///

public struct RSlider: View {
    @Environment(\.radialSliderStyle) private var style: AnyRSliderStyle
    @State private var isActive = false
    @Binding public var value: Double
    public let range: ClosedRange<Double>
    public let isDisabled: Bool
    
    public init(_ value: Binding<Double>, isDisabled: Bool) {
        self._value = value
        self.isDisabled = isDisabled
        self.range = 0...1
    }
    
    public init(_ value: Binding<Double>, range: ClosedRange<Double>) {
        self._value = value
        self.range = range
        self.isDisabled = false
        
    }
    
    public init(_ value: Binding<Double>, range: ClosedRange<Double>, isDisabled: Bool) {
        self._value = value
        self.isDisabled = isDisabled
        self.range = range
    }
    
    public init(_ value: Binding<Double>) {
        self._value = value
        self.range = 0...1
        self.isDisabled = false
    }
    
    private func calculateDirection(_ pt1: CGPoint, _ pt2: CGPoint) -> Double {
        let a = pt2.x - pt1.x
#if os(macOS)
        let b = -(pt2.y - pt1.y)
#else
        let b = pt2.y - pt1.y
#endif
        return Double(atanP(x: a, y: b)/(2 * .pi))
    }
    
    private var configuration: RSliderConfiguration {
        let pct = (value-range.lowerBound)/(range.upperBound-range.lowerBound)
        
        return .init(isDisabled: isDisabled,
                     isActive: isActive,
                     pctFill: pct,
                     value: value,
                     angle: Angle(degrees: pct*360),
                     min: range.lowerBound,
                     max: range.upperBound)
    }
    
    private func makeThumb(_ proxy: GeometryProxy) -> some View {
        let radius = min(proxy.size.height, proxy.size.width)/2
        let middle = CGPoint(x: proxy.frame(in: .global).midX, y: proxy.frame(in: .global).midY)
        
        let gesture = DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .onChanged { (value) in
                let direction = calculateDirection(middle, value.location)
                self.value = direction*(range.upperBound-range.lowerBound) + range.lowerBound
                isActive = true
            }
            .onEnded { (value) in
                let direction = calculateDirection(middle, value.location)
                self.value = direction*(range.upperBound-range.lowerBound) + range.lowerBound
                isActive = false
            }
        let pct = (value-range.lowerBound)/(range.upperBound-range.lowerBound)
        let pX = radius*CGFloat(cos(pct*2 * .pi ))
        let pY = radius*CGFloat(sin(pct*2 * .pi ))
        
        return style.makeThumb(configuration: configuration)
            .offset(x: pX, y: pY)
            .gesture(gesture)
    }
    
    public var body: some View {
        style.makeTrack(configuration: configuration)
            .overlay(GeometryReader { proxy in
                ZStack(alignment: .center) {
                    makeThumb(proxy)
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
            })
            .padding()
    }
}

// MARK: - Double Radial Slider

struct DoubleRSlider: View {
    @Environment(\.radialSliderStyle) private var style: AnyRSliderStyle
    @State public var startState: CGFloat = 0
    @State public var start: CGFloat = 0
    @State public var endState: CGFloat = 0
    @State public var end: CGFloat = 0.5
    private var e: CGFloat { endState + end }
    private var s: CGFloat { startState + start }
    private var configuration: RSliderConfiguration {
        .init(isDisabled: false,
              isActive: startState != 0 || endState != 0,
              pctFill: Double(s > e ? e+(1-s) : e-s),
              value: 0,
              angle: .zero,
              min: 0,
              max: 1)
    }
    
    public init() {}
    
    public func makeThumbs(_ proxy: GeometryProxy) -> some View {
        let radius = min(proxy.size.height, proxy.size.width)/2
        let middle = CGPoint(x: proxy.frame(in: .global).midX, y: proxy.frame(in: .global).midY)
        let upperGesture = DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .onChanged { (value) in
                endState = calculateDirection(middle, value.location) - end
            }
            .onEnded { (value) in
                endState = 0
                end = calculateDirection(middle, value.location)
            }
        
        let lowerGesture = DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .onChanged { (value) in
                startState = calculateDirection(middle, value.location) - start
            }
            .onEnded { (value) in
                startState = 0
                start = calculateDirection(middle, value.location)
            }
        
        let pX = radius*cos(e*2 * .pi)
        let pY = radius*sin(e*2 * .pi )
        
        return Group {
            style.makeThumb(configuration: configuration)
                .offset(x: pX, y: pY)
                .gesture(upperGesture)
            
            style.makeThumb(configuration: configuration)
                .offset(x: radius, y: 0)
                .gesture(lowerGesture)
                .rotationEffect(Angle(radians: Double((s)*2*CGFloat.pi)))
            
        }
    }
    
    public func calculateDirection(_ pt1: CGPoint, _ pt2: CGPoint) -> CGFloat {
        let a = pt2.x - pt1.x
        let b = pt2.y - pt1.y
        
        return CGFloat(atanP(x: a, y: b) )/(2 * .pi)
    }
    
    public var body: some View {
        style.makeTrack(configuration: configuration)
            .rotationEffect(Angle(radians: Double(s*2*CGFloat.pi)))
            .overlay(GeometryReader { proxy in
                ZStack {
                    makeThumbs(proxy)
                }
            })
            .padding()
    }
}

