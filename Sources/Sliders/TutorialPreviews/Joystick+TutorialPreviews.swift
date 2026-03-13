// Swift toolchain version 6.0
// Running macOS version 26.3
// Created on 3/13/26.
//
// Author: Kieran Brown
//
// Tutorial step previews for the Joystick DocC tutorials.
// Basics: Joystick_Basics_Step_1 … Joystick_Basics_Step_5

import SwiftUI

// MARK: - Basics

// Step 1 – Minimal Joystick with hitbox
#Preview("Joystick_Basics_Step_1") {
    struct Step1: View {
        @State private var joyState: JoyState = .inactive
        var body: some View {
            Joystick(state: $joyState, radius: 60)
                .frame(width: 300, height: 300)
                .padding()
        }
    }
    return Step1()
}

// Step 2 – Lockbox disabled
#Preview("Joystick_Basics_Step_2") {
    struct Step2: View {
        @State private var joyState: JoyState = .inactive
        var body: some View {
            Joystick(state: $joyState, radius: 60, canLock: false, isDisabled: false)
                .frame(width: 300, height: 300)
                .padding()
        }
    }
    return Step2()
}

// Step 3 – Reading angle and radial offset
#Preview("Joystick_Basics_Step_3") {
    struct Step3: View {
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
    return Step3()
}

// Step 4 – Custom style
#Preview("Joystick_Basics_Step_4") {
    struct MyStyle: JoystickStyle {
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

    struct Step4: View {
        @State private var joyState: JoyState = .inactive
        var body: some View {
            Joystick(state: $joyState, radius: 60)
                .joystickStyle(MyStyle())
                .frame(width: 300, height: 300)
                .padding()
        }
    }
    return Step4()
}

// Step 5 – Disabled state
#Preview("Joystick_Basics_Step_5") {
    struct Step5: View {
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
    return Step5()
}
