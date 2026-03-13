# TrackPad Guide

A deep dive into ``TrackPad`` — the 2-D slider that maps horizontal and vertical drag to two independent values.

## Overview

``TrackPad`` is the 2-D equivalent of a `Slider`. A draggable thumb moves freely inside a rectangular area, controlling independent x and y values simultaneously. It supports a previous-value indicator with magnetic snap, a tick-mark grid, and haptic feedback.

### What it does

- Controls a `CGPoint` value by dragging a thumb anywhere inside a rectangular track.
- Each axis has its own independent `ClosedRange`, so x and y can cover completely different domains.
- **Previous-value indicator** — a ghost marker is left at the last committed position. Dragging slowly back toward the marker will magnetically snap the thumb to it.
- **Tick marks** — divide one or both axes into a regular grid. The thumb snaps magnetically to the nearest intersection.
- **Haptic feedback** — fires when the thumb hits a track edge, and softly when it snaps to a previous-value position or tick intersection.
- Fully stylable via the ``TrackPadStyle`` protocol.

## Parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `value` | `Binding<CGPoint>` | required | The point whose x and y components the trackpad controls |
| `rangeX` | `ClosedRange<CGFloat>` | `0...1` | Valid domain for the x axis |
| `rangeY` | `ClosedRange<CGFloat>` | `0...1` | Valid domain for the y axis |
| `showPreviousValue` | `Bool` | `false` | Show a ghost marker at the last committed position |
| `previousValueAffinityRadius` | `Double` | `0.06` | Fraction of the track diagonal within which the previous-value snap activates |
| `previousValueAffinityResistance` | `Double` | `0.03` | Extra fraction beyond the pull radius to escape the snap |
| `previousValueVelocityThreshold` | `Double` | `180` | Max drag speed (pts/s) at which the snap can engage |
| `tickCountX` | `Int` | `0` | Number of equal intervals along the x-axis (`0` = no tick marks) |
| `tickCountY` | `Int` | `0` | Number of equal intervals along the y-axis (`0` = no tick marks) |
| `tickAffinityRadius` | `Double` | `0.05` | Fraction of diagonal within which the thumb snaps to a tick |
| `tickAffinityResistance` | `Double` | `0.02` | Extra fraction to escape a tick snap |
| `tickAffinityVelocityThreshold` | `Double` | `150` | Max drag speed for tick snapping |
| `label` | `(Double, Double) -> some View` | `Text` (x, y, 2 dp) | A view builder for the floating label near the thumb |

## Labels

A floating label is displayed above the thumb and updates live:

```swift
@State var point = CGPoint(x: 0.5, y: 0.5)

TrackPad($point, rangeX: -1...1, rangeY: -1...1) { x, y in
    Text(String(format: "x: %.2f  y: %.2f", x, y))
}
.frame(height: 260)
```

Use `.labelsVisibility(_:)` to hide the label:

```swift
TrackPad($point)
    .labelsVisibility(.hidden)
    .frame(height: 260)
```

## Basic Usage

```swift
@State var point = CGPoint(x: 0.5, y: 0.5)

TrackPad($point)
    .frame(height: 260)
```

### Custom Ranges

```swift
TrackPad($point, rangeX: -1...1, rangeY: 0...10)
    .frame(height: 260)
```

When both axes share the same domain:

```swift
TrackPad($point, range: 0...100)
    .frame(height: 260)
```

### Double Bindings

If your model stores x and y as separate `Double` properties:

```swift
@State var pan: Double = 0.0
@State var tilt: Double = 0.0

TrackPad(x: $pan, y: $tilt, rangeX: -1...1, rangeY: -1...1)
    .frame(height: 260)
```

## Previous Value Indicator

Enable `showPreviousValue` to leave a ghost marker at the position where the user last lifted their finger:

```swift
TrackPad($point)
    .showPreviousValue(true)
    .frame(height: 260)
```

### Tuning the Affinity

| Modifier | Description |
|---|---|
| `.previousValueAffinityRadius(_:)` | How close the thumb must be to activate the snap |
| `.previousValueAffinityResistance(_:)` | Extra fraction to break out |
| `.previousValueVelocityThreshold(_:)` | Maximum drag speed for snap engagement |

## Tick Marks

Set `tickCountX` and/or `tickCountY` to divide the track into a regular grid:

```swift
TrackPad($point)
    .tickCount(4)
    .frame(height: 260)
```

Independent axis counts:

```swift
TrackPad($point)
    .tickCountX(3)
    .tickCountY(5)
    .frame(height: 260)
```

### Tuning Tick Affinity

| Modifier | Description |
|---|---|
| `.tickAffinityRadius(_:)` | How close to snap to a tick |
| `.tickAffinityResistance(_:)` | Extra fraction to escape |
| `.tickAffinityVelocityThreshold(_:)` | Maximum drag speed for snapping |

## Haptic Feedback

Haptic feedback fires on edge hit, previous-value snap, and tick snap (iOS only).

## Styling

Conform to ``TrackPadStyle`` and implement:
- `makeThumb(configuration:)` — the draggable thumb
- `makeTrack(configuration:)` — the rectangular track background
- `makePreviousValueIndicator(configuration:)` — *(optional)* ghost marker
- `makeTickMarks(configuration:)` — *(optional)* grid overlay
- `makeLabel(configuration:content:)` — *(optional)* label container

Apply with `.trackPadStyle(_:)`.

``TrackPadConfiguration`` provides the current state including position, ranges, previous-value, and tick-snap state.

You can also use the built-in default style with custom parameters:

```swift
TrackPad($point)
    .trackPadStyle(
        .default(
            trackColor: Color.indigo.opacity(0.15),
            trackStrokeColor: Color.indigo,
            thumbInactiveColor: Color.indigo,
            thumbActiveColor: Color.white,
            thumbSize: 44
        )
    )
    .frame(height: 260)
```

## Topics

### Essentials

- ``TrackPad``
- ``TrackPadStyle``
- ``TrackPadConfiguration``

### Tutorials

- <doc:TrackPad-Tutorials>
