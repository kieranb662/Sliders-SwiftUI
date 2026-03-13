import SwiftUI

struct MyTrackPadStyle: TrackPadStyle {

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

struct ContentView: View {
    @State private var point = CGPoint(x: 0.5, y: 0.5)

    var body: some View {
        TrackPad($point)
            .trackPadStyle(MyTrackPadStyle())
            .frame(height: 260)
            .padding()
    }
}
