# RSlider Guide

A deep dive into ``RSlider`` — the circular slider whose thumb travels around a configurable arc.

## Overview

``RSlider`` is a circular slider for SwiftUI. The thumb moves around a circular track and updates a bound `Double` value. It supports partial or multiple rotations, tick marks, magnetic affinity snapping, and haptic feedback.

## Parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `value` | `Binding<Double>` | required | The value the slider controls |
| `range` | `ClosedRange<Double>` | `0...1` | The minimum and maximum values |
| `originAngle` | `Angle` | `.zero` | The angle that corresponds to the minimum value (3 o'clock by default) |
| `maxWinds` | `Double` | `1` | Number of full rotations spanned by the range |
| `tickSpacing` | `TickMarkSpacing?` | `nil` | Tick mark placement. Use `nil` to hide tick marks |
| `affinityEnabled` | `Bool` | `false` | Enables snapping toward tick marks |
| `affinityRadius` | `Double` | `0.04` | Snap radius as a fraction of the full value range |
| `affinityResistance` | `Double` | `0.02` | Extra escape distance beyond `affinityRadius` |
| `disableHaptics` | `Bool` | `false` | Disables all haptic feedback |
| `label` | `(Double) -> some View` | `Text` (value, 2 dp) | A view builder for the floating label near the thumb |

## Labels

A floating label is displayed just outside the thumb and updates live. By default it shows the current value formatted to two decimal places. Pass a custom `label` closure:

```swift
@State private var speed = 0.5

RSlider($speed, range: 0...200) { value in
    Text("\(Int(value)) km/h")
}
.frame(width: 220, height: 220)
```

Use `.labelsVisibility(_:)` to hide labels:

```swift
RSlider($value)
    .labelsVisibility(.hidden)
    .frame(width: 220, height: 220)
```

## Basic Usage

```swift
@State private var value = 0.5

RSlider($value)
    .frame(width: 180, height: 180)
```

### Set a Range and Start Angle

`originAngle` sets where the minimum value is located on the circle:

```swift
@State private var temperature = 20.0

RSlider($temperature, range: 0...100, originAngle: .degrees(-90))
    .frame(width: 220, height: 220)
```

### Multiple Rotations (Winds)

`maxWinds` controls how many full rotations cover the entire value range:

```swift
@State private var revolutionsValue = 0.0

RSlider($revolutionsValue, range: 0...1, maxWinds: 3)
    .frame(width: 220, height: 220)
```

## Tick Marks

Tick marks are controlled through ``TickMarkSpacing``:

```swift
@State private var stepped = 0.5

RSlider($stepped, range: 0...1, tickSpacing: .count(11))
    .frame(width: 220, height: 220)
```

## Tick Affinity (Snapping)

When `affinityEnabled` is `true`, the thumb is pulled onto the nearest tick when it is close enough:

```swift
RSlider(
    $snapped,
    range: 0...1,
    tickSpacing: .count(11),
    affinityEnabled: true,
    affinityRadius: 0.02,
    affinityResistance: 0.01
)
.frame(width: 220, height: 220)
```

## Styling the Slider

Conform to ``RSliderStyle`` and implement:
- `makeThumb(configuration:)` — the draggable thumb
- `makeTrack(configuration:)` — the circular track
- `makeTickMark(configuration:tickValue:)` — each tick mark view
- `makeLabel(configuration:content:)` — *(optional)* wraps the label near the thumb

Apply a style using `radialSliderStyle(_:)` on the slider or a parent view.

``RSliderConfiguration`` provides the style with the current state including `value`, `angle`, tick mark values, and wind information.

```swift
struct ExampleRSliderStyle: RSliderStyle {
    func makeThumb(configuration: RSliderConfiguration) -> some View {
        Circle()
            .fill(configuration.isActive ? Color.cyan : Color.white)
            .frame(width: 28, height: 28)
            .shadow(radius: 2)
    }

    func makeTrack(configuration: RSliderConfiguration) -> some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 18)
            CircularArc(percent: configuration.withinWind)
                .stroke(Color.cyan, style: StrokeStyle(lineWidth: 18, lineCap: .round))
        }
        .padding(9)
    }

    func makeTickMark(configuration: RSliderConfiguration,
                      tickValue: Double) -> some View {
        let range = configuration.max - configuration.min
        let thumbPct = range > 0 ? (configuration.value - configuration.min) / range : 0
        let tickPct  = range > 0 ? (tickValue - configuration.min) / range : 0
        let proximity = max(0, 1 - abs(thumbPct - tickPct) / 0.20)
        let size    = 4.0 + 6.0 * proximity
        let opacity = 0.35 + 0.65 * proximity

        return Circle()
            .fill(Color.white.opacity(opacity))
            .frame(width: size, height: size)
            .animation(.easeOut(duration: 0.1), value: proximity)
    }
}
```

You can also use the built-in styles:

```swift
RSlider($value)
    .radialSliderStyle(.default(trackThickness: 18))

RSlider($value)
    .radialSliderStyle(.knob)
```

## Topics

### Essentials

- ``RSlider``
- ``RSliderStyle``
- ``RSliderConfiguration``
- ``TickMarkSpacing``

### Tutorials

- <doc:RSlider-Tutorials>
