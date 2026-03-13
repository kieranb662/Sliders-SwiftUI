# DoubleLSlider Guide

A deep dive into ``DoubleLSlider`` — the linear range slider with two independent thumbs and a draggable active-track segment.

## Overview

``DoubleLSlider`` is a linear **range** slider with two independent thumbs — a lower (start) thumb and an upper (end) thumb — connected by a draggable active-track segment. All three elements respond to drag gestures, making it easy to select and pan a range of values on a linear track at any angle.

### What it does

- Lets the user define a range by dragging a **lower thumb** and an **upper thumb** independently along the track.
- The **active-track segment** between the two thumbs can be dragged to shift the entire range while keeping its width constant.
- Enforces a **`minimumDistance`** between the two thumbs so they can never overlap.
- Supports any track angle, tick marks, magnetic affinity (snap to tick), and haptic feedback.

## Parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `lowerValue` | `Binding<Double>` | required | The start (lower) value of the selected range |
| `upperValue` | `Binding<Double>` | required | The end (upper) value of the selected range |
| `range` | `ClosedRange<Double>` | `0...1` | The allowed value domain |
| `angle` | `Angle` | `.zero` (horizontal) | The angle at which the track is drawn |
| `keepThumbInTrack` | `Bool` | `false` | Constrains thumb centres to stay within the track's extent |
| `trackThickness` | `Double` | `20` | The thickness of the track in points |
| `minimumDistance` | `Double?` | 5 % of span | Smallest gap in value units between the two thumbs |
| `tickMarkSpacing` | `TickMarkSpacing?` | `nil` | Tick mark placement. Use `nil` to hide tick marks |
| `hapticFeedbackEnabled` | `Bool` | `true` | Whether crossing a tick mark triggers haptic feedback (iOS only) |
| `affinityEnabled` | `Bool` | `false` | Enables magnetic snap toward tick marks |
| `affinityRadius` | `Double` | `0.04` | Snap pull radius as a fraction of the full value range |
| `affinityResistance` | `Double` | `0.02` | Extra escape distance beyond `affinityRadius` |
| `lowerLabel` | `(Double) -> some View` | `Text` (value, 2 dp) | A view builder for the floating label near the lower thumb |
| `upperLabel` | `(Double) -> some View` | `Text` (value, 2 dp) | A view builder for the floating label near the upper thumb |

## Labels

Floating labels are displayed above each thumb and update live as the thumbs move. By default each label shows the current value formatted to two decimal places. Pass `lowerLabel` and `upperLabel` closures to render custom content:

```swift
@State private var lower = 0.25
@State private var upper = 0.75

DoubleLSlider(
    lowerValue: $lower,
    upperValue: $upper,
    range: 0...100
) { v in
    Text("from \(Int(v))")
} upperLabel: { v in
    Text("to \(Int(v))")
}
.frame(height: 60)
```

Use the `.labelsVisibility(_:)` modifier to hide labels across all sliders in a container:

```swift
VStack {
    DoubleLSlider(lowerValue: $lowerA, upperValue: $upperA)
    DoubleLSlider(lowerValue: $lowerB, upperValue: $upperB)
}
.labelsVisibility(.hidden)
```

## Basic Usage

A horizontal range slider over a `0...1` domain:

```swift
@State private var lower = 0.25
@State private var upper = 0.75

DoubleLSlider(
    lowerValue: $lower,
    upperValue: $upper,
    range: 0...1,
    keepThumbInTrack: true,
    trackThickness: 20
)
.frame(height: 60)
```

A vertical slider (90 degrees):

```swift
@State private var lower = 20.0
@State private var upper = 80.0

DoubleLSlider(
    lowerValue: $lower,
    upperValue: $upper,
    range: 0...100,
    angle: .degrees(90),
    keepThumbInTrack: true
)
.frame(width: 60, height: 200)
```

A diagonal slider:

```swift
@State private var lower = 0.2
@State private var upper = 0.8

DoubleLSlider(
    lowerValue: $lower,
    upperValue: $upper,
    range: 0...1,
    angle: .degrees(30),
    keepThumbInTrack: true,
    trackThickness: 20
)
.frame(width: 300, height: 120)
```

## Minimum Distance

`minimumDistance` ensures the two thumbs never collapse on top of each other. Specify it in value-domain units. If omitted it defaults to 5 % of the range span.

```swift
@State private var lower = 0.1
@State private var upper = 0.9

DoubleLSlider(
    lowerValue: $lower,
    upperValue: $upper,
    range: 0...1,
    keepThumbInTrack: true,
    minimumDistance: 0.15
)
.frame(height: 60)
```

## Tick Marks

Tick marks use the same ``TickMarkSpacing`` enum as ``LSlider``.

### `.count(n)`

Evenly distribute `n` tick marks across the range:

```swift
DoubleLSlider(
    lowerValue: $lower,
    upperValue: $upper,
    range: 0...1,
    keepThumbInTrack: true,
    trackThickness: 20,
    tickMarkSpacing: .count(11)
)
.frame(height: 60)
```

### `.spacing(step)`

Place a tick mark every `step` units:

```swift
DoubleLSlider(
    lowerValue: $lower,
    upperValue: $upper,
    range: 0...12,
    keepThumbInTrack: true,
    trackThickness: 20,
    tickMarkSpacing: .spacing(1)
)
.frame(height: 60)
```

### `.values([...])`

Place tick marks at specific values:

```swift
DoubleLSlider(
    lowerValue: $lower,
    upperValue: $upper,
    range: 0...1,
    keepThumbInTrack: true,
    trackThickness: 20,
    tickMarkSpacing: .values([0.0, 0.25, 0.5, 0.75, 1.0])
)
.frame(height: 60)
```

## Tick Affinity (Snapping)

When `affinityEnabled` is `true` and `tickMarkSpacing` is set, each thumb is pulled magnetically onto the nearest tick mark when it comes within `affinityRadius` of one. The thumb stays locked to the tick until dragged beyond `affinityRadius + affinityResistance`.

```swift
DoubleLSlider(
    lowerValue: $lower,
    upperValue: $upper,
    range: 0...1,
    keepThumbInTrack: true,
    trackThickness: 20,
    tickMarkSpacing: .count(11),
    affinityEnabled: true,
    affinityRadius: 0.03,
    affinityResistance: 0.015
)
.frame(height: 60)
```

## Dragging the Active Track

The filled segment between the two thumbs acts as a drag handle that shifts the entire range. The range width is held constant while both `lowerValue` and `upperValue` update together. This requires no special configuration — the gesture is always active on the filled segment.

## Haptic Feedback

Haptic feedback fires automatically (on supported platforms) when a thumb reaches the minimum or maximum of the range, crosses a tick mark, or snaps in or out of affinity with a tick mark. Each thumb has its own independent haptic engine. To disable all haptics, pass `hapticFeedbackEnabled: false`.

## Styling the Slider

Conform to ``DoubleLSliderStyle`` and implement these methods:

- `makeLowerThumb(configuration:)` — the draggable lower-bound thumb
- `makeUpperThumb(configuration:)` — the draggable upper-bound thumb
- `makeTrack(configuration:)` — the full track with the filled range segment
- `makeTickMark(configuration:tickValue:)` — the view rendered at each tick position (has a default implementation)
- `makeLowerLabel(configuration:content:)` — *(optional)* wraps the label near the lower thumb
- `makeUpperLabel(configuration:content:)` — *(optional)* wraps the label near the upper thumb

Apply a style using `.doubleLSliderStyle(_:)` on the slider or any ancestor view.

All methods receive a ``DoubleLSliderConfiguration`` that exposes the current state:

```swift
struct DoubleLSliderConfiguration {
    let isDisabled: Bool
    let isLowerActive: Bool
    let isUpperActive: Bool
    let isRangeActive: Bool
    let lowerValue: Double
    let upperValue: Double
    let angle: Angle
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
DoubleLSlider(lowerValue: $lower, upperValue: $upper)
    .doubleLSliderStyle(
        .default(
            trackColor: Color(white: 0.25),
            trackFilledColor: .indigo,
            lowerThumbColor: .white,
            upperThumbColor: .white,
            activeThumbColor: .cyan,
            trackThickness: 20
        )
    )
    .frame(height: 60)
```

## Topics

### Essentials

- ``DoubleLSlider``
- ``DoubleLSliderStyle``
- ``DoubleLSliderConfiguration``
- ``TickMarkSpacing``

### Tutorials

- <doc:DoubleLSlider-Tutorials>
