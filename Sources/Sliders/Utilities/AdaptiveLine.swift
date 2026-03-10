// Swift toolchain version 6.0
// Running macOS version 26.3
// Created on 3/10/26.
//
// Author: Kieran Brown
//

import SwiftUI

struct AdaptiveLine: Shape {
     var angle: Angle
    
     var animatableData: Angle {
        get { self.angle }
        set { self.angle = newValue }
    }
    
    var insetAmount: CGFloat = 0

    /// # Adaptive Line
    ///
    /// This shape creates a line centered inside of and constrained by its bounding box.
    /// The end points of the line are the points of intersection of an infinitely long angled line and the container rectangle
    /// - Parameters:
    ///     - angle: The angle of the adaptive line with `.zero` pointing in the positive X direction
    ///
    /// ## Example Usage
    ///
    /// ```
    ///    struct AdaptiveLineExample: View {
    ///        @State var angle: Double = 0.5
    ///
    ///        var body: some View {
    ///            ZStack {
    ///                Color(white: 0.1).edgesIgnoringSafeArea(.all)
    ///                VStack {
    ///                    AdaptiveLine(angle: Angle(degrees: angle*360))
    ///                        .stroke(Color.white,
    ///                                style: StrokeStyle(lineWidth: 30, lineCap: .round))
    ///                    Slider(value: $angle)
    ///                }
    ///                .padding()
    ///            }
    ///        }
    ///    }
    /// ```
     init(angle: Angle = .zero) {
        self.angle = angle
    }

     func path(in rect: CGRect) -> Path {
        let rect = rect.insetBy(dx: insetAmount, dy: insetAmount)
        let w = rect.width
        let h = rect.height
        let big: CGFloat = 5000000

        let x1 = w/2 + big*CGFloat(cos(self.angle.radians))
        let y1 = h/2 + big*CGFloat(sin(self.angle.radians))
        let x2 = w/2 - big*CGFloat(cos(self.angle.radians))
        let y2 = h/2 - big*CGFloat(sin(self.angle.radians))

        let points = lineRectIntersection(x1, y1, x2, y2, rect.minX, rect.minY, w, h)
         
        if points.count < 2 {
            return Path { p in
                p.move(to: CGPoint(x: rect.minX, y: rect.midY))
                p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            }
        }

        return Path { p in
            p.move(to: points[0])
            p.addLine(to: points[1])
        }
    }
}

extension AdaptiveLine: InsettableShape {
     func inset(by amount: CGFloat) -> some InsettableShape {
        var shape = self
        shape.insetAmount += amount
        return shape
    }
}
