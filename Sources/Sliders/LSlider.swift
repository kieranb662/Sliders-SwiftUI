//
//  LSlider.swift
//  MyExamples
//
//  Created by Kieran Brown on 4/6/20.
//  Copyright © 2020 BrownandSons. All rights reserved.
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
    var thickness: Double
    
    public init(thickness: Double = 40) {
        self.thickness = thickness
    }
    
    public func makeThumb(configuration:  LSliderConfiguration) -> some View {
        Circle()
            .fill(configuration.isActive ? Color.yellow : Color.cyan)
            .frame(width: thickness, height: thickness)
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
            ? thickness * (1 - configuration.pctFill)
            : thickness / 2

        return ZStack {
            AdaptiveLine(thickness: thickness, angle: configuration.angle)
                .fill(.gray)
            
            AdaptiveLine(
                thickness: thickness,
                angle: configuration.angle,
                percentFilled: configuration.pctFill,
                adjustmentForThumb: adjustment
            )
            .fill(Color.blue)
            .mask(AdaptiveLine(thickness: thickness, angle: configuration.angle))
        }
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
public struct LSlider: View {
    // MARK: State and Setup
    @Environment(\.linearSliderStyle) private var style: AnyLSliderStyle
    @State private var isActive: Bool = false
    @State private var atLimit: Bool = false
    private let space: String = "Slider"
    // MARK: Input
    @Binding private var value: Double
    private var range: ClosedRange<Double> = 0...1
    private var angle: Angle = .zero
    private var isDisabled: Bool = false
    private var keepThumbInTrack: Bool = false
    private var trackThickness: Double = 40

    public init(_ value: Binding<Double>, range: ClosedRange<Double>, angle: Angle, isDisabled: Bool = false, keepThumbInTrack: Bool = false, trackThickness: Double = 40) {
        self._value = value
        self.range = range
        self.angle = angle
        self.isDisabled = isDisabled
        self.keepThumbInTrack = keepThumbInTrack
        self.trackThickness = trackThickness
    }
    
    public init(_ value: Binding<Double>, range: ClosedRange<Double>, isDisabled: Bool = false, keepThumbInTrack: Bool = false, trackThickness: Double = 40) {
        self._value = value
        self.range = range
        self.isDisabled = isDisabled
        self.keepThumbInTrack = keepThumbInTrack
        self.trackThickness = trackThickness
    }
    
    public init(_ value: Binding<Double>, angle: Angle, isDisabled: Bool = false, keepThumbInTrack: Bool = false, trackThickness: Double = 40) {
        self._value = value
        self.angle = angle
        self.isDisabled = isDisabled
        self.keepThumbInTrack = keepThumbInTrack
        self.trackThickness = trackThickness
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
        
        let x1 = w/2 + big*CGFloat(cos(angle.radians))
        let y1 = h/2 + big*CGFloat(sin(angle.radians))
        let x2 = w/2 - big*CGFloat(cos(angle.radians))
        let y2 = h/2 - big*CGFloat(sin(angle.radians))
        let points = lineRectIntersection(x1, y1, x2, y2, 0, 0, w, h)
        if points.count < 2 {
            return (.zero, .zero)
        }
        
        var start = points[0]
        var end   = points[1]
        
        // When keepThumbInTrack is true, shrink the travel range by half the track
        // thickness on each side so the thumb center stays within the track's extent.
        if keepThumbInTrack {
            let inset = CGFloat(trackThickness / 2)
            let dx = CGFloat(cos(angle.radians))
            let dy = CGFloat(sin(angle.radians))
            start = CGPoint(x: start.x + inset * dx, y: start.y + inset * dy)
            end   = CGPoint(x: end.x   - inset * dx, y: end.y   - inset * dy)
        }
        
        return (start, end)
    }
    
    private func thumbOffset(_ proxy: GeometryProxy) -> CGSize {
        let ends = calculateEndPoints(proxy)
        let value = (value-range.lowerBound)/(range.upperBound - range.lowerBound)
        let x = (1-value)*Double(ends.start.x) + value*Double(ends.end.x) - Double(proxy.size.width/2)
        let y = (1-value)*Double(ends.start.y) + value*Double(ends.end.y) - Double(proxy.size.height/2)
        return CGSize(width: x, height: y)
    }
    
    private var configuration: LSliderConfiguration {
        LSliderConfiguration(
            isDisabled: isDisabled,
            isActive: isActive,
            pctFill: (value - range.lowerBound) / (range.upperBound - range.lowerBound),
            value: value,
            angle: angle,
            min: range.lowerBound,
            max: range.upperBound,
            keepThumbInTrack: keepThumbInTrack,
            trackThickness: trackThickness
        )
    }
    
    // MARK: Haptics
    private func impactOccured() {
#if os(iOS)
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
        DragGesture(minimumDistance: 10, coordinateSpace: .named(space))
            .onChanged({ drag in
                let (start, end) = calculateEndPoints(proxy)
                let parameter = Double(calculateParameter(start, end, drag.location))
                impactHandler(parameter == 1 || parameter == 0)
                value = (range.upperBound-range.lowerBound)*parameter + range.lowerBound
                isActive = true
            })
            .onEnded({ (drag) in
                let (start, end) = calculateEndPoints(proxy)
                let parameter = Double(calculateParameter(start, end, drag.location))
                impactHandler(parameter == 1 || parameter == 0)
                value = (range.upperBound-range.lowerBound)*parameter + range.lowerBound
                isActive = false
            })
    }
    
    // MARK: View
    public var body: some View {
        GeometryReader { geo in
            ZStack {
                style.makeTrack(configuration: configuration)
                
                style.makeThumb(configuration: configuration)
                    .offset(thumbOffset(geo))
                    .gesture(makeGesture(geo))
                    .allowsHitTesting(!isDisabled)
            }
            .coordinateSpace(name: space)
        }
    }
}


fileprivate struct LSliderExamples: View {
    @State var value = 0.5
    
    var body: some View {
        VStack {
            LSlider($value, range: 0...1, angle: Angle(degrees: 45), keepThumbInTrack: true, trackThickness: 40)
                .border(Color.red)
            
            LSlider($value, range: 0...1, keepThumbInTrack: true, trackThickness: 40)
        }
        .padding(20)
    }
}

#Preview {
    LSliderExamples()
}
