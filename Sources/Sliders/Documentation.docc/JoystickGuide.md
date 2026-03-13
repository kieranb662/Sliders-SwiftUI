# Joystick Guide

A deep dive into ``Joystick`` — the on-screen joystick that appears wherever the user drags within a hit-box.

## Overview

``Joystick`` is an on-screen joystick control that can appear anywhere the user drags within a defined hit-box. If the drag ends inside a lock-box region, the joystick remains on screen locked in the forward position. If the drag ends outside the lock-box the joystick fades away until the hit-box is dragged again.

### What it does

- Creates a **rectangular hit-box** that responds to drag gestures.
- On drag, the joystick appears centred at the gesture's start location.
- The thumb is constrained to a circle of the given `radius`.
- A **lock-box** above the start position lets the user lock the joystick in place.
- Provides `angle` and `radialOffset` through the bound ``JoyState``.
- Fully stylable via the ``JoystickStyle`` protocol.

## Parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `state` | `Binding<JoyState>` | required | A binding to a `JoyState` value that exposes all of the joystick's state |
| `radius` | `Double` | required | The radius of the circular track |
| `canLock` | `Bool` | `true` | Whether the joystick has locking behaviour |
| `isDisabled` | `Bool` | `false` | Whether the joystick allows hit testing |

## JoyState

`JoyState` is an enumeration that represents the joystick's current state:

- `.inactive` — the joystick is hidden.
- `.locked` — the joystick is locked in place after a drag ended inside the lock-box.
- `.dragging(time:translation:startLocation:velocity:acceleration:)` — the user is actively dragging.

Useful computed properties:

| Property | Type | Description |
|---|---|---|
| `isActive` | `Bool` | `true` when dragging or locked |
| `isLocked` | `Bool` | `true` when locked |
| `isDragging` | `Bool` | `true` when actively dragging |
| `angle` | `Angle` | Direction from centre to thumb |
| `radialOffset` | `Double` | Distance from centre to thumb |
| `translation` | `CGSize` | Current drag translation |
| `velocity` | `CGSize` | Current drag velocity |
| `acceleration` | `CGSize` | Current drag acceleration |

## Basic Usage

```swift
@State private var joyState: JoyState = .inactive

Joystick(state: $joyState, radius: 60)
    .frame(width: 300, height: 300)
```

### Disabling Lock

```swift
Joystick(state: $joyState, radius: 60, canLock: false, isDisabled: false)
    .frame(width: 300, height: 300)
```

### Reading State

```swift
@State private var joyState: JoyState = .inactive

VStack {
    Text("Angle: \(joyState.angle.degrees, specifier: "%.0f")°")
    Text("Offset: \(joyState.radialOffset, specifier: "%.1f")")
    Text("Locked: \(joyState.isLocked ? "Yes" : "No")")

    Joystick(state: $joyState, radius: 60)
        .frame(width: 300, height: 300)
}
```

## JoystickConfiguration

All style methods receive a ``JoystickConfiguration``:

```swift
struct JoystickConfiguration {
    let isDisabled: Bool
    let isActive: Bool
    let isAtLimit: Bool
    let isLocked: Bool
    let angle: Angle
    let radialOffset: Double
}
```

## Styling

Conform to ``JoystickStyle`` and implement four methods:

- `makeHitBox(configuration:)` — the rectangular region that responds to touch
- `makeLockBox(configuration:)` — the view that acts as the lock target
- `makeTrack(configuration:)` — the circular track containing the thumb
- `makeThumb(configuration:)` — the draggable thumb view

Apply with `.joystickStyle(_:)`:

```swift
struct MyJoystickStyle: JoystickStyle {
    func makeHitBox(configuration: JoystickConfiguration) -> some View {
        Rectangle()
            .fill(Color.white.opacity(0.05))
    }

    func makeLockBox(configuration: JoystickConfiguration) -> some View {
        ZStack {
            Circle().fill(Color.black)
            Circle().fill(Color.yellow).scaleEffect(0.7)
        }
        .frame(width: 25, height: 25)
    }

    func makeTrack(configuration: JoystickConfiguration) -> some View {
        Circle()
            .fill(Color.gray.opacity(0.4))
    }

    func makeThumb(configuration: JoystickConfiguration) -> some View {
        Circle()
            .fill(configuration.isActive ? Color.green : Color.blue)
            .frame(width: 45, height: 45)
    }
}
```

## Topics

### Essentials

- ``Joystick``
- ``JoystickStyle``
- ``JoystickConfiguration``

### Tutorials

- <doc:Joystick-Tutorials>
