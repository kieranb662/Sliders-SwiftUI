// Swift toolchain version 6.0
// Running macOS version 26.3
// Created on 3/13/26.
//
// Author: Kieran Brown
//
// Tutorial step previews for the PSlider DocC tutorials.
// Basics: PSlider_Basics_Step_1 … PSlider_Basics_Step_4

import SwiftUI

// MARK: - Basics

// Step 1 – Minimal PSlider with Circle shape
#Preview("PSlider_Basics_Step_1") {
    struct Step1: View {
        @State private var value = 0.5
        var body: some View {
            PSlider($value, shape: Circle())
                .frame(width: 200, height: 200)
                .padding()
        }
    }
    return Step1()
}

// Step 2 – Custom range
#Preview("PSlider_Basics_Step_2") {
    struct Step2: View {
        @State private var value = 50.0
        var body: some View {
            PSlider($value, range: 0...100, shape: Circle())
                .frame(width: 200, height: 200)
                .padding()
        }
    }
    return Step2()
}

// Step 3 – RoundedRectangle shape
#Preview("PSlider_Basics_Step_3") {
    struct Step3: View {
        @State private var value = 0.5
        var body: some View {
            PSlider($value, shape: RoundedRectangle(cornerRadius: 20))
                .frame(width: 250, height: 150)
                .padding()
        }
    }
    return Step3()
}

// Step 4 – Custom style
#Preview("PSlider_Basics_Step_4") {
    struct MyStyle: PSliderStyle {
        func makeThumb(configuration: PSliderConfiguration) -> some View {
            Circle()
                .frame(width: 30, height: 30)
                .foregroundColor(configuration.isActive ? Color.yellow : Color.red)
        }
        func makeTrack(configuration: PSliderConfiguration) -> some View {
            ZStack {
                configuration.shape
                    .stroke(Color.gray, lineWidth: 8)
                configuration.shape
                    .trim(from: 0, to: CGFloat(configuration.pctFill))
                    .stroke(Color.green, lineWidth: 10)
            }
        }
    }

    struct Step4: View {
        @State private var value = 0.5
        var body: some View {
            PSlider($value, shape: Circle())
                .pathSliderStyle(MyStyle())
                .frame(width: 200, height: 200)
                .padding()
        }
    }
    return Step4()
}
