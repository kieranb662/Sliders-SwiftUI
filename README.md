<p align="center">
    <img src ="SlidersLogo.svg" width=500 />
</p>

<p align="center">
    <img src="https://img.shields.io/badge/platform-SwiftUI-red.svg" alt="Swift UI" />
    <img src="https://img.shields.io/badge/Swift-5.1-orange.svg" alt="Swift 5.1" />
</p>

## Examples Created Using Sliders 

<p align="center">
    <img src="https://github.com/kieranb662/SlidersExamples/blob/master/Sliders%20Media/ActivityRings.gif" alt="Activity Rings Gif" height=300 />
    <img src="https://github.com/kieranb662/SlidersExamples/blob/master/Sliders%20Media/RGBColorPicker.gif" alt="RGB Color Picker" height=300 />
    <img src="https://github.com/kieranb662/SlidersExamples/blob/master/Sliders%20Media/LSlider.gif" alt="LSlider Example" height=300 />
    <img src="https://github.com/kieranb662/SlidersExamples/blob/master/Sliders%20Media/RadialPadHSBPicker.gif" alt="RadialPad HSB Color Picker" height=300 />
    <img src="https://github.com/kieranb662/SlidersExamples/blob/master/Sliders%20Media/Joystick.gif" alt="JoyStick" height=300 />
</p>

**Sliders** is a compilation of all my stylable drag based SwiftUI components. It provides a variety of unique controls as well as an enhanced version of the normal `Slider` called an `LSlider`. You can try them all out quickly by clone the example [project](https://github.com/kieranb662/SlidersExamples)

The various components are: 
* `LSlider` - a spatially adaptive slider that fits to its container at any angle you decide.
* `RSlider` - A circularly shaped slider which restricts movement of the thumb to the radius of the circle 
* `PSlider` - Turn any `Shape` into its very own slider!
* `OverflowSlider` - A meter like slider which has two moving components, the track and the thumb. Also has velocity based gestures implemented 
* `TrackPad` - A 2D version of a normal slider, which restricts displacement of the thumb to the bounds of the track 
* `RadialPad` - A joystick like component that does not reset the position of the thumb upon gesture end. 
* `Joystick` - an onscreen joystick that can appear anywhere the user drags within the defined hitbox, if the drag ends inside the lockbox, the joystick remains onscreen locked in the forward position. if the drag ends **not** inside the lockbox the joystick fades away until the hitbox is dragged again.



## Requirements 

**Sliders** as a default requires the SwiftUI Framework to be operational and since the `DragGesture` is required only these platforms can make use of the library:

* macOS 10.15 or Greater 
* iOS 13 or Greater 
* watchOS 6 or Greater

## How To Add To Your Project

1. Snag that URL from the github repo 
2. In Xcode -> File -> Swift Packages -> Add Package Dependencies 
3. Paste the URL Into the box
4. Specify the minimum version number (This is new so 1.0.3 and greater will work).

## Dependencies 

* [CGExtender](https://github.com/kieranb662/CGExtender)
* [Shapes](https://github.com/kieranb662/Shapes) - Currently looking for contributors 
* [bez](https://github.com/kieranb662/bez)



