import SwiftUI

struct ContentView: View {
    @State private var dist = 0.0
    @State private var dir  = Angle.zero

    var body: some View {
        RadialPad(offset: $dist, angle: $dir)
            .showPreviousValue(true)
            .frame(width: 260, height: 260)
            .padding()
    }
}
