# PSlider Guide

A deep dive into ``PSlider`` — turn any SwiftUI `Shape` into a slider whose thumb travels along the shape's path.

## Overview

``PSlider`` takes any SwiftUI `Shape` and converts it into a slider. The thumb follows the outline of the shape, and the track fills as the thumb is dragged. This makes it great for creating unique, organic user experiences.

## Parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `value` | `Binding<Double>` | required | The current value of the slider |
| `shape` | `Shape` | required | The `Shape` to be used as the slider's track |
| `range` | `ClosedRange<Double>` | `0...1` | The minimum and maximum numbers that `value` can be |
| `isDisabled` | `Bool` | `false` | Whether the slider should be disabled |

## Basic Usage

Use any SwiftUI `Shape` as the track:

```swift
@State private var value = 0.5

PSlider($value, shape: Circle())
    .frame(width: 200, height: 200)
```

### Custom Range

```swift
@State private var value = 50.0

PSlider($value, range: 0...100, shape: Circle())
    .frame(width: 200, height: 200)
```

### Using a Custom Shape

Any conforming `Shape` works — including your own:

```swift
@State private var value = 0.5

PSlider($value, shape: RoundedRectangle(cornerRadius: 20))
    .frame(width: 250, height: 150)
```

## PSliderConfiguration

Both style methods provide access to state values through ``PSliderConfiguration``:

```swift
struct PSliderConfiguration {
    let isDisabled: Bool
    let isActive: Bool
    let pctFill: Double
    let value: Double
    let angle: Angle
    let min: Double
    let max: Double
    let shape: AnyShape
}
```

## Styling

Conform to ``PSliderStyle`` and implement two methods:

- `makeThumb(configuration:)` — the draggable thumb that follows the shape's path
- `makeTrack(configuration:)` — the track that fills or empties as the thumb drags

Apply with `.pathSliderStyle(_:)`:

```swift
struct MyPSliderStyle: PSliderStyle {
    func makeThumb(configuration: PSliderConfiguration) -> some View {
        Circle()
            .frame(width: 30, height: 30)
            .foregroundColor(configuration.isActive ? Color.yellow : Color.white)
    }

    func makeTrack(configuration: PSliderConfiguration) -> some View {
        ZStack {
            configuration.shape
                .stroke(Color.gray, lineWidth: 8)
            configuration.shape
                .trim(from: 0, to: CGFloat(configuration.pctFill))
                .stroke(Color.purple, lineWidth: 10)
        }
    }
}
```

Apply the style:

```swift
PSlider($value, shape: Circle())
    .pathSliderStyle(MyPSliderStyle())
    .frame(width: 200, height: 200)
```

The `pathSliderStyle` modifier cascades through the view hierarchy.

## Topics

### Essentials

- ``PSlider``
- ``PSliderStyle``
- ``PSliderConfiguration``

### Tutorials

- <doc:PSlider-Tutorials>
