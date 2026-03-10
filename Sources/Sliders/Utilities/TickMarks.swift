// Swift toolchain version 6.0
// Running macOS version 26.3
// Created on 3/10/26.
//
// Author: Kieran Brown
//

import SwiftUI

public struct TickMarks: Shape {
    public var spacing: CGFloat
    public var ticks: Int
    public var isVertical: Bool
    
    /// Creates `ticks` number of tickmarks of varying sizes each spaced apart with the given `spacing`
    ///
    /// ## Example Usage
    /// ```
    /// struct Ruler: View {
    ///     var length: CGFloat = 500
    ///     var tickSpacing: CGFloat = 10
    ///     var tickColor: Color = Color(white: 0.9)
    ///     var majorTickLength: CGFloat = 30
    ///     var tickBackgroundColor: Color = Color(white: 0.1)
    ///     var nonTickBackgroundColor: Color = Color(white: 0.2)
    ///     var rulerWidth: CGFloat = 80
    ///     var cornerRadius: CGFloat = 5
    ///
    ///     var body: some View {
    ///         HStack(spacing: 0) {
    ///             TickMarks(spacing: tickSpacing,
    ///                       ticks: Int(length/tickSpacing),
    ///                       isVertical: true)
    ///                 .stroke(tickColor)
    ///                 .frame(width: majorTickLength)
    ///                 .padding(.vertical, 6)
    ///                 .padding(.leading, 4)
    ///                 .padding(.trailing, 5)
    ///                 .background(
    ///                     OmniRectangle(topLeft: .round(radius: cornerRadius),
    ///                                   topRight: .square,
    ///                                   bottomLeft: .round(radius: cornerRadius),
    ///                                   bottomRight: .square)
    ///                         .fill(tickBackgroundColor)
    ///                 )
    ///             OmniRectangle(topLeft: .square,
    ///                           topRight: .round(radius: cornerRadius),
    ///                           bottomLeft: .square,
    ///                           bottomRight: .round(radius: cornerRadius))
    ///                 .fill(nonTickBackgroundColor)
    ///                 .frame(width: rulerWidth - majorTickLength)
    ///         }
    ///         .frame(height: length)
    ///         .clipped()
    ///     }
    /// }
    ///```
    public init(spacing: CGFloat, ticks: Int, isVertical: Bool = false) {
        self.spacing = spacing
        self.ticks = ticks
        self.isVertical = isVertical
    }
    
    func determineHeight(_ i: Int) -> CGFloat {
        if i%100 == 0 { return 1    }
        if i%10 == 0  { return 0.75 }
        if i%5 == 0   { return 0.5  }
        return 0.25
    }
    
    private func verticalPath(in rect: CGRect) -> Path {
        Path { path in
            for i in 0...ticks {
                path.move(to: CGPoint(x: 0, y: CGFloat(i)*spacing))
                path.addLine(to: CGPoint(x: rect.width*self.determineHeight(i), y: CGFloat(i)*spacing))
            }
        }
    }
    
    private func horizontalPath(in rect: CGRect) -> Path {
        Path { path in
            for i in 0...ticks {
                path.move(to: CGPoint(x: CGFloat(i)*spacing, y: 0))
                path.addLine(to: CGPoint(x: CGFloat(i)*spacing, y: rect.height*self.determineHeight(i)))
            }
        }
    }
    
    public func path(in rect: CGRect) -> Path {
        isVertical ? verticalPath(in: rect) : horizontalPath(in: rect)
    }
}






