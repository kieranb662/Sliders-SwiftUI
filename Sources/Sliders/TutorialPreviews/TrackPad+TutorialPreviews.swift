// Swift toolchain version 6.0
// Running macOS version 26.3
// Created on 3/13/26.
//
// Author: Kieran Brown
//
// Tutorial step previews for the TrackPad DocC tutorials.
// Basics:   TrackPad_Basics_Step_1  … TrackPad_Basics_Step_8
// Advanced: TrackPad_Advanced_Step_1 … TrackPad_Advanced_Step_5

import SwiftUI

// MARK: - Basics

// Step 1 – Minimal TrackPad with all defaults
#Preview("TrackPad_Basics_Step_1") {
    struct Step1: View {
        @State private var point = CGPoint(x: 0.5, y: 0.5)
        var body: some View {
            TrackPad($point)
                .frame(height: 260)
                .padding()
        }
    }
    return Step1()
}

// Step 2 – Custom rangeX and rangeY
#Preview("TrackPad_Basics_Step_2") {
    struct Step2: View {
        @State private var point = CGPoint(x: 0.0, y: 5.0)
        var body: some View {
            TrackPad($point, rangeX: -1...1, rangeY: 0...10)
                .frame(height: 260)
                .padding()
        }
    }
    return Step2()
}

// Step 3 – Double bindings (separate x and y)
#Preview("TrackPad_Basics_Step_3") {
    struct Step3: View {
        @State private var pan: Double = 0.0
        @State private var tilt: Double = 0.0
        var body: some View {
            TrackPad(x: $pan, y: $tilt, rangeX: -1...1, rangeY: -1...1)
                .frame(height: 260)
                .padding()
        }
    }
    return Step3()
}

// Step 4 – Previous value indicator
#Preview("TrackPad_Basics_Step_4") {
    struct Step4: View {
        @State private var point = CGPoint(x: 0.5, y: 0.5)
        var body: some View {
            TrackPad($point)
                .showPreviousValue(true)
                .frame(height: 260)
                .padding()
        }
    }
    return Step4()
}

// Step 5 – Tuning previous-value affinity
#Preview("TrackPad_Basics_Step_5") {
    struct Step5: View {
        @State private var point = CGPoint(x: 0.5, y: 0.5)
        var body: some View {
            TrackPad($point)
                .showPreviousValue(true)
                .previousValueAffinityRadius(0.03)
                .previousValueAffinityResistance(0.01)
                .frame(height: 260)
                .padding()
        }
    }
    return Step5()
}

// Step 6 – Tick grid (both axes with .tickCount)
#Preview("TrackPad_Basics_Step_6") {
    struct Step6: View {
        @State private var point = CGPoint(x: 0.5, y: 0.5)
        var body: some View {
            TrackPad($point)
                .tickCount(4)
                .frame(height: 260)
                .padding()
        }
    }
    return Step6()
}

// Step 7 – Independent axis tick counts
#Preview("TrackPad_Basics_Step_7") {
    struct Step7: View {
        @State private var point = CGPoint(x: 0.5, y: 0.5)
        var body: some View {
            TrackPad($point)
                .tickCountX(3)
                .tickCountY(5)
                .frame(height: 260)
                .padding()
        }
    }
    return Step7()
}

// Step 8 – Custom label and disabled state
#Preview("TrackPad_Basics_Step_8") {
    struct Step8: View {
        @State private var point = CGPoint(x: 0.5, y: 0.5)
        var body: some View {
            VStack(spacing: 20) {
                TrackPad($point, rangeX: -1...1, rangeY: -1...1) { x, y in
                    Text(String(format: "x: %.2f  y: %.2f", x, y))
                }
                .frame(height: 260)

                TrackPad(.constant(CGPoint(x: 0.5, y: 0.5)))
                    .disabled(true)
                    .frame(height: 260)
            }
            .padding()
        }
    }
    return Step8()
}

// MARK: - Advanced

// Step 1 – Declare MyTrackPadStyle with stub implementations
#Preview("TrackPad_Advanced_Step_1") {
    struct MyStyle: TrackPadStyle {
        func makeThumb(configuration: TrackPadConfiguration) -> some View {
            Circle()
                .fill(Color.gray)
                .frame(width: 20, height: 20)
        }
        func makeTrack(configuration: TrackPadConfiguration) -> some View {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.15))
        }
    }

    struct Step1: View {
        @State private var point = CGPoint(x: 0.5, y: 0.5)
        var body: some View {
            TrackPad($point)
                .trackPadStyle(MyStyle())
                .frame(height: 260)
                .padding()
        }
    }
    return Step1()
}

// Step 2 – Implement makeTrack with dot grid
#Preview("TrackPad_Advanced_Step_2") {
    struct MyStyle: TrackPadStyle {
        func makeThumb(configuration: TrackPadConfiguration) -> some View {
            Circle()
                .fill(Color.gray)
                .frame(width: 20, height: 20)
        }
        func makeTrack(configuration: TrackPadConfiguration) -> some View {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.blue.opacity(0.4), lineWidth: 1)
                    )
                GeometryReader { geo in
                    let cols = 4; let rows = 4
                    ForEach(0..<cols, id: \.self) { col in
                        ForEach(0..<rows, id: \.self) { row in
                            Circle()
                                .fill(Color.blue.opacity(0.3))
                                .frame(width: 3, height: 3)
                                .position(
                                    x: geo.size.width  * CGFloat(col + 1) / CGFloat(cols + 1),
                                    y: geo.size.height * CGFloat(row + 1) / CGFloat(rows + 1)
                                )
                        }
                    }
                }
            }
        }
    }

    struct Step2: View {
        @State private var point = CGPoint(x: 0.5, y: 0.5)
        var body: some View {
            TrackPad($point)
                .trackPadStyle(MyStyle())
                .frame(height: 260)
                .padding()
        }
    }
    return Step2()
}

// Step 3 – Implement makeThumb with active state
#Preview("TrackPad_Advanced_Step_3") {
    struct MyStyle: TrackPadStyle {
        func makeThumb(configuration: TrackPadConfiguration) -> some View {
            ZStack {
                Circle()
                    .fill(configuration.isActive ? Color.blue.opacity(0.8) : Color.blue)
                    .frame(width: 20, height: 20)
                Circle()
                    .fill(Color.white)
                    .frame(width: 6, height: 6)
            }
            .shadow(color: .black.opacity(0.25), radius: configuration.isActive ? 8 : 3)
            .animation(.easeOut(duration: 0.1), value: configuration.isActive)
        }
        func makeTrack(configuration: TrackPadConfiguration) -> some View {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.blue.opacity(0.4), lineWidth: 1)
                    )
                GeometryReader { geo in
                    let cols = 4; let rows = 4
                    ForEach(0..<cols, id: \.self) { col in
                        ForEach(0..<rows, id: \.self) { row in
                            Circle()
                                .fill(Color.blue.opacity(0.3))
                                .frame(width: 3, height: 3)
                                .position(
                                    x: geo.size.width  * CGFloat(col + 1) / CGFloat(cols + 1),
                                    y: geo.size.height * CGFloat(row + 1) / CGFloat(rows + 1)
                                )
                        }
                    }
                }
            }
        }
    }

    struct Step3: View {
        @State private var point = CGPoint(x: 0.5, y: 0.5)
        var body: some View {
            TrackPad($point)
                .trackPadStyle(MyStyle())
                .frame(height: 260)
                .padding()
        }
    }
    return Step3()
}

// Step 4 – Implement makePreviousValueIndicator
#Preview("TrackPad_Advanced_Step_4") {
    struct MyStyle: TrackPadStyle {
        func makeThumb(configuration: TrackPadConfiguration) -> some View {
            ZStack {
                Circle()
                    .fill(configuration.isActive ? Color.blue.opacity(0.8) : Color.blue)
                    .frame(width: 20, height: 20)
                Circle()
                    .fill(Color.white)
                    .frame(width: 6, height: 6)
            }
            .shadow(color: .black.opacity(0.25), radius: configuration.isActive ? 8 : 3)
            .animation(.easeOut(duration: 0.1), value: configuration.isActive)
        }
        func makeTrack(configuration: TrackPadConfiguration) -> some View {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.blue.opacity(0.4), lineWidth: 1)
                    )
                GeometryReader { geo in
                    let cols = 4; let rows = 4
                    ForEach(0..<cols, id: \.self) { col in
                        ForEach(0..<rows, id: \.self) { row in
                            Circle()
                                .fill(Color.blue.opacity(0.3))
                                .frame(width: 3, height: 3)
                                .position(
                                    x: geo.size.width  * CGFloat(col + 1) / CGFloat(cols + 1),
                                    y: geo.size.height * CGFloat(row + 1) / CGFloat(rows + 1)
                                )
                        }
                    }
                }
            }
        }
        func makePreviousValueIndicator(configuration: TrackPadConfiguration) -> some View {
            let snapped = configuration.isSnappedToPrevious
            let size: Double = snapped ? 14 : 9
            return Rectangle()
                .fill(Color.blue.opacity(snapped ? 0.85 : 0.40))
                .frame(width: size, height: size)
                .rotationEffect(.degrees(45))
                .animation(.easeOut(duration: 0.15), value: snapped)
        }
    }

    struct Step4: View {
        @State private var point = CGPoint(x: 0.5, y: 0.5)
        var body: some View {
            TrackPad($point)
                .showPreviousValue(true)
                .trackPadStyle(MyStyle())
                .frame(height: 260)
                .padding()
        }
    }
    return Step4()
}

// Step 5 – Apply finished style with previous-value and tick marks
#Preview("TrackPad_Advanced_Step_5") {
    struct MyStyle: TrackPadStyle {
        func makeThumb(configuration: TrackPadConfiguration) -> some View {
            ZStack {
                Circle()
                    .fill(configuration.isActive ? Color.blue.opacity(0.8) : Color.blue)
                    .frame(width: 20, height: 20)
                Circle()
                    .fill(Color.white)
                    .frame(width: 6, height: 6)
            }
            .shadow(color: .black.opacity(0.25), radius: configuration.isActive ? 8 : 3)
            .animation(.easeOut(duration: 0.1), value: configuration.isActive)
        }
        func makeTrack(configuration: TrackPadConfiguration) -> some View {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.blue.opacity(0.4), lineWidth: 1)
                    )
                GeometryReader { geo in
                    let cols = 4; let rows = 4
                    ForEach(0..<cols, id: \.self) { col in
                        ForEach(0..<rows, id: \.self) { row in
                            Circle()
                                .fill(Color.blue.opacity(0.3))
                                .frame(width: 3, height: 3)
                                .position(
                                    x: geo.size.width  * CGFloat(col + 1) / CGFloat(cols + 1),
                                    y: geo.size.height * CGFloat(row + 1) / CGFloat(rows + 1)
                                )
                        }
                    }
                }
            }
        }
        func makePreviousValueIndicator(configuration: TrackPadConfiguration) -> some View {
            let snapped = configuration.isSnappedToPrevious
            let size: Double = snapped ? 14 : 9
            return Rectangle()
                .fill(Color.blue.opacity(snapped ? 0.85 : 0.40))
                .frame(width: size, height: size)
                .rotationEffect(.degrees(45))
                .animation(.easeOut(duration: 0.15), value: snapped)
        }
    }

    struct Step5: View {
        @State private var pointA = CGPoint(x: 0.5, y: 0.5)
        @State private var pointB = CGPoint(x: 0.5, y: 0.5)
        var body: some View {
            VStack(spacing: 20) {
                TrackPad($pointA)
                    .showPreviousValue(true)
                    .tickCount(4)
                    .frame(height: 260)

                TrackPad($pointB, rangeX: -1...1, rangeY: -1...1)
                    .frame(height: 200)
            }
            .trackPadStyle(MyStyle())
            .padding()
        }
    }
    return Step5()
}
