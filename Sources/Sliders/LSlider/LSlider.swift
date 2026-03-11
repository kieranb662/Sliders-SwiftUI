//
//  LSlider.swift
//  MyExamples
//
//  Created by Kieran Brown on 4/6/20.
//  Copyright © 2020 BrownandSons. All rights reserved.
//

import SwiftUI




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
        let w = Double(proxy.size.width)
        let h = Double(proxy.size.height)
        let T = trackThickness

        let θ = angle.radians
        let absCos = abs(cos(θ))
        let absSin = abs(sin(θ))
        let epsilon: Double = 1e-10

        // Match AdaptiveLine's capsule length formula exactly
        let capsuleMaxFromWidth:  Double = absCos > epsilon ? (w - T) / absCos + T : .infinity
        let capsuleMaxFromHeight: Double = absSin > epsilon ? (h - T) / absSin + T : .infinity
        let capsuleLength = max(0, min(capsuleMaxFromWidth, capsuleMaxFromHeight))

        // The two cap centres are half a capsule-length apart along the angle axis.
        // When keepThumbInTrack the thumb travels between those cap centres (inset T/2 from each end).
        // When not keepThumbInTrack the thumb travels the full capsule length (end-to-end).
        let halfTravel: Double
        if keepThumbInTrack {
            halfTravel = (capsuleLength - T) / 2   // cap-centre to cap-centre, halved
        } else {
            halfTravel = capsuleLength / 2          // full end to full end, halved
        }

        let cx = w / 2
        let cy = h / 2
        let dx = cos(θ)
        let dy = sin(θ)

        // "start" is the low-value end (parameter 0), "end" is the high-value end (parameter 1).
        // AdaptiveLine draws left→right in its local frame before rotation, so the
        // negative-cos direction corresponds to the start of the fill.
        let start = CGPoint(x: cx - halfTravel * dx, y: cy - halfTravel * dy)
        let end   = CGPoint(x: cx + halfTravel * dx, y: cy + halfTravel * dy)

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
            LSlider($value, range: 0...1, angle: Angle(degrees: 325), keepThumbInTrack: true, trackThickness: 40)
                .border(Color.red)
            
            LSlider($value, range: 0...1, keepThumbInTrack: true, trackThickness: 40)
        }
        .padding(20)
    }
}

#Preview {
    LSliderExamples()
}
