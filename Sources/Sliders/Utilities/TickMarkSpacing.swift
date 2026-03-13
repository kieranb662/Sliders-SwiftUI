// Swift toolchain version 6.0
// Running macOS version 26.3
// Created on 3/12/26.
//
// Author: Kieran Brown
//

import Foundation

// MARK: - TickMarkSpacing

/// Describes how tick marks should be placed along the single value axis of a slider such as ``LSlider``.
///
/// Sliders resolve this spacing into a concrete, ordered array of tick values within the slider’s
/// `range`.
///
/// - Note: Individual sliders may clamp, sort, or filter tick values to ensure they fall within the
///   slider’s configured range.
public enum TickMarkSpacing: Sendable, Equatable {
    /// Place a tick mark every `spacing` units in the slider's value domain.
    ///
    /// For example, a slider with `range: 0...10` and `.spacing(1)` will produce ticks at
    /// 0, 1, 2, …, 10.
    ///
    /// - Important: Sliders typically require `spacing > 0`. Non-positive values may result in no ticks.
    case spacing(Double)

    /// Distribute exactly `count` tick marks evenly across the slider's range (including endpoints).
    ///
    /// For example, `count: 2` yields ticks at the minimum and maximum.
    ///
    /// - Important: Sliders typically expect `count >= 2`. Some implementations may treat smaller
    ///   counts as a degenerate request and produce a single tick at the minimum.
    case count(Int)

    /// Place tick marks at the specified values within the slider's range.
    ///
    /// Values outside the slider’s range are typically ignored.
    case values([Double])
}
