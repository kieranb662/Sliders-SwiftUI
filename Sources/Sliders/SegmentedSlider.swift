//
//  SegmentedSlider.swift
//  MyExamples
//
//  Created by Kieran Brown on 3/25/20.
//  Copyright © 2020 BrownandSons. All rights reserved.
//

import SwiftUI
import Shapes

@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public struct SegmentedSliderConfiguration {
    public let isDisabled: Bool
    
    public let thumbIsActive: Bool
    public let thumbInDragging: Bool
    public let thumbIsAtLimit: Bool
    
    public let trackIsActive: Bool
    public let trackIsAtLimit: Bool
    
    public let value: Double
    public let min: Double
    public let max: Double
    public let tickSpacing: Double
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public protocol SegmentedSliderStyle {
    
    associatedtype Track: View
    associatedtype Thumb: View
    
    func makeTrack(configuration: SegmentedSliderConfiguration) -> Self.Track
    func makeThumb(configuration: SegmentedSliderConfiguration) -> Self.Thumb
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
extension SegmentedSliderStyle {
    
    func makeTrackTypeErased(configuration: SegmentedSliderConfiguration) -> AnyView {
        AnyView(self.makeTrack(configuration: configuration))
    }
    func makeThumbTypeErased(configuration: SegmentedSliderConfiguration) -> AnyView {
        AnyView(self.makeThumb(configuration: configuration))
    }
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public struct AnySegmentedSliderStyle: SegmentedSliderStyle {
    private let _makeTrack: (SegmentedSliderConfiguration) -> AnyView
    public func makeTrack(configuration: SegmentedSliderConfiguration) -> some View {
        return self._makeTrack(configuration)
    }
    
    private let _makeThumb: (SegmentedSliderConfiguration) -> AnyView
    public func makeThumb(configuration: SegmentedSliderConfiguration) -> some View {
        return self._makeThumb(configuration)
    }
    
    init<ST: SegmentedSliderStyle>(_ style: ST) {
        self._makeTrack = style.makeTrackTypeErased
        self._makeThumb = style.makeThumbTypeErased
        
    }
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public struct DefaultSegmentedSliderStyle: SegmentedSliderStyle {
    public init() { } 
    public func makeTrack(configuration: SegmentedSliderConfiguration) -> some View {
        let totalLength = configuration.max-configuration.min
        let spacing = configuration.tickSpacing
        
        return TickMarks(spacing: CGFloat(spacing), ticks: Int(totalLength/Double(spacing)))
            .stroke(Color.gray)
            .frame(width: CGFloat(totalLength))
    }
    public func makeThumb(configuration: SegmentedSliderConfiguration) -> some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(configuration.thumbIsActive ?  Color.orange : Color.blue)
            .opacity(0.5)
            .frame(width: 20, height: 50)
    }
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public struct SegmentedSliderStyleKey: EnvironmentKey {
    public static let defaultValue: AnySegmentedSliderStyle  = AnySegmentedSliderStyle(DefaultSegmentedSliderStyle())
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
extension EnvironmentValues {
    public var segmentedSliderStyle: AnySegmentedSliderStyle {
        get {
            return self[SegmentedSliderStyleKey.self]
        }
        set {
            self[SegmentedSliderStyleKey.self] = newValue
        }
    }
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
extension View {
    public func segmentedSliderStyle<S>(_ style: S) -> some View where S: SegmentedSliderStyle {
        self.environment(\.segmentedSliderStyle, AnySegmentedSliderStyle(style))
    }
}


/// # Segmented Slider
///
/// A slider
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public struct SegmentedSlider: View {
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
    @Environment(\.segmentedSliderStyle) private var style: AnySegmentedSliderStyle
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
    
    private var configuration: SegmentedSliderConfiguration {
        .init(isDisabled: isDisabled,
              thumbIsActive: thumbState != 0,
              thumbInDragging: thumbState != 0,
              thumbIsAtLimit: thumbOffset + thumbState <= 0 || thumbOffset + thumbState >= 1,
              trackIsActive: trackState.isActive,
              trackIsAtLimit: trackState.translation + trackOffset <= 0 || trackState.translation + trackOffset >= 1,
              value: value,
              min: range.lowerBound,
              max: range.upperBound,
              tickSpacing: spacing)
    }
    
    private func thumbHandler() {
        // Thumb handling
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
            .background(GeometryReader{ self.makeTrack($0)}.padding(.horizontal))
            .overlay(GeometryReader { proxy in
                ZStack {
                    self.makeThumb(proxy)
                }.offset(x: -proxy.size.width/2)
            })
            .clipped()
    }
}


