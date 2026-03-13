import SwiftUI

struct MyTrackPadStyle: TrackPadStyle {

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

struct ContentView: View {
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
        .trackPadStyle(MyTrackPadStyle())
        .padding()
    }
}
