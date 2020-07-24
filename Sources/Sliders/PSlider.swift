//
//  PSlider.swift
//  MyExamples
//
//  Created by Kieran Brown on 4/6/20.
//  Copyright © 2020 BrownandSons. All rights reserved.
//

import SwiftUI
import Shapes
import bez

// MARK: - Configuration
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public struct PSliderConfiguration {
    /// whether or not the slider is current disables
    public let isDisabled: Bool
    /// whether or not the thumb is dragging or not
    public let isActive: Bool
    /// The percentage of the sliders track that is filled
    public let pctFill: Double
    /// The current value of the slider
    public let value: Double
    ///  The direction between the current thumb location and the next sampled point
    public let angle: Angle
    /// The minimum value of the sliders range
    public let min: Double
    /// The maximum value of the sliders range
    public let max: Double
    /// The shape of the slider 
    public let shape: AnyShape
}
// MARK: - Style
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public protocol PSliderStyle {
    associatedtype Thumb: View
    associatedtype Track: View
    
    func makeThumb(configuration:  PSliderConfiguration) -> Self.Thumb
    func makeTrack(configuration:  PSliderConfiguration) -> Self.Track
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public extension PSliderStyle {
    func makeThumbTypeErased(configuration:  PSliderConfiguration) -> AnyView {
        AnyView(self.makeThumb(configuration: configuration))
    }
    func makeTrackTypeErased(configuration:  PSliderConfiguration) -> AnyView {
        AnyView(self.makeTrack(configuration: configuration))
    }
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public struct AnyPSliderStyle: PSliderStyle {
    private let _makeThumb: (PSliderConfiguration) -> AnyView
    public func makeThumb(configuration: PSliderConfiguration) -> some View {
        self._makeThumb(configuration)
    }
    private let _makeTrack: (PSliderConfiguration) -> AnyView
    public func makeTrack(configuration: PSliderConfiguration) -> some View  {
        self._makeTrack(configuration)
    }
    public init<S: PSliderStyle>(_ style: S) {
        self._makeThumb = style.makeThumbTypeErased
        self._makeTrack = style.makeTrackTypeErased
    }
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public struct PSliderStyleKey: EnvironmentKey {
    public static let defaultValue: AnyPSliderStyle = AnyPSliderStyle(DefaultPSliderStyle())
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
extension EnvironmentValues {
    public var pathSliderStyle: AnyPSliderStyle {
        get {
            return self[PSliderStyleKey.self]
        }
        set {
            self[PSliderStyleKey] = newValue
        }
    }
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
extension View {
    public func pathSliderStyle<S>(_ style: S) -> some View where S: PSliderStyle {
        self.environment(\.pathSliderStyle, AnyPSliderStyle(style))
    }
}
// MARK: - Default Style
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public struct DefaultPSliderStyle: PSliderStyle {
    public init() {}
    
    public func makeThumb(configuration:  PSliderConfiguration) -> some View {
        Circle()
            .frame(width: 30, height:30)
            .foregroundColor(configuration.isActive ? Color.yellow : Color.white)
    }
    public func makeTrack(configuration:  PSliderConfiguration) -> some View {
        ZStack {
            configuration.shape
                .stroke(Color.gray, lineWidth: 8)
            configuration.shape
                .trim(from: 0, to: CGFloat(configuration.pctFill))
                .stroke(Color.purple, lineWidth: 10)
        }
    }
}



/// # Path Slider
/// A View that turns any `Shape` into a slider. Its great for creating unique user experiences 
///
/// - parameters:
///     - value: a `Binding<Double>` value which represents the percent fill of the slider between  (0,1).
///     - shape: The `Shape` to be used as the sliders track
///     - range: `ClosedRange<Double>` The minimum and maximum numbers that `value` can be
///     - isDisabled: `Bool` Whether or not the slider should be disabled
///
/// ## Styling The Slider
///
/// To create a custom style for the slider you need to create a `PSliderStyle` conforming struct. Conformnance requires implementation of 2 methods
///     1. `makeThumb`: which creates the draggable portion of the slider
///     2. `makeTrack`: which creates the track which fills or emptys as the thumb is dragging within it
///
/// Both methods provide access to state values through the `PSliderConfiguration` struct
///
///     struct PSliderConfiguration {
///         let isDisabled: Bool // whether or not  the slider is disabled
///         let isActive: Bool // whether or not the thumb is currently dragging
///         let pctFill: Double  // The percentage of the sliders track that is filled
///         let value: Double // The current value of the slider
///         let angle: Angle // Angle of the thumb
///         let min: Double  // The minimum value of the sliders range
///         let max: Double // The maximum value of the sliders range
///     }
///
/// To make this easier just copy and paste the following style based on the `DefaultPSliderStyle`. After creating your custom style
///  apply it by calling the `pathSliderStyle` method on the `PSlider` or a view containing it.
///
/// ```
///     struct <#My PSlider Style#>: PSliderStyle {
///         func makeThumb(configuration:  PSliderConfiguration) -> some View {
///             Circle()
///             .frame(width: 30, height:30)
///             .foregroundColor(configuration.isActive ? Color.yellow : Color.white)
///         }
///
///         func makeTrack(configuration:  PSliderConfiguration) -> some View {
///             configuration.shape
///                 .stroke(Color.gray, lineWidth: 8)
///                 .overlay(
///                     configuration.shape
///                     .trim(from: 0, to: CGFloat(configuration.pctFill))
///                 .stroke(Color.purple, lineWidth: 10))
///         }
///     }
/// ```
///
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public struct PSlider<S: Shape>: View {
    enum DragState {
        case inactive
        case dragging(translation: CGSize)
        
        var translation: CGSize {
            switch self {
            case .inactive:
                return .zero
            case .dragging(let translation):
                return translation
            }
        }
        
        var isActive: Bool {
            switch self {
            case .inactive:
                return false
            case .dragging:
                return true
            }
        }
    }
    @Environment(\.pathSliderStyle) private var style: AnyPSliderStyle
    private let space: String = "Follow"
    
    @State private var dragState: DragState = .inactive
    @Binding public var value: Double
    public var shape: S
    public var range: ClosedRange<Double>
    public var isDisabled: Bool
    
    public init(_ value: Binding<Double>, shape: S) {
        self._value = value
        self.shape = shape
        self.range = 0...1
        self.isDisabled = false
    }
    public init(_ value: Binding<Double>, range: ClosedRange<Double>, shape: S) {
        self._value = value
        self.shape = shape
        self.range = range
        self.isDisabled = false
    }
    public init(_ value: Binding<Double>, range: ClosedRange<Double>, shape: S, isDisabled: Bool) {
        self._value = value
        self.shape = shape
        self.isDisabled = isDisabled
        self.range = range
    }
    public init(_ value: Binding<Double>, shape: S, isDisabled: Bool) {
        self._value = value
        self.shape = shape
        self.isDisabled = isDisabled
        self.range = 0...1
    }
    
    struct PThumb: View {
        
        @State private var position: CGPoint = .zero
        @Environment(\.pathSliderStyle) private var style: AnyPSliderStyle
        private let space: String = "Follow"
        @Binding var dragState: PSlider.DragState
        @Binding public var value: Double
        public let lookUpTable: [CGPoint]
        public let range: ClosedRange<Double>
        public let isDisabled: Bool
        public let shape: AnyShape
        
        func getDisplacement(closestPoint: CGPoint) -> CGSize {
            return CGSize(width: closestPoint.x - position.x, height: closestPoint.y - position.y)
        }
        func calculateDirection(_ pt1: CGPoint, _ pt2: CGPoint) -> Angle {
            let a = pt2.x - pt1.x
            let b = pt2.y - pt1.y
            
            let angle = a < 0 ? atan(Double(b / a)) : atan(Double(b / a)) - Double.pi
            return Angle(radians: angle)
        }
        var angle: Angle {
            let num = Int(getPercent(self.position + self.dragState.translation.toPoint(), lookupTable: self.lookUpTable)*CGFloat(lookUpTable.count))
            if self.lookUpTable.count < 3 {
                return .zero
            }
            if num > lookUpTable.count-2 {
                return calculateDirection(lookUpTable[num-2], lookUpTable[num-1])
            } else {
                return calculateDirection(lookUpTable[num], lookUpTable[num+1])
            }
        }
        var configuration: PSliderConfiguration {
            .init(isDisabled: isDisabled,
                  isActive: dragState.isActive,
                  pctFill: value,
                  value: value,
                  angle: angle,
                  min: range.lowerBound,
                  max: range.upperBound,
                  shape: shape)
        }
        
        var body: some View {
            style
                .makeThumb(configuration: self.configuration)
                .position(position)
                .offset(dragState.translation)
                .gesture(self.dragGesture)
                .onAppear {
                    let num = self.value*Double(self.lookUpTable.count)
                    self.position = self.lookUpTable[Int(num)]
            }
        }

        private var dragGesture: some Gesture {
            DragGesture(minimumDistance: 0, coordinateSpace: .named(space))
                .onChanged({ (drag) in
                    let closestPoint = getClosestPoint(drag.location , lookupTable: self.lookUpTable)
                    self.dragState = .dragging(translation: self.getDisplacement(closestPoint: closestPoint))
                    self.value = Double(getPercent(closestPoint, lookupTable: self.lookUpTable))*(self.range.upperBound-self.range.lowerBound) + self.range.lowerBound
                })
                .onEnded { drag in
                    let closestPoint = getClosestPoint(drag.location, lookupTable: self.lookUpTable)
                    self.value = Double(getPercent(closestPoint, lookupTable: self.lookUpTable))*(self.range.upperBound-self.range.lowerBound) + self.range.lowerBound
                    let displacement = self.getDisplacement(closestPoint: closestPoint)
                    self.position.x += displacement.width
                    self.position.y += displacement.height
                    self.dragState = .inactive
        }
        }
    }
    
    private func makeThumb(_ proxy: GeometryProxy) -> some View {
        let rect = proxy.frame(in: .global) != .zero ? proxy.frame(in: .local) : CGRect(x: 0, y: 0, width: 100, height: 100)
        return PThumb(dragState: $dragState,
                      value: $value,
                      lookUpTable: generateLookupTable(path: shape.path(in: rect)),
                      range: range,
                      isDisabled: self.isDisabled,
                      shape: AnyShape(shape))
    }
    
    var configuration: PSliderConfiguration {
        .init(isDisabled: isDisabled,
              isActive: dragState.isActive,
              pctFill: (value-range.lowerBound)/(range.upperBound-range.lowerBound),
              value: value,
              angle: .zero,
              min: range.lowerBound,
              max: range.upperBound,
              shape: AnyShape(shape))
    }
    
    public var body: some View {
        GeometryReader { proxy in
            self.style.makeTrack(configuration: self.configuration)
                .overlay(
                    self.makeThumb(proxy)
            ).coordinateSpace(name: "Follow")
        }
    }
}
