# LSlider Guide

A deep dive into ``LSlider`` — the spatially adaptive linear slider that fits its container at any angle.

## Overview

``LSlider`` is a fully stylable linear slider that fits itself to its container at any angle. Unlike the built-in `Slider`, you can place an ``LSlider`` horizontally, vertically, or at any diagonal and it will automatically scale its track to the available space. Tick marks can be added and will optionally fire haptic feedback as the thumb passes over them.

## Parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `value` | `Binding<Double>` | required | The value the slider controls |
| `range` | `ClosedRange<Double>` | `0...1` | The minimum and maximum values |
| `angle` | `Angle` | `.zero` (horizontal) | The angle at which the slider is drawn |
| `keepThumbInTrack` | `Bool` | `false` | Constrains the thumb centre to stay within the track's extent |
| `trackThickness` | `Double` | `20` | The thickness of the track in points |
| `tickMarkSpacing` | `TickMarkSpacing?` | `nil` | How tick marks are spaced, or `nil` to hide them |
| `hapticFeedbackEnabled` | `Bool` | `true` | Whether crossing a tick mark triggers haptic feedback (iOS only) |
| `label` | `(Double) -> some View` | `Text` (value, 2 dp) | A view builder that receives the current value and returns the floating label displayed near the thumb |

## Labels

A floating label is displayed just above the thumb and updates live as the thumb moves. By default it shows the current value formatted to two decimal places. Pass a custom `label` closure to render anything:

```swift
@State var volume = 0.5

LSlider($volume, range: 0...100) { value in
    Label("\(Int(value)) dB", systemImage: "speaker.wave.2")
}
.frame(height: 60)
```

Use the `.labelsVisibility(_:)` modifier to hide the label across all sliders in a container:

```swift
VStack {
    LSlider($red,   range: 0...1)
    LSlider($green, range: 0...1)
    LSlider($blue,  range: 0...1)
}
.labelsVisibility(.hidden)
```

## Basic Usage

A horizontal slider over a `0...1` range with no tick marks:

```swift
@State var volume = 0.5

LSlider($volume, range: 0...1, keepThumbInTrack: true, trackThickness: 20)
    .frame(height: 60)
```

A vertical slider (90 degrees):

```swift
@State var brightness = 0.75

LSlider($brightness, range: 0...1, angle: .degrees(90), keepThumbInTrack: true)
    .frame(width: 60, height: 200)
```

A diagonal slider:

```swift
@State var value = 0.5

LSlider($value, range: 0...1, angle: .degrees(325), keepThumbInTrack: true, trackThickness: 20)
    .frame(width: 300, height: 120)
```

## Tick Marks

Tick marks are controlled through the ``TickMarkSpacing`` enum. There are three cases:

### `.count(n)`

Places exactly `n` tick marks evenly distributed across the range, including both endpoints:

```swift
@State var step = 0.5

LSlider(
    $step,
    range: 0...1,
    keepThumbInTrack: true,
    trackThickness: 20,
    tickMarkSpacing: .count(11),
    hapticFeedbackEnabled: true
)
.frame(height: 60)
```

### `.spacing(step)`

Places a tick mark every `step` units across the value domain:

```swift
@State var temperature = 3.0

LSlider(
    $temperature,
    range: 0...10,
    keepThumbInTrack: true,
    trackThickness: 20,
    tickMarkSpacing: .spacing(1),
    hapticFeedbackEnabled: true
)
.frame(height: 60)
```

### `.values([...])`

Places tick marks at specific values within the range:

```swift
@State var position = 0.5

LSlider(
    $position,
    range: 0...1,
    keepThumbInTrack: true,
    trackThickness: 20,
    tickMarkSpacing: .values([0.0, 0.25, 0.5, 0.75, 1.0]),
    hapticFeedbackEnabled: false
)
.frame(height: 60)
```

## Haptic Feedback

Haptic feedback fires each time the thumb passes over a tick mark. It is powered by `CoreHaptics` and is available on iOS. On platforms that do not support `CoreHaptics` the calls are silently ignored. To disable haptics entirely, pass `hapticFeedbackEnabled: false`. Haptics require tick marks to be configured; if `tickMarkSpacing` is `nil` no feedback is fired.

## Styling the Slider

Conform to ``LSliderStyle`` and implement these methods:

- `makeThumb(configuration:)` — the draggable thumb view
- `makeTrack(configuration:)` — the track and fill view
- `makeTickMark(configuration:tickValue:)` — the view rendered at each tick mark position
- `makeLabel(configuration:content:)` — *(optional, default provided)* wraps the label view floating above the thumb

Apply your style using the `linearSliderStyle(_:)` modifier on the slider or any ancestor view.

All four methods receive an ``LSliderConfiguration`` that exposes the current state of the slider:

```swift
struct LSliderConfiguration {
    let isDisabled: Bool
    let isActive: Bool
    let pctFill: Double
    let value: Double
    let angle: Angle
    let min: Double
    let max: Double
    let keepThumbInTrack: Bool
    let trackThickness: Double
    let tickMarkSpacing: TickMarkSpacing?
    let tickValues: [Double]
}
```

### Custom Style Example

```swift
struct BarLSliderStyle: LSliderStyle {
    func makeThumb(configuration: LSliderConfiguration) -> some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(configuration.isActive ? Color.orange : Color.white)
            .frame(width: configuration.trackThickness,
                   height: configuration.trackThickness * 1.4)
            .shadow(radius: 3)
    }

    func makeTrack(configuration: LSliderConfiguration) -> some View {
        let adjustment: Double = configuration.keepThumbInTrack
            ? configuration.trackThickness * (1 - configuration.pctFill)
            : configuration.trackThickness / 2

        return ZStack {
            AdaptiveLine(thickness: configuration.trackThickness,
                         angle: configuration.angle)
                .fill(Color(white: 0.2))
            AdaptiveLine(
                thickness: configuration.trackThickness,
                angle: configuration.angle,
                percentFilled: configuration.pctFill,
                cap: .square,
                adjustmentForThumb: adjustment / 2
            )
            .fill(Color.orange)
            .mask(AdaptiveLine(thickness: configuration.trackThickness,
                               angle: configuration.angle))
        }
    }

    func makeTickMark(configuration: LSliderConfiguration,
                      tickValue: Double) -> some View {
        let range = configuration.max - configuration.min
        let thumbPct = range > 0 ? (configuration.value - configuration.min) / range : 0
        let tickPct  = range > 0 ? (tickValue - configuration.min) / range : 0
        let distance  = abs(thumbPct - tickPct)
        let proximity = max(0, 1 - distance / 0.15)

        let size    = 6.0 + 6.0 * proximity
        let opacity = 0.4 + 0.6 * proximity

        return Rectangle()
            .fill(Color.orange.opacity(opacity))
            .frame(width: size, height: size)
            .rotationEffect(.degrees(45))
            .animation(.easeOut(duration: 0.08), value: proximity)
    }
}
```

Apply the style:

```swift
LSlider($value, range: 0...1, keepThumbInTrack: true, trackThickness: 40,
        tickMarkSpacing: .spacing(0.1), hapticFeedbackEnabled: true)
    .linearSliderStyle(BarLSliderStyle())
    .frame(height: 60)
```

The `linearSliderStyle` modifier cascades through the view hierarchy, so you can apply one style to a container and have it affect every ``LSlider`` inside it.

## Topics

### Essentials

- ``LSlider``
- ``LSliderStyle``
- ``LSliderConfiguration``
- ``TickMarkSpacing``

### Tutorials

- <doc:LSlider-Tutorials>
