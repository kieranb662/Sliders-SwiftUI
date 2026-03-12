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
    /// whether or not the slider is current disabled
    public let isDisabled: Bool
    /// whether or not the thumb is dragging or not
    public let isActive: Bool
    /// The current value of the slider
    public let value: Double
    /// The direction from the thumb to the slider center
    public let angle: Angle
    /// The minimum value of the sliders range
    public let min: Double
    /// The maximum value of the sliders range
    public let max: Double
    /// The current number of full rotations completed (fractional winds are possible)
    public let currentWind: Double
    /// The maximum number of winds the slider spans
    public let maxWinds: Double
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

    public func makeThumb(configuration: RSliderConfiguration) -> some View {
        Circle()
            .frame(width: 30, height: 30)
            .foregroundColor(configuration.isActive ? Color.yellow : Color.white)
    }

    public func makeTrack(configuration: RSliderConfiguration) -> some View {
        // How far around the circle the thumb is within the current wind (0–1)
        let withinWind = configuration.maxWinds > 0
            ? (configuration.currentWind + (configuration.value - configuration.min) / (configuration.max - configuration.min) * configuration.maxWinds)
                .truncatingRemainder(dividingBy: 1.0)
            : 0.0
        return ZStack {
            Circle()
                .stroke(Color.gray, style: StrokeStyle(lineWidth: 10, lineCap: .round))
            Circle()
                .trim(from: 0, to: CGFloat(withinWind))
                .stroke(Color.purple, style: StrokeStyle(lineWidth: 12, lineCap: .round))
        }
    }
}

// MARK: - Knob Style

public struct KnobStyle: RSliderStyle {
    public init() { }

    public func makeThumb(configuration: RSliderConfiguration) -> some View {
        let gradient = RadialGradient(gradient: Gradient(colors: [.gray, .white]), center: .center, startRadius: 0, endRadius: 80)
        return Circle()
            .fill(gradient)
            .frame(width: 40)
            .shadow(radius: 1)
    }

    public func makeTrack(configuration: RSliderConfiguration) -> some View {
        // Total rotation in degrees across all completed winds plus position in current wind
        let totalDegrees = configuration.maxWinds > 0
            ? 360.0 * (configuration.currentWind + (configuration.value - configuration.min) / (configuration.max - configuration.min) * configuration.maxWinds)
                .truncatingRemainder(dividingBy: 1.0) / configuration.maxWinds
                + 360.0 * configuration.currentWind / configuration.maxWinds
            : 0.0
        return Circle().frame(width: 150)
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
            .rotationEffect(Angle(degrees: totalDegrees))
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
///            let isDisabled: Bool  // whether or not the slider is currently disabled
///            let isActive: Bool    // whether or not the thumb is dragging or not
///            let value: Double     // The current value of the slider
///            let angle: Angle      // The direction from the thumb to the slider center
///            let min: Double       // The minimum value of the sliders range
///            let max: Double       // The maximum value of the sliders range
///            let currentWind: Double // The current number of full rotations completed
///            let maxWinds: Double  // The maximum number of winds the slider spans
///        }
/// ```
///  To make this easier just copy and paste the following style based on the `DefaultRSliderStyle`. After creating your custom style
///  apply it by calling the `radialSliderStyle` method on the `RSlider` or a view containing it.
///
///    ```
///          struct <#My Slider Style #>: RSliderStyle {
///              func makeThumb(configuration: RSliderConfiguration) -> some View {
///                  Circle()
///                      .frame(width: 30, height: 30)
///                      .foregroundColor(configuration.isActive ? Color.yellow : Color.white)
///              }
///
///              func makeTrack(configuration: RSliderConfiguration) -> some View {
///                  let fill = (configuration.value - configuration.min) / (configuration.max - configuration.min)
///                  return Circle()
///                      .stroke(Color.gray, style: StrokeStyle(lineWidth: 10, lineCap: .round))
///                      .overlay(Circle()
///                          .trim(from: 0, to: CGFloat(fill))
///                          .stroke(Color.purple, style: StrokeStyle(lineWidth: 12, lineCap: .round)))
///              }
///          }
///  ```
///

public struct RSlider: View {
    @Environment(\.radialSliderStyle) private var style: AnyRSliderStyle
    @Environment(\.isEnabled) private var isEnabled: Bool
    @State private var isActive = false
    /// Tracks the cumulative number of full rotations (winds)
    @State private var currentWind: Double = 0
    /// The raw [0,1) angle position from the last drag update, used to detect crossings
    @State private var lastRawAngle: Double = 0
    @Binding public var value: Double
    public let range: ClosedRange<Double>
    /// The angle on the circle that corresponds to the minimum value (default: `.zero` = 3 o'clock)
    public let originAngle: Angle
    /// Maximum number of full winds allowed (e.g. 2 = 0–720°, 0.25 = 0–90°). Default is 1.
    public let maxWinds: Double

    public init(_ value: Binding<Double>, originAngle: Angle = .zero, maxWinds: Double = 1) {
        self._value = value
        self.range = 0...1
        self.originAngle = originAngle
        self.maxWinds = maxWinds
    }

    public init(_ value: Binding<Double>, range: ClosedRange<Double>, originAngle: Angle = .zero, maxWinds: Double = 1) {
        self._value = value
        self.range = range
        self.originAngle = originAngle
        self.maxWinds = maxWinds
    }

    /// Returns the raw [0, 1) position around the circle for a drag location,
    /// adjusted so that `originAngle` maps to 0.
    private func rawAngle(from pt1: CGPoint, _ pt2: CGPoint) -> Double {
        let a = pt2.x - pt1.x
        let b = pt2.y - pt1.y
        let raw = Double(atanP(x: a, y: b) / (2 * .pi))
        let originFraction = originAngle.degrees / 360.0
        return (raw - originFraction).truncatingRemainder(dividingBy: 1.0) + (raw < originFraction ? 1 : 0)
    }

    /// Computes the new value and updates `currentWind` based on the drag position.
    private func updateValue(from center: CGPoint, location: CGPoint) {
        let newRaw = rawAngle(from: center, location)

        // Detect wrap-around crossings
        let delta = newRaw - lastRawAngle
        if delta < -0.5 {
            // Crossed 0 going forward (e.g. 0.95 → 0.05)
            currentWind += 1
        } else if delta > 0.5 {
            // Crossed 0 going backward (e.g. 0.05 → 0.95)
            currentWind -= 1
        }
        lastRawAngle = newRaw

        // Total fractional progress across all winds
        let totalPct = (currentWind + newRaw) / maxWinds

        // Clamp to [0, 1] across full wind range
        let clampedPct = Swift.max(0, Swift.min(1, totalPct))

        // If we're at the boundary, also clamp currentWind so we don't drift
        if totalPct < 0 {
            currentWind = -newRaw
        } else if totalPct > 1 {
            currentWind = maxWinds - newRaw
        }

        value = clampedPct * (range.upperBound - range.lowerBound) + range.lowerBound
    }

    private var configuration: RSliderConfiguration {
        let pct = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        return .init(isDisabled: !isEnabled,
                     isActive: isActive,
                     value: value,
                     angle: Angle(degrees: pct * 360 * maxWinds + originAngle.degrees),
                     min: range.lowerBound,
                     max: range.upperBound,
                     currentWind: currentWind,
                     maxWinds: maxWinds)
    }

    private func makeThumb(_ proxy: GeometryProxy) -> some View {
        let radius = min(proxy.size.height, proxy.size.width) / 2
        let middle = CGPoint(x: proxy.frame(in: .global).midX, y: proxy.frame(in: .global).midY)

        let gesture = DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .onChanged { dragValue in
                if !isActive {
                    // Initialise lastRawAngle on first touch to avoid a spurious wind jump
                    lastRawAngle = rawAngle(from: middle, dragValue.location)
                    isActive = true
                }
                updateValue(from: middle, location: dragValue.location)
            }
            .onEnded { dragValue in
                updateValue(from: middle, location: dragValue.location)
                isActive = false
            }

        // Place thumb at the correct angular position, accounting for originAngle
        let pct = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        let thumbAngle = pct * 2 * .pi * maxWinds + originAngle.radians
        let pX = radius * CGFloat(cos(thumbAngle))
        let pY = radius * CGFloat(sin(thumbAngle))

        return style.makeThumb(configuration: configuration)
            .offset(x: pX, y: pY)
            .gesture(gesture)
            .allowsHitTesting(isEnabled)
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
