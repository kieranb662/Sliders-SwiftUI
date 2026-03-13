import SwiftUI

struct MyJoystickStyle: JoystickStyle {
    func makeHitBox(configuration: JoystickConfiguration) -> some View {
        Rectangle()
            .fill(Color.green.opacity(0.05))
    }

    func makeLockBox(configuration: JoystickConfiguration) -> some View {
        ZStack {
            Circle().fill(Color.black)
            Image(systemName: "lock.fill")
                .foregroundColor(.green)
                .font(.caption)
        }
        .frame(width: 30, height: 30)
    }

    func makeTrack(configuration: JoystickConfiguration) -> some View {
        Circle()
            .fill(Color.green.opacity(0.2))
            .overlay(
                Circle().strokeBorder(Color.green.opacity(0.5), lineWidth: 2)
            )
    }

    func makeThumb(configuration: JoystickConfiguration) -> some View {
        Circle()
            .fill(configuration.isActive ? Color.green : Color.green.opacity(0.6))
            .frame(width: 45, height: 45)
            .shadow(color: .green.opacity(0.4), radius: configuration.isActive ? 8 : 0)
    }
}

struct ContentView: View {
    @State private var joyState: JoyState = .inactive

    var body: some View {
        Joystick(state: $joyState, radius: 60)
            .joystickStyle(MyJoystickStyle())
            .frame(width: 300, height: 300)
            .padding()
    }
}
