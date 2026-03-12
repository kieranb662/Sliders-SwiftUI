// Swift toolchain version 6.0
// Running macOS version 26.3
// Created on 3/12/26.
//
// Author: Kieran Brown
//

import Foundation


// MARK: - TickMarkSpacing

/// Describes how tick marks should be spaced along the dragging axis of any single degree of freedom slider.
public enum TickMarkSpacing: Sendable, Equatable {
    /// Place a tick mark every `spacing` units in the slider's value domain.
    case spacing(Double)
    /// Distribute exactly `count` tick marks evenly across the slider's range (including endpoints).
    case count(Int)
    /// Place tick marks at the specified values within the slider's range.
    case values([Double])
}
