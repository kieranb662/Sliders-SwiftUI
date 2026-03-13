# DoubleRSlider Guide

A deep dive into ``DoubleRSlider`` — the circular range slider with two independent thumbs and a draggable active-track arc.

## Overview

``DoubleRSlider`` is a circular **range** slider with two independent thumbs — a lower (start) thumb and an upper (end) thumb — connected by a draggable active-track arc. All three elements respond to drag gestures, making it easy to select and pan a range of values on a circular track.

### What it does

- Lets the user define a range by dragging a **lower thumb** and an **upper thumb** independently around a full circle.
- The **active-track arc** between the two thumbs can be dragged to shift the entire range while keeping its width constant.
- Enforces a **`minimumDistance`** between the two thumbs so they can never overlap.
- Supports tick marks, magnetic affinity (snap to tick), and haptic feedback — all independently configurable per thumb.

## Parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `lowerValue` | `Binding<Double>` | required | The start (lower) value of the selected range |
| `upperValue` | `Binding<Double>` | required | The end (upper) value of the selected range |
| `range` | `ClosedRange<Double>` | `0...1` | The allowed value domain |
| `originAngle` | `Angle` | `.zero` | The angle that corresponds to the minimum value (3 o'clock by default) |
| `minimumDistance` | `Double?` | 5 % of span | Smallest gap in value units between the two thumbs |
| `tickSpacing` | `TickMarkSpacing?` | `nil` | Tick mark placement. Use `nil` to hide tick marks |
| `affinityEnabled` | `Bool` | `false` | Enables magnetic snap toward tick marks |
| `affinityRadius` | `Double` | `0.04` | Snap pull radius as a fraction of the full value range |
| `affinityResistance` | `Double` | `0.02` | Extra escape distance beyond `affinityRadius` |
| `disableHaptics` | `Bool` | `false` | Suppresses all haptic feedback |
| `lowerLabel` | `(Double) -> some View` | `Text` (value, 2 dp) | A view builder for the floating label near the lower thumb |
| `upperLabel` | `(Double) -> some View` | `Text` (value, 2 dp) | A view builder for the floating label near the upper thumb |

## Labels

Floating labels are displayed above each thumb and update live. Pass `lowerLabel` and `upperLabel` closures:

```swift
@State private var lower = 0.25
@State private var upper = 0.75

DoubleRSlider(
    lowerValue: $lower,
    upperValue: $upper,
    range: 0...100
) { v in
    Text("from \(Int(v))")
} upperLabel: { v in
    Text("to \(Int(v))")
}
.frame(width: 220, height: 220)
```

## Basic Usage

```swift
@State private var lower = 0.25
@State private var upper = 0.75

DoubleRSlider(
    lowerValue: $lower,
    upperValue: $upper,
    range: 0...1
)
.frame(width: 220, height: 220)
```

### Minimum Distance

```swift
DoubleRSlider(
    lowerValue: $lower,
    upperValue: $upper,
    range: 0...1,
    minimumDistance: 0.1
)
.frame(width: 220, height: 220)
```

## Tick Marks

Tick marks use the same ``TickMarkSpacing`` enum as the other sliders:

```swift
DoubleRSlider(
    lowerValue: $lower,
    upperValue: $upper,
    range: 0...1,
    tickSpacing: .count(9)
)
.frame(width: 220, height: 220)
```

## Tick Affinity (Snapping)

```swift
DoubleRSlider(
    lowerValue: $lower,
    upperValue: $upper,
    range: 0...1,
    tickSpacing: .count(9),
    affinityEnabled: true,
    affinityRadius: 0.03,
    affinityResistance: 0.015
)
.frame(width: 220, height: 220)
```

## Dragging the Active Track

The filled arc between the two thumbs acts as a drag handle that shifts the entire range. The range width is held constant while both `lowerValue` and `upperValue` update together.

## Haptic Feedback

Haptic feedback fires automatically when a thumb reaches a range limit, crosses a tick mark, or snaps in/out of affinity. Each thumb has its own independent haptic engine. Disable all haptics with `disableHaptics: true`.

## Styling the Slider

Conform to ``DoubleRSliderStyle`` and implement:

- `makeLowerThumb(configuration:)` — the lower-bound thumb
- `makeUpperThumb(configuration:)` — the upper-bound thumb
- `makeTrack(configuration:)` — the full track with the filled arc segment
- `makeTickMark(configuration:tickValue:)` — each tick mark view (has a default implementation)
- `makeLowerLabel(configuration:content:)` — *(optional)* wraps the label near the lower thumb
- `makeUpperLabel(configuration:content:)` — *(optional)* wraps the label near the upper thumb

Apply a style using `.doubleRadialSliderStyle(_:)` on the slider or any ancestor view.

``DoubleRSliderConfiguration`` provides the current state:

```swift
struct DoubleRSliderConfiguration {
    let isDisabled: Bool
    let isLowerActive: Bool
    let isUpperActive: Bool
    let isRangeActive: Bool
    let lowerValue: Double
    let upperValue: Double
    let lowerAngle: Angle
    let upperAngle: Angle
    let originAngle: Angle
    let min: Double
    let max: Double
    let tickMarkSpacing: TickMarkSpacing?
    let tickValues: [Double]
    let affinityEnabled: Bool
    let snappedLowerTickValue: Double?
    let snappedUpperTickValue: Double?

    var lowerPercent: Double
    var upperPercent: Double
}
```

You can also use the built-in default style with custom colours:

```swift
DoubleRSlider(lowerValue: $lower, upperValue: $upper)
    .doubleRadialSliderStyle(
        .default(
            trackColor: Color(white: 0.25),
            trackFilledColor: .indigo,
            lowerThumbColor: .white,
            upperThumbColor: .white,
            activeThumbColor: .cyan,
            trackThickness: 20
        )
    )
    .frame(width: 220, height: 220)
```

## Topics

### Essentials

- ``DoubleRSlider``
- ``DoubleRSliderStyle``
- ``DoubleRSliderConfiguration``
- ``TickMarkSpacing``

### Tutorials

- <doc:DoubleRSlider-Tutorials>
