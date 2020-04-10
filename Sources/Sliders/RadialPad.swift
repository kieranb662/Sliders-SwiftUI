//
//  RadialPad.swift
//  MyExamples
//
//  Created by Kieran Brown on 4/7/20.
//  Copyright © 2020 BrownandSons. All rights reserved.
//

import SwiftUI
import CGExtender

// MARK: - Style
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public struct RadialPadConfiguration {
    public let isActive: Bool
    public let isAtLimit: Bool
    public let angle: Angle
    public let radialOffset: Double
    
    public init(_ isActive: Bool , _ isAtLimit: Bool, _ angle: Angle, _ radialOffset: Double) {
        self.isActive = isActive
        self.isAtLimit = isAtLimit
        self.angle = angle
        self.radialOffset = radialOffset
    }
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public protocol RadialPadStyle {
    associatedtype Track: View
    associatedtype Thumb: View
    
    func makeTrack(configuration: RadialPadConfiguration) -> Self.Track
    func makeThumb(configuration: RadialPadConfiguration) -> Self.Thumb
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public extension RadialPadStyle {
    func makeTrackTypeErased(configuration: RadialPadConfiguration) -> AnyView {
        AnyView(self.makeTrack(configuration: configuration))
    }
    func makeThumbTypeErased(configuration: RadialPadConfiguration) -> AnyView {
        AnyView(self.makeThumb(configuration: configuration))
    }
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public struct AnyRadialPadStyle: RadialPadStyle {
    private let _makeTrack: (RadialPadConfiguration) -> AnyView
    public func makeTrack(configuration: RadialPadConfiguration) -> some View {
        return self._makeTrack(configuration)
    }
    
    private let _makeThumb: (RadialPadConfiguration) -> AnyView
    public func makeThumb(configuration: RadialPadConfiguration) -> some View {
        return self._makeThumb(configuration)
    }
    
    public init<ST: RadialPadStyle>(_ style: ST) {
        self._makeTrack = style.makeTrackTypeErased
        self._makeThumb = style.makeThumbTypeErased
    }
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public struct DefaultRadialPadStyle: RadialPadStyle {
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
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public struct RadialPadStyleKey: EnvironmentKey {
    public static let defaultValue: AnyRadialPadStyle  = AnyRadialPadStyle(DefaultRadialPadStyle())
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
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
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
extension View {
    public func radialPadStyle<S>(_ style: S) -> some View where S: RadialPadStyle {
        self.environment(\.radialPadStyle, AnyRadialPadStyle(style))
    }
}

@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public struct RadialPad: View {
    @Environment(\.radialPadStyle) private var style: AnyRadialPadStyle
    private let space: String = "Radial Pad"
    @Binding public var offset: Double
    @Binding public var angle: Angle
    @State private var isActive: Bool = false
    public init(offset: Binding<Double>, angle: Binding<Angle>) {
        self._offset = offset
        self._angle = angle
    }
    
    private func thumbOffset(_ proxy: GeometryProxy) -> CGSize {
        let radius = Double(proxy.size.width > proxy.size.height ? proxy.size.height/2 : proxy.size.width/2)
        let pX = radius*offset*cos(angle.radians)
        let pY = radius*offset*sin(angle.radians)
        return CGSize(width: pX, height: pY)
    }
    private var configuration: RadialPadConfiguration {
        return .init(isActive, offset == 1, angle, offset)
    }
    
    public var body: some View {
        ZStack {
            style.makeTrack(configuration: configuration)
                .overlay(GeometryReader { proxy in
                    ZStack {
                        self.style.makeThumb(configuration: self.configuration)
                            .offset(self.thumbOffset(proxy))
                            .gesture(
                                DragGesture(minimumDistance: 0, coordinateSpace: .named(self.space))
                                    .onChanged({
                                        let middle = CGPoint(x: proxy.size.width/2, y: proxy.size.height/2)
                                        let radius = Double(proxy.size.width > proxy.size.height ? proxy.size.height/2 : proxy.size.width/2)
                                        let off = sqrt((middle - $0.location).magnitudeSquared)
                                        self.offset = min(radius, off)/radius
                                        self.angle = Angle(degrees: calculateDirection(middle, $0.location)*360)
                                        self.isActive = true
                                    })
                                    .onEnded({
                                        let middle = CGPoint(x: proxy.size.width/2, y: proxy.size.height/2)
                                        let radius = Double(proxy.size.width > proxy.size.height ? proxy.size.height/2 : proxy.size.width/2)
                                        let off = sqrt((middle - $0.location).magnitudeSquared)
                                        self.offset = min(radius, off)/radius
                                        self.angle = Angle(degrees: calculateDirection(middle, $0.location)*360)
                                        self.isActive = false
                                    }))
                    }
                })
        }.coordinateSpace(name: space)
    }
}

