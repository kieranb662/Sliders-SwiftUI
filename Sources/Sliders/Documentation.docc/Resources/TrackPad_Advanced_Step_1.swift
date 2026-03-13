import SwiftUI

struct MyTrackPadStyle: TrackPadStyle {

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

struct ContentView: View {
    @State private var point = CGPoint(x: 0.5, y: 0.5)

    var body: some View {
        TrackPad($point)
            .trackPadStyle(MyTrackPadStyle())
            .frame(height: 260)
            .padding()
    }
}
