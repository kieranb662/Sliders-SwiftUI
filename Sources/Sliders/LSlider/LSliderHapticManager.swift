// Swift toolchain version 6.0
// Running macOS version 26.3
// Created on 3/11/26.
//
// Author: Kieran Brown
//

#if canImport(CoreHaptics)
import CoreHaptics
import Foundation

/// Manages CoreHaptics playback for the LSlider tick mark feedback.
///
/// Call ``prepare()`` once before dragging begins (e.g. in `onChanged` the first time)
/// and ``playTick()`` whenever the thumb crosses a tick mark.
@MainActor
public final class LSliderHapticManager: ObservableObject, Sendable {

    private var engine: CHHapticEngine?
    private var isEngineReady = false

    public init() {
        prepare()
    }

    /// Prepares the haptic engine. Safe to call multiple times.
    public func prepare() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            let newEngine = try CHHapticEngine()
            newEngine.resetHandler = { [weak self] in
                Task { @MainActor in
                    self?.isEngineReady = false
                    self?.prepare()
                }
            }
            newEngine.stoppedHandler = { [weak self] _ in
                Task { @MainActor in
                    self?.isEngineReady = false
                }
            }
            try newEngine.start()
            engine = newEngine
            isEngineReady = true
        } catch {
            isEngineReady = false
        }
    }

    /// Plays a subtle tick haptic pattern.
    /// - Parameter intensity: A value in 0…1 controlling the strength of the tick. Defaults to 0.6.
    public func playTick(intensity: Float = 0.6) {
        guard isEngineReady, let engine else { return }

        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
        let intensityParam = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [sharpness, intensityParam],
            relativeTime: 0,
            duration: 0.05
        )

        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            // Haptics are best-effort; silently ignore playback failures.
        }
    }
}
#else
/// Stub for platforms that don't support CoreHaptics (e.g. macOS < 10.15, watchOS).
@MainActor
public final class LSliderHapticManager: ObservableObject, Sendable {
    public init() {}
    public func prepare() {}
    public func playTick(intensity: Float = 0.6) {}
}
#endif
