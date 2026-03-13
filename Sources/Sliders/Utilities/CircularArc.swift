// Swift toolchain version 6.0
// Running macOS version 26.3
// Created on 3/12/26.
//
// Author: Kieran Brown
//

import SwiftUI

public struct CircularArc: Shape {
    var percent: Double
    public var animatableData: Double {
        get { percent }
        set { percent = newValue }
    }
    
    public init(percent: Double) {
        self.percent = percent
    }
    
    var inset: CGFloat = 0.0
    
    public func path(in rect: CGRect) -> Path {
        let rect = rect.insetBy(dx: inset, dy: inset)
        
        return Circle()
            .path(in: rect)
            .trimmedPath(from: 0, to: percent)
    }
}

extension CircularArc: InsettableShape {
    public func inset(by amount: CGFloat) -> some InsettableShape {
        var arc = self
        arc.inset += amount
        return arc
    }
}
