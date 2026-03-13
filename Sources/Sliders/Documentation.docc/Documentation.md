# ``Sliders``

A collection of fully stylable, drag-based SwiftUI controls — including linear, radial, range, and 2D sliders.

## Overview

@Image(source: sliders-logo.png, alt: "The Sliders Framework logo.")

**Sliders** provides drop-in replacements and extensions for SwiftUI's built-in `Slider`, designed to fill the gaps the standard toolkit leaves behind.

Every control is built around the same principles:

- **Fully stylable** — each component exposes a style protocol so you can customise the thumb, track, tick marks, and floating label independently.
- **Spatially adaptive** — sliders scale to fill their container and accept an `angle` parameter so you can place them horizontally, vertically, or at any diagonal without extra layout work.
- **Tick marks and haptics** — add evenly-spaced, step-spaced, or arbitrary tick marks and get haptic feedback on iOS as the thumb crosses each one.
- **Magnetic affinity snapping** — opt in to a pull-and-resist snap behaviour that locks the thumb to nearby tick marks and requires a deliberate extra drag to break free.

### Controls at a Glance

| Control | Description |
|---|---|
| ``LSlider`` | A linear slider that can be placed at any angle and scales its track to the available space. |
| ``DoubleLSlider`` | A linear **range** slider with two independent thumbs and a draggable active-track segment. |
| ``RSlider`` | A circular slider whose thumb travels around a configurable arc. |
| ``DoubleRSlider`` | A circular **range** slider with two thumbs and a draggable active-track arc. |
| ``TrackPad`` | A 2-D slider that maps horizontal and vertical drag to two independent values. |
| ``RadialPad`` | A joystick-style 2-D control that retains its position after the drag ends. |
| ``Joystick`` | An on-screen joystick that appears wherever the user drags within a defined hit-box. |
| ``PSlider`` | Turns any SwiftUI `Shape` into a slider whose thumb travels along the shape's path. |
| ``OverflowSlider`` | A meter-style slider with two moving parts — thumb and track — and velocity-based gestures. |

### Styling

All controls follow the same pattern: implement a style protocol, then apply it with a modifier:

```swift
// Apply a custom style to every LSlider in a container
VStack {
    LSlider($red,   range: 0...1)
    LSlider($green, range: 0...1)
    LSlider($blue,  range: 0...1)
}
.linearSliderStyle(MyLSliderStyle())
```

Style modifiers cascade through the view hierarchy, so one call at a container level styles all descendants of that type.

### Requirements

- iOS 26 or later
- macOS 26 or later
- watchOS 26 or later

### Installation

Add the package via Swift Package Manager: **File → Add Package Dependencies**, paste the repository URL, and select a minimum version.

## Topics

### Guides

- <doc:LSliderGuide>
- <doc:DoubleLSliderGuide>
- <doc:RSliderGuide>
- <doc:DoubleRSliderGuide>
- <doc:TrackPadGuide>
- <doc:RadialPadGuide>
- <doc:JoystickGuide>
- <doc:PSliderGuide>
- <doc:OverflowSliderGuide>

### Linear Sliders

- ``LSlider``
- ``DoubleLSlider``

### Radial Sliders

- ``RSlider``
- ``DoubleRSlider``

### 2D Controls

- ``TrackPad``
- ``RadialPad``
- ``Joystick``

### Path & Overflow Sliders

- ``PSlider``
- ``OverflowSlider``

### Styling — LSlider

- ``LSliderStyle``
- ``DefaultLSliderStyle``
- ``LSliderConfiguration``
- ``AnyLSliderStyle``

### Styling — DoubleLSlider

- ``DoubleLSliderStyle``
- ``DefaultDoubleLSliderStyle``
- ``DoubleLSliderConfiguration``

### Styling — RSlider

- ``RSliderStyle``
- ``DefaultRSliderStyle``
- ``RSliderConfiguration``

### Styling — DoubleRSlider

- ``DoubleRSliderStyle``
- ``DefaultDoubleRSliderStyle``
- ``DoubleRSliderConfiguration``

### Styling — TrackPad

- ``TrackPadStyle``
- ``DefaultTrackPadStyle``
- ``TrackPadConfiguration``

### Styling — RadialPad

- ``RadialPadStyle``
- ``DefaultRadialPadStyle``
- ``RadialPadConfiguration``

### Tick Marks

- ``TickMarkSpacing``

## Tutorials

- <doc:LSlider-Tutorials>
- <doc:DoubleLSlider-Tutorials>
- <doc:RSlider-Tutorials>
- <doc:DoubleRSlider-Tutorials>
- <doc:TrackPad-Tutorials>
- <doc:RadialPad-Tutorials>
- <doc:Joystick-Tutorials>
- <doc:PSlider-Tutorials>
- <doc:OverflowSlider-Tutorials>
