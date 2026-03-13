import SwiftUI

struct ContentView: View {
    @State private var joyState: JoyState = .inactive

    var body: some View {
        VStack(spacing: 20) {
            Joystick(state: $joyState, radius: 60)
                .frame(width: 300, height: 300)

            Joystick(state: .constant(.inactive), radius: 60, isDisabled: true)
                .frame(width: 300, height: 300)
                .opacity(0.5)
        }
        .padding()
    }
}
