// Swift toolchain version 6.0
// Running macOS version 26.3
// Created on 3/13/26.
//
// Author: Kieran Brown
//
// Tutorial step previews for the RadialPad DocC tutorials.
// Basics: RadialPad_Basics_Step_1 … RadialPad_Basics_Step_6

import SwiftUI

// MARK: - Basics

// Step 1 – Minimal RadialPad with all defaults
#Preview("RadialPad_Basics_Step_1") {
    struct Step1: View {
        @State private var dist = 0.0
        @State private var dir  = Angle.zero
        var body: some View {
            RadialPad(offset: $dist, angle: $dir)
                .frame(width: 260, height: 260)
                .padding()
        }
    }
    return Step1()
}

// Step 2 – Previous value indicator
#Preview("RadialPad_Basics_Step_2") {
    struct Step2: View {
        @State private var dist = 0.0
        @State private var dir  = Angle.zero
        var body: some View {
            RadialPad(offset: $dist, angle: $dir)
                .showPreviousValue(true)
                .frame(width: 260, height: 260)
                .padding()
        }
    }
    return Step2()
}

// Step 3 – Polar tick marks (rings + spokes)
#Preview("RadialPad_Basics_Step_3") {
    struct Step3: View {
        @State private var dist = 0.0
        @State private var dir  = Angle.zero
        var body: some View {
            RadialPad(offset: $dist, angle: $dir)
                .tickCountR(4)
                .tickCountTheta(8)
                .frame(width: 260, height: 260)
                .padding()
        }
    }
    return Step3()
}

// Step 4 – Tuning tick affinity
#Preview("RadialPad_Basics_Step_4") {
    struct Step4: View {
        @State private var dist = 0.0
        @State private var dir  = Angle.zero
        var body: some View {
            RadialPad(offset: $dist, angle: $dir)
                .tickCountR(4)
                .tickCountTheta(8)
                .tickAffinityRadius(0.08)
                .tickAffinityResistance(0.03)
                .frame(width: 260, height: 260)
                .padding()
        }
    }
    return Step4()
}

// Step 5 – Single-tap select
#Preview("RadialPad_Basics_Step_5") {
    struct Step5: View {
        @State private var dist = 0.0
        @State private var dir  = Angle.zero
        var body: some View {
            RadialPad(offset: $dist, angle: $dir)
                .allowsSingleTapSelect(true)
                .frame(width: 260, height: 260)
                .padding()
        }
    }
    return Step5()
}

// Step 6 – Custom label
#Preview("RadialPad_Basics_Step_6") {
    struct Step6: View {
        @State private var dist = 0.0
        @State private var dir  = Angle.zero
        var body: some View {
            RadialPad(offset: $dist, angle: $dir) { offset, angle in
                Text(String(format: "%.0f°  r=%.2f", angle.degrees, offset))
            }
            .frame(width: 260, height: 260)
            .padding()
        }
    }
    return Step6()
}
