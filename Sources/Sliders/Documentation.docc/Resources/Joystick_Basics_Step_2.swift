import SwiftUI

struct ContentView: View {
    @State private var joyState: JoyState = .inactive

    var body: some View {
        Joystick(state: $joyState, radius: 60, canLock: false, isDisabled: false)
            .frame(width: 300, height: 300)
            .padding()
    }
}
