import SwiftUI

struct MyPSliderStyle: PSliderStyle {
    func makeThumb(configuration: PSliderConfiguration) -> some View {
        Circle()
            .frame(width: 30, height: 30)
            .foregroundColor(configuration.isActive ? Color.yellow : Color.white)
    }

    func makeTrack(configuration: PSliderConfiguration) -> some View {
        ZStack {
            configuration.shape
                .stroke(Color.gray, lineWidth: 8)
            configuration.shape
                .trim(from: 0, to: CGFloat(configuration.pctFill))
                .stroke(Color.purple, lineWidth: 10)
        }
    }
}

struct ContentView: View {
    @State private var value = 0.5

    var body: some View {
        PSlider($value, shape: Circle())
            .pathSliderStyle(MyPSliderStyle())
            .frame(width: 200, height: 200)
            .padding()
    }
}
