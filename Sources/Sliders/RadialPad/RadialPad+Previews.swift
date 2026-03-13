// Swift toolchain version 6.0
// Running macOS version 26.3
// Created on 3/13/26.
//
// Author: Kieran Brown
//

import SwiftUI

// MARK: - Preview Examples

#if !os(watchOS)
fileprivate struct RadialPadExamples: View {
    @State var offset1 = 0.5
    @State var angle1  = Angle.zero

    @State var offset2 = 0.5
    @State var angle2  = Angle.zero

    @State var offset3 = 0.5
    @State var angle3  = Angle.zero

    @State var offset4 = 0.5
    @State var angle4  = Angle.zero

    @State var offset5 = 0.5
    @State var angle5  = Angle.zero

    @State var offset6 = 0.5
    @State var angle6  = Angle.zero

    @State var offset7 = 0.5
    @State var angle7  = Angle.zero

    @State var offset8 = 0.5
    @State var angle8  = Angle.zero

    @State var offset9 = 0.5
    @State var angle9  = Angle.zero

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // ── Default style ─────────────────────────────────────────────
                GroupBox("Default Style") {
                    RadialPad(offset: $offset1, angle: $angle1)
                        .allowsSingleTapSelect(true)
                        .frame(width: 220, height: 220)
                    polarLabel(offset: offset1, angle: angle1)
                }

                // ── showPreviousValue — default affinity ──────────────────────
                GroupBox("showPreviousValue (default affinity)") {
                    RadialPad(offset: $offset2, angle: $angle2)
                        .showPreviousValue(true)
                        .frame(width: 220, height: 220)
                    Text("Lift finger to commit; drag slowly near the ghost to snap back")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    polarLabel(offset: offset2, angle: angle2)
                }

                // ── showPreviousValue — tight affinity ────────────────────────
                GroupBox("showPreviousValue — tight affinity (radius 3%, resistance 1%)") {
                    RadialPad(offset: $offset3, angle: $angle3)
                        .showPreviousValue(true)
                        .previousValueAffinityRadius(0.03)
                        .previousValueAffinityResistance(0.01)
                        .frame(width: 220, height: 220)
                    polarLabel(offset: offset3, angle: angle3)
                }

                // ── showPreviousValue — loose affinity ────────────────────────
                GroupBox("showPreviousValue — loose affinity (radius 12%, velocity ≤350)") {
                    RadialPad(offset: $offset4, angle: $angle4)
                        .showPreviousValue(true)
                        .previousValueAffinityRadius(0.12)
                        .previousValueVelocityThreshold(350)
                        .frame(width: 220, height: 220)
                    Text("Larger pull zone; snaps even when moving somewhat quickly")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    polarLabel(offset: offset4, angle: angle4)
                }

                // ── Polar tick marks — rings only ─────────────────────────────
                GroupBox("Tick marks — 4 rings only (tickCountR: 4)") {
                    RadialPad(offset: $offset5, angle: $angle5)
                        .tickCountR(4)
                        .frame(width: 220, height: 220)
                    polarLabel(offset: offset5, angle: angle5)
                }

                // ── Polar tick marks — spokes only ────────────────────────────
                GroupBox("Tick marks — 8 spokes only (tickCountTheta: 8)") {
                    RadialPad(offset: $offset6, angle: $angle6)
                        .tickCountTheta(8)
                        .frame(width: 220, height: 220)
                    polarLabel(offset: offset6, angle: angle6)
                }

                // ── Polar tick marks — rings + spokes with snapping ───────────
                GroupBox("Tick marks + snapping — 3 rings × 12 spokes") {
                    RadialPad(offset: $offset7, angle: $angle7)
                        .tickCount(r: 3, theta: 12)
                        .frame(width: 220, height: 220)
                    Text("Drag slowly near an intersection to snap to it")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    polarLabel(offset: offset7, angle: angle7)
                }

                // ── Full-featured: previous value + ticks ─────────────────────
                GroupBox("showPreviousValue + tick marks (4 × 8) + custom style") {
                    RadialPad(offset: $offset8, angle: $angle8)
                        .showPreviousValue(true)
                        .tickCount(r: 4, theta: 8)
                        .radialPadStyle(.default(thumbSize: 44))
                        .frame(width: 220, height: 220)
                    polarLabel(offset: offset8, angle: angle8)
                }

                // ── Disabled state ────────────────────────────────────────────
                GroupBox("Disabled") {
                    RadialPad(offset: $offset9, angle: $angle9)
                        .showPreviousValue(true)
                        .disabled(true)
                        .frame(width: 220, height: 220)
                }
            }
            .padding()
        }
    }

    @ViewBuilder
    func polarLabel(offset: Double, angle: Angle) -> some View {
        HStack(spacing: 16) {
            Text("r: \(offset, specifier: "%.3f")")
                .monospacedDigit()
            Text("θ: \(angle.degrees, specifier: "%.1f")°")
                .monospacedDigit()
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }
}

// MARK: - Custom style example

/// A minimal custom style used in the previews.
private struct NeonRadialPadStyle: RadialPadStyle {
    func makeTrack(configuration: RadialPadConfiguration) -> some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.85))
            Circle()
                .strokeBorder(
                    LinearGradient(
                        colors: [.cyan, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        }
    }

    func makeThumb(configuration: RadialPadConfiguration) -> some View {
        Circle()
            .fill(configuration.isActive ? Color.white : Color.cyan)
            .frame(width: 32, height: 32)
            .overlay(
                Circle()
                    .strokeBorder(Color.purple.opacity(0.7), lineWidth: 1.5)
            )
            .shadow(color: .cyan.opacity(0.7), radius: configuration.isActive ? 8 : 2)
    }

    func makePreviousValueIndicator(configuration: RadialPadConfiguration) -> some View {
        let snapped = configuration.isSnappedToPrevious
        return Circle()
            .strokeBorder(Color.purple.opacity(snapped ? 0.9 : 0.4), lineWidth: snapped ? 2 : 1)
            .frame(width: snapped ? 20 : 14, height: snapped ? 20 : 14)
            .animation(.easeOut(duration: 0.15), value: snapped)
    }

    func makeTickMarks(configuration: RadialPadConfiguration) -> some View {
        GeometryReader { geo in
            let size  = min(geo.size.width, geo.size.height)
            let radius = size / 2
            let cx = geo.size.width  / 2
            let cy = geo.size.height / 2
            let nr = configuration.tickCountR
            let nt = configuration.tickCountTheta

            ZStack {
                if nr > 0 {
                    ForEach(1...nr, id: \.self) { ir in
                        let fr = CGFloat(ir) / CGFloat(nr)
                        Circle()
                            .strokeBorder(Color.cyan.opacity(0.15), lineWidth: 1)
                            .frame(width: fr * size, height: fr * size)
                            .position(x: cx, y: cy)
                    }
                }
                if nt > 0 {
                    ForEach(0..<nt, id: \.self) { it in
                        let theta = 2.0 * Double.pi * Double(it) / Double(nt)
                        let ex = cx + radius * CGFloat(cos(theta))
                        let ey = cy + radius * CGFloat(sin(theta))
                        Path { p in
                            p.move(to: CGPoint(x: cx, y: cy))
                            p.addLine(to: CGPoint(x: ex, y: ey))
                        }
                        .stroke(Color.purple.opacity(0.15), lineWidth: 1)
                    }
                }
            }
        }
    }
}

// MARK: - Preview registration

#Preview("RadialPad Examples") {
    RadialPadExamples()
}
#endif
