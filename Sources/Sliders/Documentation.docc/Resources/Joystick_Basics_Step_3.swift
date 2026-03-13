import SwiftUI

struct ContentView: View {
    @State private var joyState: JoyState = .inactive

    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading) {
                Text("Angle: \(joyState.angle.degrees, specifier: "%.0f")°")
                Text("Offset: \(joyState.radialOffset, specifier: "%.1f")")
                Text("Locked: \(joyState.isLocked ? "Yes" : "No")")
                Text("Active: \(joyState.isActive ? "Yes" : "No")")
            }
            .font(.system(.body, design: .monospaced))

            Joystick(state: $joyState, radius: 60)
                .frame(width: 300, height: 300)
        }
        .padding()
    }
}
