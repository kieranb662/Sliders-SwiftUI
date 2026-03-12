//
//  RadialSlider+Previews.swift
//  Sliders
//

import SwiftUI

// MARK: - Preview Styles

/// A style that shows a wind counter badge overlaid on the track.
struct WindCounterRSliderStyle: RSliderStyle {
    func makeThumb(configuration: RSliderConfiguration) -> some View {
        Circle()
            .frame(width: 24, height: 24)
            .foregroundStyle(configuration.isActive ? Color.orange : Color.white)
            .shadow(radius: configuration.isActive ? 6 : 2)
    }

    func makeTrack(configuration: RSliderConfiguration) -> some View {
        let fill = configuration.maxWinds > 0
            ? (configuration.value - configuration.min) / (configuration.max - configuration.min)
            : 0.0
        return ZStack {
            Circle()
                .stroke(Color.secondary.opacity(0.3), style: StrokeStyle(lineWidth: 12, lineCap: .round))
            Circle()
                .trim(from: 0, to: CGFloat(fill))
                .stroke(
                    LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            VStack(spacing: 2) {
                Text("\(Int(configuration.currentWind))")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                Text("winds")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

/// A minimal arc style that starts from the top (12 o'clock).
struct ArcRSliderStyle: RSliderStyle {
    func makeThumb(configuration: RSliderConfiguration) -> some View {
        Circle()
            .frame(width: 20, height: 20)
            .foregroundStyle(.white)
            .overlay(Circle().stroke(Color.teal, lineWidth: 3))
            .shadow(radius: 3)
    }

    func makeTrack(configuration: RSliderConfiguration) -> some View {
        let fill = configuration.maxWinds > 0
            ? (configuration.value - configuration.min) / (configuration.max - configuration.min)
            : 0.0
        return ZStack {
            Circle()
                .stroke(Color.teal.opacity(0.2), style: StrokeStyle(lineWidth: 8))
            Circle()
                .trim(from: 0, to: CGFloat(fill))
                .stroke(Color.teal, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                // rotationEffect so trim starts from 12 o'clock (−90°)
                .rotationEffect(.degrees(-90))
        }
    }
}

// MARK: - Previews

#Preview("Default Style – 1 Wind") {
    @Previewable @State var value = 0.5
    VStack(spacing: 16) {
        RSlider($value)
            .frame(width: 180, height: 180)
        Text(String(format: "Value: %.2f", value))
            .font(.caption)
    }
    .padding()
}

#Preview("Default Style – 2 Winds") {
    @Previewable @State var value = 0.0
    VStack(spacing: 16) {
        RSlider($value, maxWinds: 2)
            .frame(width: 180, height: 180)
        Text(String(format: "Value: %.2f", value))
            .font(.caption)
    }
    .padding()
}

#Preview("Default Style – Quarter Wind (0–90°)") {
    @Previewable @State var value = 0.0
    VStack(spacing: 16) {
        RSlider($value, maxWinds: 0.25)
            .frame(width: 180, height: 180)
        Text(String(format: "Value: %.2f", value))
            .font(.caption)
    }
    .padding()
}

#Preview("Origin at Top (12 o'clock)") {
    @Previewable @State var value = 0.0
    VStack(spacing: 16) {
        RSlider($value, originAngle: .degrees(-90))
            .frame(width: 180, height: 180)
        Text(String(format: "Value: %.2f", value))
            .font(.caption)
    }
    .padding()
}

#Preview("Origin at Top – 2 Winds") {
    @Previewable @State var value = 0.0
    VStack(spacing: 16) {
        RSlider($value, originAngle: .degrees(-90), maxWinds: 2)
            .frame(width: 180, height: 180)
        Text(String(format: "Value: %.2f", value))
            .font(.caption)
    }
    .padding()
}

#Preview("Custom Range – 0 to 100") {
    @Previewable @State var value = 50.0
    VStack(spacing: 16) {
        RSlider($value, range: 0...100, originAngle: .degrees(-90))
            .frame(width: 180, height: 180)
        Text(String(format: "Value: %.0f", value))
            .font(.caption)
    }
    .padding()
}

#Preview("Knob Style") {
    @Previewable @State var value = 0.25
    VStack(spacing: 16) {
        RSlider($value)
            .radialSliderStyle(KnobStyle())
            .frame(width: 200, height: 200)
        Text(String(format: "Value: %.2f", value))
            .font(.caption)
    }
    .padding()
}

#Preview("Knob Style – 3 Winds") {
    @Previewable @State var value = 0.0
    VStack(spacing: 16) {
        RSlider($value, originAngle: .degrees(-90), maxWinds: 3)
            .radialSliderStyle(KnobStyle())
            .frame(width: 200, height: 200)
        Text(String(format: "Value: %.2f", value))
            .font(.caption)
    }
    .padding()
}

#Preview("Arc Style – Top Origin") {
    @Previewable @State var value = 0.0
    VStack(spacing: 16) {
        RSlider($value, originAngle: .degrees(-90))
            .radialSliderStyle(ArcRSliderStyle())
            .frame(width: 180, height: 180)
        Text(String(format: "Value: %.2f", value))
            .font(.caption)
    }
    .padding()
}

#Preview("Wind Counter – 3 Winds") {
    @Previewable @State var value = 0.0
    VStack(spacing: 16) {
        RSlider($value, range: 0...100, originAngle: .degrees(-90), maxWinds: 3)
            .radialSliderStyle(WindCounterRSliderStyle())
            .frame(width: 200, height: 200)
        Text(String(format: "Value: %.1f / 100", value))
            .font(.caption)
    }
    .padding()
}

#Preview("Disabled") {
    @Previewable @State var value = 0.6
    VStack(spacing: 16) {
        RSlider($value)
            .disabled(true)
            .frame(width: 180, height: 180)
        Text("Disabled")
            .font(.caption)
            .foregroundStyle(.secondary)
    }
    .padding()
}

#Preview("Style Gallery") {
    @Previewable @State var v1 = 0.3
    @Previewable @State var v2 = 0.3
    @Previewable @State var v3 = 0.3
    @Previewable @State var v4 = 0.3

    ScrollView {
        VStack(spacing: 32) {
            HStack(spacing: 32) {
                VStack {
                    RSlider($v1)
                        .frame(width: 140, height: 140)
                    Text("Default").font(.caption)
                }
                VStack {
                    RSlider($v2)
                        .radialSliderStyle(KnobStyle())
                        .frame(width: 140, height: 140)
                    Text("Knob").font(.caption)
                }
            }
            HStack(spacing: 32) {
                VStack {
                    RSlider($v3, originAngle: .degrees(-90))
                        .radialSliderStyle(ArcRSliderStyle())
                        .frame(width: 140, height: 140)
                    Text("Arc").font(.caption)
                }
                VStack {
                    RSlider($v4, range: 0...100, originAngle: .degrees(-90), maxWinds: 2)
                        .radialSliderStyle(WindCounterRSliderStyle())
                        .frame(width: 140, height: 140)
                    Text("Wind Counter").font(.caption)
                }
            }
        }
        .padding()
    }
}
