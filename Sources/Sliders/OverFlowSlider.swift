//
//  OverflowSlider.swift
//  MyExamples
//
//  Created by Kieran Brown on 3/25/20.
//  Copyright © 2020 BrownandSons. All rights reserved.
//

import SwiftUI
import Shapes

@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public struct OverflowSliderConfiguration {
    /// Whether the control is disabled or not
    public let isDisabled: Bool
    /// Whether the thumb is currently dragging or not
    public let thumbIsActive: Bool
    /// Whether the thumb has reached its min/max displacement
    public let thumbIsAtLimit: Bool
    /// Whether of not the track is dragging
    public let trackIsActive: Bool
    /// Whether the track has reached its min/max position
    public let trackIsAtLimit: Bool
    /// The current value of the slider
    public let value: Double
    /// The minimum value of the sliders range
    public let min: Double
    /// The maximum value of the sliders range
    public let max: Double
    /// The spacing of the sliders tick marks
    public let tickSpacing: Double
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public protocol OverflowSliderStyle {
    associatedtype Track: View
    associatedtype Thumb: View
    
    func makeTrack(configuration: OverflowSliderConfiguration) -> Self.Track
    func makeThumb(configuration: OverflowSliderConfiguration) -> Self.Thumb
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
extension OverflowSliderStyle {
    func makeTrackTypeErased(configuration: OverflowSliderConfiguration) -> AnyView {
        AnyView(self.makeTrack(configuration: configuration))
    }
    func makeThumbTypeErased(configuration: OverflowSliderConfiguration) -> AnyView {
        AnyView(self.makeThumb(configuration: configuration))
    }
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public struct AnyOverflowSliderStyle: OverflowSliderStyle {
    private let _makeTrack: (OverflowSliderConfiguration) -> AnyView
    public func makeTrack(configuration: OverflowSliderConfiguration) -> some View {
        return self._makeTrack(configuration)
    }
    private let _makeThumb: (OverflowSliderConfiguration) -> AnyView
    public func makeThumb(configuration: OverflowSliderConfiguration) -> some View {
        return self._makeThumb(configuration)
    }
    
    init<S: OverflowSliderStyle>(_ style: S) {
        self._makeTrack = style.makeTrackTypeErased
        self._makeThumb = style.makeThumbTypeErased
    }
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public struct DefaultOverflowSliderStyle: OverflowSliderStyle {
    public init() { } 
    public func makeTrack(configuration: OverflowSliderConfiguration) -> some View {
        let totalLength = configuration.max-configuration.min
        let spacing = configuration.tickSpacing
        
        return TickMarks(spacing: CGFloat(spacing), ticks: Int(totalLength/Double(spacing)))
            .stroke(Color.gray)
            .frame(width: CGFloat(totalLength))
    }
    public func makeThumb(configuration: OverflowSliderConfiguration) -> some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(configuration.thumbIsActive ?  Color.orange : Color.blue)
            .opacity(0.5)
            .frame(width: 20, height: 50)
    }
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public struct OverflowSliderStyleKey: EnvironmentKey {
    public static let defaultValue: AnyOverflowSliderStyle  = AnyOverflowSliderStyle(DefaultOverflowSliderStyle())
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
extension EnvironmentValues {
    public var overflowSliderStyle: AnyOverflowSliderStyle {
        get {
            return self[OverflowSliderStyleKey.self]
        }
        set {
            self[OverflowSliderStyleKey.self] = newValue
        }
    }
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
extension View {
    public func overflowSliderStyle<S>(_ style: S) -> some View where S: OverflowSliderStyle {
        self.environment(\.overflowSliderStyle, AnyOverflowSliderStyle(style))
    }
}


/// # Overflow Slider
///
/// A Slider which has a fixed frame but a movable track in the background. Used for values that have a discrete nature to them but would not necessarily fit on screen.
/// Both the thumb and track can be dragged, if the track is dragged and thrown the velocity of the throw is added to the tracks velocity and it slows gradually to a stop.
/// If the thumb is currently being dragged and reachs the minimum or maximum value of its bounds, velocity is added to the track in the opposite direction of the drag. 
///
/// - parameters:
///     - value: `Binding<Double>` The value the slider should control
///     - range: `ClosedRange<Double>` The minimum and maximum numbers that `value` can be
///     - isDisabled: `Bool` Whether or not the slider should be disabled
///
///
/// ## Styling The Slider
///
/// To create a custom style for the slider you need to create a `OverflowSliderStyle` conforming struct. Conformnance requires implementation of 2 methods
///     1. `makeThumb`: which creates the draggable portion of the slider
///     2. `makeTrack`: which creates the draggable background track
///
/// Both methods provide access to the sliders current state thru the `OverflowSliderConfiguration` of the `OverflowSlider `to be styled.
///
///             struct OverflowSliderConfiguration {
///                 let isDisabled: Bool // Whether the control is disabled or not
///                 let thumbIsActive: Bool // Whether the thumb is currently dragging or not
///                 let thumbIsAtLimit: Bool // Whether the thumb has reached its min/max displacement
///                 let trackIsActive: Bool // Whether of not the track is dragging
///                 let trackIsAtLimit: Bool // Whether the track has reached its min/max position
///                 let value: Double // The current value of the slider
///                 let min: Double // The minimum value of the sliders range
///                 let max: Double // The maximum value of the sliders range
///                 let tickSpacing: Double // The spacing of the sliders tick marks
///             }
///
/// To make this easier just copy and paste the following style based on the `DefaultOverflowSliderStyle`. After creating your custom style
///  apply it by calling the `overflowSliderStyle` method on the `OverflowSlider` or a view containing it.
///
///         struct <#My OverflowSlider Style#>: OverflowSliderStyle {
///             func makeThumb(configuration: OverflowSliderConfiguration) -> some View {
///                 RoundedRectangle(cornerRadius: 5)
///                     .fill(configuration.thumbIsActive ?  Color.orange : Color.blue)
///                     .opacity(0.5)
///                     .frame(width: 20, height: 50)
///             }
///             func makeTrack(configuration: OverflowSliderConfiguration) -> some View {
///                 let totalLength = configuration.max-configuration.min
///                 let spacing = configuration.tickSpacing
///
///                 return TickMarks(spacing: CGFloat(spacing), ticks: Int(totalLength/Double(spacing)))
///                     .stroke(Color.gray)
///                     .frame(width: CGFloat(totalLength))
///             }
///         }
///
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public struct OverflowSlider: View {
    private struct ThumbKey: PreferenceKey {
        static var defaultValue: CGRect {  .zero }
        static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
            value = nextValue()
        }
    }
    public enum SliderState {
        case inactive
        case dragging(time: Date, translation: CGFloat, startLocation: CGFloat, velocity: CGFloat)
        
        var isDragging: Bool {
            switch self {
            case .dragging(_, _, _, _): return true
            default: return false
            }
        }
        
        var isActive: Bool {
            switch self {
            case .inactive: return false
            default: return true
            }
        }
        
        var time: Date? {
            switch self {
            case .dragging( let time, _ , _, _):
                return time
            default: return nil
            }
        }
        
        var translation: CGFloat {
            switch self {
            case .dragging(_, let translation , _, _):
                return translation
            default: return .zero
            }
        }
        
        var startLocation: CGFloat? {
            switch self {
            case .dragging(_, _ , let start, _):
                return start
            default: return nil
            }
        }
        
        
        var velocity: CGFloat {
            switch self {
            case .dragging(_ , _ , _, let velocity):
                return velocity
            default: return .zero
            }
        }
    }
    @Environment(\.overflowSliderStyle) private var style: AnyOverflowSliderStyle
    @State private var currentVelocity: CGFloat = 0
    @State private var thumbOffset: CGFloat = 0.5
    @State private var thumbState: CGFloat = 0
    @State private var trackState: SliderState = .inactive
    @State private var trackOffset: CGFloat = 0
    private let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    @Binding public var value: Double
    public let range: ClosedRange<Double>
    public let spacing: Double
    public var isDisabled: Bool = false
    
    public init(value: Binding<Double>, range: ClosedRange<Double>, spacing: Double, isDisabled: Bool) {
        self._value = value
        self.range = range
        self.spacing = spacing
        self.isDisabled = isDisabled
    }
    
    private var configuration: OverflowSliderConfiguration {
        .init(isDisabled: isDisabled,
              thumbIsActive: thumbState != 0,
              thumbIsAtLimit: thumbOffset + thumbState <= 0 || thumbOffset + thumbState >= 1,
              trackIsActive: trackState.isActive,
              trackIsAtLimit: trackState.translation + trackOffset <= 0 || trackState.translation + trackOffset >= 1,
              value: value,
              min: range.lowerBound,
              max: range.upperBound,
              tickSpacing: spacing)
    }
    
    private func thumbHandler() {
        if self.thumbState != 0 {
            if self.thumbOffset + self.thumbState > 1 {
                self.currentVelocity += (self.thumbOffset + self.thumbState)
            } else if self.thumbOffset + self.thumbState < 0 {
                self.currentVelocity -= 1-(self.thumbOffset + self.thumbState)
            } else {
                self.currentVelocity *= 0.97
            }
        } else {
            self.currentVelocity *= 0.97
        }
    }
    private func makeThumb(_ proxy: GeometryProxy) -> some View {
        style.makeThumb(configuration: configuration)
            .allowsHitTesting(false)
            .opacity(0)
            .anchorPreference(key: ThumbKey.self, value: .bounds, transform: { proxy[$0]})
            .overlayPreferenceValue(ThumbKey.self, { (rect)  in
                self.style.makeThumb(configuration: self.configuration)
                    .position(x: (proxy.size.width-rect.width)*min(max(self.thumbState + self.thumbOffset, 0), 1),
                              y: proxy.size.height/2)
                    .offset(x: rect.width/2, y: 0)
                    .gesture(
                        DragGesture()
                            .onChanged({ (value) in
                                self.thumbState = value.translation.width/proxy.size.width
                            }).onEnded({ (value) in
                                self.thumbState = 0
                                self.thumbOffset = min(max(value.translation.width/proxy.size.width + self.thumbOffset, 0), 1)
                            }))
                    .onReceive(self.timer) { (time) in
                        // stop velocity once value reaches limit
                        if self.value == self.range.upperBound || self.value == self.range.lowerBound || abs(self.currentVelocity) < 1 {
                            self.currentVelocity = 0
                        }
                        // allow velocity to displace track while not active
                        if !self.trackState.isActive {
                            self.trackOffset -= self.currentVelocity*0.01
                        }
                        
                        self.thumbHandler()
                        
                        // Update value
                        self.value = max(min(Double(-(self.trackState.translation + self.trackOffset) + (proxy.size.width-rect.width)*(self.thumbState + self.thumbOffset)), self.range.upperBound), self.range.lowerBound)
                }.onAppear {
                    self.trackOffset = -(CGFloat(self.value) - (proxy.size.width-rect.width)*(self.thumbState + self.thumbOffset))
                }
            })
    }
    
    private func calculateVelocity(translation: CGFloat, time: Date) -> CGFloat {
        guard let last = trackState.time else {return .zero}
        let dx = translation-trackState.translation
        let dt = CGFloat(1/last.timeIntervalSince(time))
        return dx*dt
    }
    private func makeTrack(_ proxy: GeometryProxy) -> some View {
        let offset = self.trackState.translation + self.trackOffset
        let w: CGFloat = proxy.size.width/2
        return style.makeTrack(configuration: configuration)
            .contentShape(Rectangle())
            .offset(x: max(min(offset, -CGFloat(range.lowerBound)+w), -CGFloat(range.upperBound)+w), y: 0)
            .offset(x: -CGFloat(range.upperBound - range.lowerBound)/2 )
            .gesture(
                DragGesture(coordinateSpace: .global)
                    .onChanged({ (value) in
                        let velocity = self.calculateVelocity(translation: value.translation.width, time: value.time)
                        self.trackState = .dragging(time: value.time, translation: value.translation.width, startLocation: value.startLocation.x, velocity: velocity)
                    }).onEnded({ (value) in
                        self.currentVelocity += self.trackState.velocity
                        self.trackState = .inactive
                        self.trackOffset += value.translation.width
                        self.trackOffset = max(min(self.trackOffset, CGFloat(-self.range.lowerBound)+proxy.size.width/2), CGFloat(-self.range.upperBound)+proxy.size.width/2)
                        
                    }))
            .animation(.linear)
        
    }
    
    public var body: some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(Color.white.opacity(0.001))
            .allowsHitTesting(false)
            .background(GeometryReader{
                self.makeTrack($0)}
                .padding(.horizontal)
                .allowsHitTesting(!self.isDisabled))
            .overlay(GeometryReader { proxy in
                ZStack {
                    self.makeThumb(proxy)
                        .allowsHitTesting(!self.isDisabled)
                }.offset(x: -proxy.size.width/2)
            })
            .clipped()
    }
}


