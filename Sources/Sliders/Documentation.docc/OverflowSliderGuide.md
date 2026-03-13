# OverflowSlider Guide

A deep dive into ``OverflowSlider`` — a meter-style slider with two moving parts and velocity-based gestures.

## Overview

``OverflowSlider`` is a slider with a fixed frame but a movable track in the background. It is designed for values that have a discrete nature but would not necessarily fit on screen. Both the thumb and track can be dragged independently.

### What it does

- The **thumb** can be dragged within a fixed frame.
- The **track** can be dragged and thrown — velocity is preserved and decays gradually.
- When the thumb reaches the minimum or maximum of its bounds, velocity is added to the track in the opposite direction.
- Uses tick marks along the track to provide a meter-like visual.

## Parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `value` | `Binding<Double>` | required | The value the slider should control |
| `range` | `ClosedRange<Double>` | required | The minimum and maximum numbers that `value` can be |
| `spacing` | `Double` | required | The spacing of the slider's tick marks |
| `isDisabled` | `Bool` | `false` | Whether the slider should be disabled |

## Basic Usage

```swift
@State private var value = 50.0

OverflowSlider(value: $value, range: 0...500, spacing: 10, isDisabled: false)
    .frame(height: 60)
```

### Adjusting Tick Spacing

The `spacing` parameter controls how far apart the tick marks are, in value-domain units:

```swift
OverflowSlider(value: $value, range: 0...1000, spacing: 25, isDisabled: false)
    .frame(height: 60)
```

### Velocity Behaviour

Both the thumb and track respond to gestures with velocity. When you throw the track by dragging quickly and releasing, momentum carries it forward and decays gradually. When the thumb hits a boundary, the track begins to scroll in the opposite direction automatically.

## OverflowSliderConfiguration

Both style methods provide access to state values through ``OverflowSliderConfiguration``:

```swift
struct OverflowSliderConfiguration {
    let isDisabled: Bool
    let thumbIsActive: Bool
    let thumbIsAtLimit: Bool
    let trackIsActive: Bool
    let trackIsAtLimit: Bool
    let value: Double
    let min: Double
    let max: Double
    let tickSpacing: Double
}
```

## Styling

Conform to ``OverflowSliderStyle`` and implement two methods:

- `makeThumb(configuration:)` — the draggable thumb in the foreground
- `makeTrack(configuration:)` — the movable background track with tick marks

Apply with `.overflowSliderStyle(_:)`:

```swift
struct MyOverflowSliderStyle: OverflowSliderStyle {
    func makeThumb(configuration: OverflowSliderConfiguration) -> some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(configuration.thumbIsActive ? Color.orange : Color.blue)
            .opacity(0.5)
            .frame(width: 20, height: 50)
    }

    func makeTrack(configuration: OverflowSliderConfiguration) -> some View {
        let totalLength = configuration.max - configuration.min
        let spacing = configuration.tickSpacing

        return TickMarks(
            spacing: CGFloat(spacing),
            ticks: Int(totalLength / Double(spacing))
        )
        .stroke(Color.gray)
        .frame(width: CGFloat(totalLength))
    }
}
```

Apply the style:

```swift
OverflowSlider(value: $value, range: 0...500, spacing: 10, isDisabled: false)
    .overflowSliderStyle(MyOverflowSliderStyle())
    .frame(height: 60)
```

The `overflowSliderStyle` modifier cascades through the view hierarchy.

## Topics

### Essentials

- ``OverflowSlider``
- ``OverflowSliderStyle``
- ``OverflowSliderConfiguration``
- ``TickMarks``

### Tutorials

- <doc:OverflowSlider-Tutorials>
