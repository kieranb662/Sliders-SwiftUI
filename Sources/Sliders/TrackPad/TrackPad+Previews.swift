// Swift toolchain version 6.0
// Running macOS version 26.3
// Created on 3/13/26.
//
// Author: Kieran Brown
//

import SwiftUI

// MARK: - Preview Examples

#if !os(watchOS)
fileprivate struct TrackPadExamples: View {
    @State var point1 = CGPoint(x: 0.5, y: 0.5)
    @State var point2 = CGPoint(x: 0.5, y: 0.5)
    @State var point3 = CGPoint(x: 0.5, y: 0.5)
    @State var point4 = CGPoint(x: 0.0, y: 5.0)
    @State var point5 = CGPoint(x: 0.5, y: 0.5)
    @State var point6 = CGPoint(x: 0.5, y: 0.5)
    @State var point7 = CGPoint(x: 0.5, y: 0.5)
    @State var point8 = CGPoint(x: 0.5, y: 0.5)
    @State var point9  = CGPoint(x: 0.5, y: 0.5)
    @State var point10 = CGPoint(x: 0.5, y: 0.5)
    @State var point11 = CGPoint(x: 0.5, y: 0.5)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // ── Default style ─────────────────────────────────────────────
                GroupBox("Default Style") {
                    TrackPad($point1)
                        .frame(height: 220)
                    valueLabel(point1, rangeX: 0...1, rangeY: 0...1)
                }
                
                // ── Custom ranges ─────────────────────────────────────────────
                GroupBox("Custom Ranges (x: −1…1, y: 0…10)") {
                    TrackPad($point4, rangeX: -1...1, rangeY: 0...10)
                        .frame(height: 220)
                    valueLabel(point4, rangeX: -1...1, rangeY: 0...10)
                }
                
                // ── showPreviousValue — default indicator ─────────────────────
                GroupBox("showPreviousValue — default indicator") {
                    TrackPad($point2)
                        .showPreviousValue(true)
                        .frame(height: 220)
                    Text("Lift finger to commit; drag slowly near the ghost to snap back")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    valueLabel(point2, rangeX: 0...1, rangeY: 0...1)
                }
                
                // ── showPreviousValue — tight affinity ────────────────────────
                GroupBox("showPreviousValue — tight affinity (radius 3%, resistance 1%)") {
                    TrackPad($point3)
                        .showPreviousValue(true)
                        .previousValueAffinityRadius(0.03)
                        .previousValueAffinityResistance(0.01)
                        .frame(height: 220)
                    valueLabel(point3, rangeX: 0...1, rangeY: 0...1)
                }
                
                // ── showPreviousValue — loose affinity ────────────────────────
                GroupBox("showPreviousValue — loose affinity (radius 12%, velocity ≤350)") {
                    TrackPad($point5)
                        .showPreviousValue(true)
                        .previousValueAffinityRadius(0.12)
                        .previousValueVelocityThreshold(350)
                        .frame(height: 220)
                    Text("Larger pull zone; snaps even when moving somewhat quickly")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    valueLabel(point5, rangeX: 0...1, rangeY: 0...1)
                }
                
                // ── Custom style (.default preset with large thumb) ───────────
                GroupBox(".default(thumbSize: 48) preset + showPreviousValue") {
                    TrackPad($point6)
                        .showPreviousValue(true)
                        .trackPadStyle(.default(thumbSize: 48))
                        .frame(height: 220)
                    valueLabel(point6, rangeX: 0...1, rangeY: 0...1)
                }
                
                // ── Custom CrosshairTrackPadStyle ─────────────────────────────
                GroupBox("Custom CrosshairTrackPadStyle + diamond indicator") {
                    TrackPad($point7)
                        .showPreviousValue(true)
                        .trackPadStyle(CrosshairTrackPadStyle())
                        .frame(height: 220)
                    valueLabel(point7, rangeX: 0...1, rangeY: 0...1)
                }
                
                // ── Disabled state ────────────────────────────────────────────
                GroupBox("Disabled") {
                    TrackPad($point8)
                        .showPreviousValue(true)
                        .disabled(true)
                        .frame(height: 140)
                        .opacity(0.45)
                }
                
                // ── Tick marks — 4×4 grid ─────────────────────────────────────
                GroupBox("Tick Marks — 4×4 grid") {
                    TrackPad($point9)
                        .tickCount(4)
                        .frame(height: 220)
                    Text("Drag slowly near an intersection to snap to it")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    valueLabel(point9, rangeX: 0...1, rangeY: 0...1)
                }

                // ── Tick marks — x-axis only (3 intervals) ────────────────────
                GroupBox("Tick Marks — x-axis only (3 intervals)") {
                    TrackPad($point10)
                        .tickCountX(3)
                        .frame(height: 220)
                    Text("Vertical guide lines; snaps to nearest x tick when moving slowly")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    valueLabel(point10, rangeX: 0...1, rangeY: 0...1)
                }

                // ── Tick marks — large affinity radius ────────────────────────
                GroupBox("Tick Marks — 3×3 grid, large snap radius (10%)") {
                    TrackPad($point11)
                        .tickCount(3)
                        .tickAffinityRadius(0.10)
                        .tickAffinityResistance(0.04)
                        .frame(height: 220)
                    Text("Generous pull zone — easy to land on intersections")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    valueLabel(point11, rangeX: 0...1, rangeY: 0...1)
                }
            }
            .padding()
        }
    }
    
    @ViewBuilder
    private func valueLabel(_ point: CGPoint, rangeX: ClosedRange<CGFloat>, rangeY: ClosedRange<CGFloat>) -> some View {
        HStack(spacing: 16) {
            Label(String(format: "x: %.2f", point.x), systemImage: "arrow.left.arrow.right")
            Label(String(format: "y: %.2f", point.y), systemImage: "arrow.up.arrow.down"
            )
        }
        .font(.caption.monospacedDigit())
        .foregroundStyle(.secondary)
    }
}

#endif  // !os(watchOS)

// MARK: - Custom Preview Style

/// A crosshair-style track pad with a dot thumb and a 4×4 grid of guide dots.
private struct CrosshairTrackPadStyle: TrackPadStyle {
    
    func makeThumb(configuration: TrackPadConfiguration) -> some View {
        ZStack {
            Circle()
                .fill(configuration.isActive
                      ? Color(.sRGB, red: 0.084, green: 0.247, blue: 0.602)
                      : Color(.sRGB, red: 0.204, green: 0.648, blue: 0.855))
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
                .fill(Color(.sRGB, red: 0.084, green: 0.247, blue: 0.602).opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            Color(.sRGB, red: 0.084, green: 0.247, blue: 0.602).opacity(0.4),
                            lineWidth: 1
                        )
                )
            
            // 4×4 grid of guide dots
            GeometryReader { geo in
                let cols = 4
                let rows = 4
                ForEach(0..<cols, id: \.self) { col in
                    ForEach(0..<rows, id: \.self) { row in
                        Circle()
                            .fill(Color(.sRGB, red: 0.204, green: 0.648, blue: 0.855).opacity(0.3))
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
    
    /// Custom previous-value indicator: a filled diamond marker.
    func makePreviousValueIndicator(configuration: TrackPadConfiguration) -> some View {
        let snapped = configuration.isSnappedToPrevious
        let size: Double = snapped ? 14 : 9
        let fillColor = Color(.sRGB, red: 0.084, green: 0.247, blue: 0.602)
            .opacity(snapped ? 0.85 : 0.40)
        
        return ZStack {
            Rectangle()
                .fill(fillColor)
                .frame(width: size, height: size)
                .rotationEffect(.degrees(45))
            Rectangle()
                .strokeBorder(Color.white.opacity(snapped ? 0.6 : 0.2), lineWidth: 1)
                .frame(width: size, height: size)
                .rotationEffect(.degrees(45))
        }
        .animation(.easeOut(duration: 0.15), value: snapped)
    }
}

// MARK: - Previews

#Preview("Default Style") {
    @Previewable @State var point = CGPoint(x: 0.5, y: 0.5)
    VStack(spacing: 12) {
        TrackPad($point)
            .allowsSingleTapSelect(true)
            .frame(height: 240)
        HStack(spacing: 16) {
            Label(String(format: "x: %.2f", point.x), systemImage: "arrow.left.arrow.right")
            Label(String(format: "y: %.2f", point.y), systemImage: "arrow.up.arrow.down")
        }
        .font(.caption.monospacedDigit())
        .foregroundStyle(.secondary)
    }
    .padding()
}

#Preview("showPreviousValue + Affinity") {
    @Previewable @State var point = CGPoint(x: 0.5, y: 0.5)
    VStack(spacing: 12) {
        TrackPad($point)
            .showPreviousValue(true)
            .frame(height: 260)
        Text("Lift finger to commit a position.\nDrag slowly near the ghost to snap back.")
            .font(.caption)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
        HStack(spacing: 16) {
            Label(String(format: "x: %.2f", point.x), systemImage: "arrow.left.arrow.right")
            Label(String(format: "y: %.2f", point.y), systemImage: "arrow.up.arrow.down")
        }
        .font(.caption.monospacedDigit())
        .foregroundStyle(.secondary)
    }
    .padding()
}

#Preview("Custom Ranges") {
    @Previewable @State var point = CGPoint(x: 0.0, y: 5.0)
    VStack(spacing: 12) {
        TrackPad($point, rangeX: -1...1, rangeY: 0...10)
            .frame(height: 240)
        HStack(spacing: 16) {
            Label(String(format: "x: %.2f", point.x), systemImage: "arrow.left.arrow.right")
            Label(String(format: "y: %.2f", point.y), systemImage: "arrow.up.arrow.down")
        }
        .font(.caption.monospacedDigit())
        .foregroundStyle(.secondary)
    }
    .padding()
}

#Preview("Custom CrosshairTrackPadStyle") {
    @Previewable @State var point = CGPoint(x: 0.5, y: 0.5)
    VStack(spacing: 12) {
        TrackPad($point)
            .showPreviousValue(true)
            .trackPadStyle(CrosshairTrackPadStyle())
            .frame(height: 260)
        HStack(spacing: 16) {
            Label(String(format: "x: %.2f", point.x), systemImage: "arrow.left.arrow.right")
            Label(String(format: "y: %.2f", point.y), systemImage: "arrow.up.arrow.down")
        }
        .font(.caption.monospacedDigit())
        .foregroundStyle(.secondary)
    }
    .padding()
}

#Preview("Tick Marks — 4×4 Grid") {
    @Previewable @State var point = CGPoint(x: 0.5, y: 0.5)
    VStack(spacing: 12) {
        TrackPad($point)
            .tickCount(4)
            .frame(height: 260)
        Text("Drag slowly near an intersection to snap to it.\nFast swipes pass through freely.")
            .font(.caption)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
        HStack(spacing: 16) {
            Label(String(format: "x: %.2f", point.x), systemImage: "arrow.left.arrow.right")
            Label(String(format: "y: %.2f", point.y), systemImage: "arrow.up.arrow.down")
        }
        .font(.caption.monospacedDigit())
        .foregroundStyle(.secondary)
    }
    .padding()
}

#Preview("Tick Marks — x-axis Only") {
    @Previewable @State var point = CGPoint(x: 0.5, y: 0.5)
    VStack(spacing: 12) {
        TrackPad($point)
            .tickCountX(4)
            .frame(height: 260)
        Text("Vertical guide lines on the x-axis; snaps to nearest column.")
            .font(.caption)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
        HStack(spacing: 16) {
            Label(String(format: "x: %.2f", point.x), systemImage: "arrow.left.arrow.right")
            Label(String(format: "y: %.2f", point.y), systemImage: "arrow.up.arrow.down")
        }
        .font(.caption.monospacedDigit())
        .foregroundStyle(.secondary)
    }
    .padding()
}

#Preview("All Features") {
#if !os(watchOS)
    TrackPadExamples()
#else
    Text("Previews not available on watchOS")
#endif
}
