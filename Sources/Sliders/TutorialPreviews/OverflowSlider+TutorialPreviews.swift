// Swift toolchain version 6.0
// Running macOS version 26.3
// Created on 3/13/26.
//
// Author: Kieran Brown
//
// Tutorial step previews for the OverflowSlider DocC tutorials.
// Basics: OverflowSlider_Basics_Step_1 … OverflowSlider_Basics_Step_4

import SwiftUI

// MARK: - Basics

// Step 1 – Minimal OverflowSlider
#Preview("OverflowSlider_Basics_Step_1") {
    struct Step1: View {
        @State private var value = 50.0
        var body: some View {
            OverflowSlider(value: $value, range: 0...500, spacing: 10, isDisabled: false)
                .frame(height: 60)
                .padding()
        }
    }
    return Step1()
}

// Step 2 – Wider range and finer spacing
#Preview("OverflowSlider_Basics_Step_2") {
    struct Step2: View {
        @State private var value = 250.0
        var body: some View {
            OverflowSlider(value: $value, range: 0...1000, spacing: 25, isDisabled: false)
                .overlay(RoundedRectangle(cornerRadius: 5).stroke())
                .frame(height: 60)
                .padding()
        }
    }
    return Step2()
}

// Step 3 – Velocity gestures demonstration
#Preview("OverflowSlider_Basics_Step_3") {
    struct Step3: View {
        @State private var value = 100.0
        var body: some View {
            VStack {
                Text("Value: \(Int(value))")
                    .font(.headline)

                Text("Drag the track quickly and release to throw it")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                OverflowSlider(value: $value, range: 0...500, spacing: 10, isDisabled: false)
                    .frame(height: 60)
            }
            .padding()
        }
    }
    return Step3()
}

// Step 4 – Custom style
#Preview("OverflowSlider_Basics_Step_4") {
    struct MyStyle: OverflowSliderStyle {
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
            .stroke(Color.orange.opacity(0.6))
            .frame(width: CGFloat(totalLength))
        }
    }

    struct Step4: View {
        @State private var value = 50.0
        var body: some View {
            OverflowSlider(value: $value, range: 0...500, spacing: 10, isDisabled: false)
                .overflowSliderStyle(MyStyle())
                .frame(height: 60)
                .padding()
        }
    }
    return Step4()
}
