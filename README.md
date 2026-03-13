<p align="center">
    <img src ="sliders-logo.png"  />
</p>

<p align="center">
    <img src="https://img.shields.io/badge/platforms-iOS_26_|macOS_26_| watchOS_26-blue.svg" alt="SwiftUI" />
    <img src="https://img.shields.io/badge/Swift-6.0-orange.svg" alt="Swift 6.0" />
    <img src="https://img.shields.io/badge/SwiftPM-compatible-green.svg" alt="Swift Package Manager" />
    <img src="https://img.shields.io/github/followers/kieranb662?label=Follow" alt="kieranb662 followers" />
</p>

**Sliders** is a collection of fully stylable, drag-based SwiftUI controls — linear, radial, range, 2-D, and path sliders — designed to fill the gaps the standard toolkit leaves behind. Every control scales to its container, accepts custom styles, and optionally provides tick marks with haptic feedback.
 You can try them all out quickly by cloning the example [project](https://github.com/kieranb662/SlidersExamples)

<p align="center">
    <img src="https://github.com/kieranb662/SlidersExamples/blob/master/Sliders%20Media/SlidersCollage.PNG" alt="Activity Rings Gif" >
</p>

> 📖 **Full API reference & tutorials** are available on the [hosted documentation site](https://kieranb662.github.io/Sliders-SwiftUI/documentation/sliders/).

---

## Controls at a Glance

| Control | Description | Docs |
|---|---|---|
| **LSlider** | A linear slider that works at any angle and scales its track to the available space. | [Guide](https://kieranb662.github.io/Sliders-SwiftUI/documentation/sliders/lsliderguide) · [Tutorial](https://kieranb662.github.io/Sliders-SwiftUI/tutorials/sliders/lslider-tutorials) |
| **DoubleLSlider** | A linear **range** slider with two thumbs and a draggable active-track segment. | [Guide](https://kieranb662.github.io/Sliders-SwiftUI/documentation/sliders/doublelsliderguide) · [Tutorial](https://kieranb662.github.io/Sliders-SwiftUI/tutorials/sliders/doublelslider-tutorials) |
| **RSlider** | A circular slider whose thumb travels around a configurable arc. | [Guide](https://kieranb662.github.io/Sliders-SwiftUI/documentation/sliders/rsliderguide) · [Tutorial](https://kieranb662.github.io/Sliders-SwiftUI/tutorials/sliders/rslider-tutorials) |
| **DoubleRSlider** | A circular **range** slider with two thumbs and a draggable active-track arc. | [Guide](https://kieranb662.github.io/Sliders-SwiftUI/documentation/sliders/doublersliderguide) · [Tutorial](https://kieranb662.github.io/Sliders-SwiftUI/tutorials/sliders/doublerslider-tutorials) |
| **TrackPad** | A 2-D slider that maps horizontal and vertical drag to two independent values. | [Guide](https://kieranb662.github.io/Sliders-SwiftUI/documentation/sliders/trackpadguide) · [Tutorial](https://kieranb662.github.io/Sliders-SwiftUI/tutorials/sliders/trackpad-tutorials) |
| **RadialPad** | A joystick-style 2-D control that retains its position after the drag ends. | [Guide](https://kieranb662.github.io/Sliders-SwiftUI/documentation/sliders/radialpadguide) · [Tutorial](https://kieranb662.github.io/Sliders-SwiftUI/tutorials/sliders/radialpad-tutorials) |
| **Joystick** | An on-screen joystick that appears wherever the user drags within a hit-box. | [Guide](https://kieranb662.github.io/Sliders-SwiftUI/documentation/sliders/joystickguide) · [Tutorial](https://kieranb662.github.io/Sliders-SwiftUI/tutorials/sliders/joystick-tutorials) |
| **PSlider** | Turns any SwiftUI `Shape` into a slider whose thumb travels along the shape's path. | [Guide](https://kieranb662.github.io/Sliders-SwiftUI/documentation/sliders/psliderguide) · [Tutorial](https://kieranb662.github.io/Sliders-SwiftUI/tutorials/sliders/pslider-tutorials) |
| **OverflowSlider** | A meter-style slider with two moving parts — thumb and track — and velocity gestures. | [Guide](https://kieranb662.github.io/Sliders-SwiftUI/documentation/sliders/overflowsliderguide) · [Tutorial](https://kieranb662.github.io/Sliders-SwiftUI/tutorials/sliders/overflowslider-tutorials) |

---

## Quick Start

```swift
import Sliders

struct ContentView: View {
    @State private var value = 0.5

    var body: some View {
        LSlider($value, range: 0...1, keepThumbInTrack: true, trackThickness: 20)
            .frame(height: 60)
            .padding()
    }
}
```

Every control follows the same styling pattern — conform to a style protocol and apply it with a modifier:

```swift
VStack {
    LSlider($red,   range: 0...1)
    LSlider($green, range: 0...1)
    LSlider($blue,  range: 0...1)
}
.linearSliderStyle(MyLSliderStyle())
```

---

## Requirements

| Platform | Minimum Version |
|---|---|
| iOS | 26 |
| macOS | 26 |
| watchOS | 26 |

## Installation

Add the package via **Swift Package Manager**:

1. In Xcode, go to **File → Add Package Dependencies**.
2. Paste the repository URL: `https://github.com/kieranb662/Sliders-SwiftUI`.
3. Select a minimum version and add the package to your target.

Or add it directly to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/kieranb662/Sliders-SwiftUI", from: "1.0.0")
]
```

---

## Documentation

| Resource | Link |
|---|---|
| **API Reference** | [kieranb662.github.io/Sliders-SwiftUI/documentation/sliders](https://kieranb662.github.io/Sliders-SwiftUI/documentation/sliders/) |
| **Tutorials** | [kieranb662.github.io/Sliders-SwiftUI/tutorials/sliders](https://kieranb662.github.io/Sliders-SwiftUI/tutorials/sliders/lslider-tutorials) |
| **Example Project** | [SlidersExamples](https://github.com/kieranb662/SlidersExamples) |

---

## License

**Sliders** is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
