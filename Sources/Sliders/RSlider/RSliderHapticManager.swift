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
@Observable
public final class RSliderHapticManager: Sendable {

    private var engine: CHHapticEngine?
    private var isEngineReady = false

    /// The continuous wind-tension player (nil when not playing).
    private var player: CHHapticAdvancedPatternPlayer?
    
    // Current tension: 0.0 (relaxed) → 1.0 (fully wound)
    private var tension: Float = 0.0

    // MARK: - Engine lifecycle

    /// Prepares the haptic engine. Safe to call multiple times.
    public func prepare() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            let newEngine = try CHHapticEngine()
            newEngine.isAutoShutdownEnabled = false
            newEngine.resetHandler = { [weak self] in
                Task { @MainActor in
                    self?.isEngineReady = false
                    self?.prepare()
                }
            }
            newEngine.stoppedHandler = { [weak self] _ in
                Task { @MainActor in
                    self?.isEngineReady = false
                    self?.player = nil
                }
            }
            try newEngine.start()
            engine = newEngine
            isEngineReady = true
        } catch {
            isEngineReady = false
        }
    }
    
    // Call this continuously as the user winds (gestureProgress: 0.0 → 1.0)
    public func updateWindTension(_ gestureProgress: Float) {
        let previousTension = tension
        tension = gestureProgress
        
        // Play a "tick" haptic when crossing tension thresholds
        let tickInterval: Float = 0.1
        let previousTick = floor(previousTension / tickInterval)
        let currentTick = floor(tension / tickInterval)
        
        if currentTick > previousTick {
            playTensionTick(at: tension)
        }
        
        // Play continuous friction buzz while winding
        updateContinuousHaptic(tension: tension)
    }
    
    // Discrete "click" feeling at each wind increment
    private func playTensionTick(at tension: Float) {
        guard let engine else { return }
        
        // Sharpness increases faster than intensity — spring gets "crisper" as it tightens
        let intensity = 0.3 + (tension * 0.7)           // 0.3 → 1.0
        let sharpness = 0.2 + (tension * 0.8)            // 0.2 → 1.0 (leads intensity)
        let attackTime = Double(0.015 - tension * 0.010) // Gets snappier under tension
        
        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness),
                CHHapticEventParameter(parameterID: .attackTime, value: Float(attackTime)),
                CHHapticEventParameter(parameterID: .decayTime, value: 0.05),
                CHHapticEventParameter(parameterID: .sustained, value: 0)
            ],
            relativeTime: 0
        )
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Tick error: \(error)")
        }
    }
    
    // Continuous low hum — represents spring friction/resistance
    private func updateContinuousHaptic(tension: Float) {
        // Use dynamic parameters to update a running player
        guard let _ = engine else { return }
        
        if player == nil {
            startContinuousPlayer()
        }
        
        // Scale friction buzz intensity with tension
        let frictionIntensity = tension * 0.25  // Subtle — ticks are the star
        let frictionSharpness = 0.3 + tension * 0.4
        
        do {
            try player?.sendParameters([
                CHHapticDynamicParameter(
                    parameterID: .hapticIntensityControl,
                    value: frictionIntensity,
                    relativeTime: 0
                ),
                CHHapticDynamicParameter(
                    parameterID: .hapticSharpnessControl,
                    value: frictionSharpness,
                    relativeTime: 0
                )
            ], atTime: CHHapticTimeImmediate)
        } catch {
            print("Dynamic parameter error: \(error)")
        }
    }
    
    private func startContinuousPlayer() {
        guard let engine else { return }
        do {
            let event = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.01),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                ],
                relativeTime: 0,
                duration: 60  // Long duration — we'll stop it manually
            )
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            player = try engine.makeAdvancedPlayer(with: pattern)
            try player?.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Continuous player error: \(error)")
        }
    }
    
    // Call when user releases — spring snaps back
    public func releaseSpring() {
        playReleaseSnap()
        stopContinuous()
        tension = 0.0
    }
    
    private func playReleaseSnap() {
        guard let engine else { return }
        
        // Sharp burst followed by diminishing bounces — spring settling
        var events: [CHHapticEvent] = []
        
        // Initial snap — full tension release
        events.append(CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0),
                CHHapticEventParameter(parameterID: .attackTime, value: 0.001),
            ],
            relativeTime: 0
        ))
        
        // Diminishing bounces — spring oscillating to rest
        let bounceTimes: [Double] = [0.08, 0.18, 0.30, 0.44]
        let bounceIntensities: [Float] = [0.6, 0.35, 0.18, 0.08]
        
        for (time, intensity) in zip(bounceTimes, bounceIntensities) {
            events.append(CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: intensity * 0.8),
                ],
                relativeTime: time
            ))
        }
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let snapPlayer = try engine.makePlayer(with: pattern)
            try snapPlayer.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Release snap error: \(error)")
        }
    }
    
    private func stopContinuous() {
        try? player?.stop(atTime: CHHapticTimeImmediate)
        player = nil
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
}

#else
import Foundation

/// Stub for platforms that don't support CoreHaptics (e.g. macOS < 10.15, watchOS).
@MainActor
@Observable
public final class RSliderHapticManager: Sendable {
    public init() {}
    public func prepare() {}
    public func playLimitHit() {}
    public func playTick(intensity: Float = 0.6) {}
    public func playSnapIn() {}
    public func updateWindTension(_ gestureProgress: Float) {}
    public func releaseSpring() {}
}
#endif
