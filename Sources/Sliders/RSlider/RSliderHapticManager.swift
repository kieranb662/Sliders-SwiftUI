// Swift toolchain version 6.0
// Running macOS version 26.3
// Created on 3/12/26.
//
// Author: Kieran Brown
//

#if canImport(CoreHaptics)
import CoreHaptics
import Foundation

/// Manages CoreHaptics playback for the RSlider.
///
/// ### Event catalogue
/// - ``playLimitHit()``         – sharp impact when the thumb reaches min or max.
/// - ``playTick(intensity:)``   – light transient as the thumb crosses a tick mark.
/// - ``playSnapIn()``           – two-pulse "magnetic pull" when affinity snaps the thumb onto a tick.
/// - ``updateWindTension(_:)``  – continuous haptic engine that ramps intensity with the
///   fractional wind position and fires a crisp pop each time a full wind boundary is crossed.
///
/// Call ``prepare()`` before the first drag event and ``stopContinuous()`` when dragging ends.
@MainActor
public final class RSliderHapticManager: ObservableObject, Sendable {

    private var engine: CHHapticEngine?
    private var isEngineReady = false

    /// The continuous wind-tension player (nil when not playing).
    private var tensionPlayer: CHHapticAdvancedPatternPlayer?
    /// The last integer wind boundary that triggered a pop, used to debounce.
    private var lastWindPop: Int = -1

    public init() {
        prepare()
    }

    // MARK: - Engine lifecycle

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
                    self?.tensionPlayer = nil
                }
            }
            try newEngine.start()
            engine = newEngine
            isEngineReady = true
        } catch {
            isEngineReady = false
        }
    }

    // MARK: - Transient events

    /// Plays a sharp impact haptic when the slider hits its minimum or maximum boundary.
    public func playLimitHit() {
        guard isEngineReady, let engine else { return }
        do {
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
            let event = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [sharpness, intensity],
                relativeTime: 0,
                duration: 0.1
            )
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            // Best-effort; ignore playback failures.
        }
    }

    /// Plays a subtle tick haptic as the thumb crosses a tick mark value.
    /// - Parameter intensity: A value in 0…1 controlling the strength. Defaults to `0.6`.
    public func playTick(intensity: Float = 0.6) {
        guard isEngineReady, let engine else { return }
        do {
            let sharpness  = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
            let intensityP = CHHapticEventParameter(parameterID: .hapticIntensity,  value: intensity)
            let event = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [sharpness, intensityP],
                relativeTime: 0,
                duration: 0.05
            )
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch { }
    }

    /// Plays a two-pulse "magnetic pull" haptic when affinity snaps the thumb onto a tick mark.
    ///
    /// A soft leading pulse (the "pull") is immediately followed by a firmer landing pulse
    /// (the "snap"), giving the sensation of the thumb being drawn in and settling into place.
    public func playSnapIn() {
        guard isEngineReady, let engine else { return }
        do {
            // Soft leading pulse — the "pull"
            let softSharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
            let softIntensity = CHHapticEventParameter(parameterID: .hapticIntensity,  value: 0.4)
            let leadPulse = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [softSharpness, softIntensity],
                relativeTime: 0,
                duration: 0.05
            )
            // Firm landing pulse — the "snap"
            let firmSharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.9)
            let firmIntensity = CHHapticEventParameter(parameterID: .hapticIntensity,  value: 0.85)
            let landPulse = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [firmSharpness, firmIntensity],
                relativeTime: 0.06,
                duration: 0.05
            )
            let pattern = try CHHapticPattern(events: [leadPulse, landPulse], parameters: [])
            let player  = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch { }
    }

    // MARK: - Continuous wind-tension haptic

    /// Updates the continuous wind-tension haptic to reflect the current dragging position.
    ///
    /// - Parameter totalWind: The total fractional wind position, e.g. `currentWind + withinWind`.
    ///   This value increases monotonically as the slider is wound up.
    ///
    /// The intensity of the continuous buzz ramps linearly with the fractional part of each wind
    /// (0 at the start of a wind, maximum just before the next integer crossing).
    /// Each time an integer wind boundary is crossed a crisp transient "pop" fires.
    ///
    /// Call ``stopContinuous()`` when dragging ends.
    public func updateWindTension(_ totalWind: Double) {
        guard isEngineReady, let engine else { return }

        let windInt   = Int(totalWind)          // number of completed winds
        let fraction  = totalWind - Double(windInt)   // 0…1 position within current wind

        // Fire a pop when crossing into a new whole-wind boundary
        if windInt != lastWindPop && windInt > 0 {
            lastWindPop = windInt
            playWindPop()
        }

        // Ramp the continuous rumble intensity with the fraction
        // Use a curve so the last 20% of the wind feels noticeably stronger
        let curve = fraction * fraction             // quadratic ramp 0→1
        let buzzIntensity = Float(0.10 + 0.60 * curve)
        let buzzSharpness = Float(0.20 + 0.40 * curve)

        if let player = tensionPlayer {
            // Update the live parameters of the existing player
            do {
                let intensityParam = CHHapticDynamicParameter(
                    parameterID: .hapticIntensityControl,
                    value: buzzIntensity,
                    relativeTime: 0
                )
                let sharpnessParam = CHHapticDynamicParameter(
                    parameterID: .hapticSharpnessControl,
                    value: buzzSharpness,
                    relativeTime: 0
                )
                try player.sendParameters([intensityParam, sharpnessParam], atTime: CHHapticTimeImmediate)
            } catch {
                tensionPlayer = nil   // will recreate below
            }
        }

        if tensionPlayer == nil {
            // Start a new looping continuous player
            do {
                let continuousEvent = CHHapticEvent(
                    eventType: .hapticContinuous,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity,  value: buzzIntensity),
                        CHHapticEventParameter(parameterID: .hapticSharpness,  value: buzzSharpness)
                    ],
                    relativeTime: 0,
                    duration: 100   // long enough; we stop it manually
                )
                let pattern = try CHHapticPattern(events: [continuousEvent], parameters: [])
                let player  = try engine.makeAdvancedPlayer(with: pattern)
                player.loopEnabled = true
                try player.start(atTime: CHHapticTimeImmediate)
                tensionPlayer = player
            } catch { }
        }
    }

    /// Stops the continuous wind-tension haptic. Call this when dragging ends.
    public func stopContinuous() {
        guard let player = tensionPlayer else { return }
        lastWindPop = -1
        do {
            try player.stop(atTime: CHHapticTimeImmediate)
        } catch { }
        tensionPlayer = nil
    }

    // MARK: - Private helpers

    /// Fires a crisp "pop" transient to mark a full-wind crossing.
    private func playWindPop() {
        guard isEngineReady, let engine else { return }
        do {
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.9)
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity,  value: 0.9)
            let event = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [sharpness, intensity],
                relativeTime: 0,
                duration: 0.08
            )
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player  = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch { }
    }
}

#else
import Foundation

/// Stub for platforms that don't support CoreHaptics (e.g. macOS < 10.15, watchOS).
@MainActor
public final class RSliderHapticManager: ObservableObject, Sendable {
    public init() {}
    public func prepare() {}
    public func playLimitHit() {}
    public func playTick(intensity: Float = 0.6) {}
    public func playSnapIn() {}
    public func updateWindTension(_ totalWind: Double) {}
    public func stopContinuous() {}
}
#endif
