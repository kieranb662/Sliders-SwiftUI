# RadialPad Guide

A deep dive into ``RadialPad`` — the joystick-style 2-D control that retains its position after the drag ends.

## Overview

``RadialPad`` is a joystick-like 2-D control where the thumb moves freely within a circular track. Unlike a traditional joystick, the thumb stays at its last dragged position when the gesture ends.

### What it does

- Tracks a normalised radial distance (`offset`, `0…1`) and an `Angle` direction.
- **Previous-value indicator** — a ghost marker at the last committed position. Drag slowly back to snap.
- **Polar tick marks** — divide the track into concentric rings (r-ticks) and/or angular spokes (θ-ticks). Intersections act as snap points.
- **Single-tap select** — optionally allows a tap on the track to place the thumb immediately.
- **Haptic feedback** — fires on edge, previous-value snap, and tick snap.
- Fully stylable via the ``RadialPadStyle`` protocol.

## Parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `offset` | `Binding<Double>` | required | The normalised radial distance (`0…1`) from the centre |
| `angle` | `Binding<Angle>` | required | The angular direction of the thumb |
| `label` | `(Double, Angle) -> some View` | `Text` (offset, angle) | View builder for the floating label |
| `showPreviousValue` | `Bool` | `false` | Show a ghost marker at the last committed position |
| `previousValueAffinityRadius` | `Double` | `0.06` | Fraction of track radius for snap activation |
| `previousValueAffinityResistance` | `Double` | `0.03` | Extra fraction to escape the snap |
| `previousValueVelocityThreshold` | `Double` | `180` | Max drag speed for snap engagement |
| `tickCountR` | `Int` | `0` | Number of radial intervals (concentric rings) |
| `tickCountTheta` | `Int` | `0` | Number of angular sectors (spoke lines) |
| `tickAffinityRadius` | `Double` | `0.05` | Fraction of track radius for tick snapping |
| `tickAffinityResistance` | `Double` | `0.02` | Extra fraction to escape a tick snap |
| `tickAffinityVelocityThreshold` | `Double` | `150` | Max drag speed for tick snapping |
| `allowsSingleTapSelect` | `Bool` | `false` | Allow a tap to place the thumb |

## Basic Usage

```swift
@State var dist = 0.0
@State var dir  = Angle.zero

RadialPad(offset: $dist, angle: $dir)
    .frame(width: 260, height: 260)
```

## Labels

```swift
RadialPad(offset: $dist, angle: $dir) { offset, angle in
    Text(String(format: "%.0f°  r=%.2f", angle.degrees, offset))
}
.frame(width: 260, height: 260)
```

## Previous Value Indicator

```swift
RadialPad(offset: $dist, angle: $dir)
    .showPreviousValue(true)
    .frame(width: 260, height: 260)
```

## Polar Tick Marks

Set `tickCountR` and/or `tickCountTheta` to add rings and spokes:

```swift
RadialPad(offset: $dist, angle: $dir)
    .tickCountR(4)
    .tickCountTheta(8)
    .frame(width: 260, height: 260)
```

## Styling

Conform to ``RadialPadStyle`` and implement:
- `makeThumb(configuration:)` — the draggable thumb
- `makeTrack(configuration:)` — the circular track background
- `makePreviousValueIndicator(configuration:)` — *(optional)* ghost marker
- `makeTickMarks(configuration:)` — *(optional)* polar grid
- `makeLabel(configuration:content:)` — *(optional)* label container

Apply with `.radialPadStyle(_:)`.

``RadialPadConfiguration`` provides the current state including offset, angle, previous-value, and tick-snap state.

## Topics

### Essentials

- ``RadialPad``
- ``RadialPadStyle``
- ``RadialPadConfiguration``

### Tutorials

- <doc:RadialPad-Tutorials>
