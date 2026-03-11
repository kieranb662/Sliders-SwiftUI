// Swift toolchain version 6.0
// Running macOS version 26.3
// Created on 3/10/26.
//
// Author: Kieran Brown
//

import SwiftUI

public struct AdaptiveLine: Shape {
    var angle: Angle
    var thickness: Double
    var cap: Cap
    
    var animatableData: Angle {
        get { self.angle }
        set { self.angle = newValue }
    }
    
    public var insetAmount: CGFloat = 0
    
    public enum Cap: Sendable {
        case square
        case round
    }
    
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
    public init(thickness: Double = 40, angle: Angle = .zero, cap: Cap = .round) {
        self.thickness = thickness
        self.angle = angle
        self.cap = cap
    }
    
    public func path(in rect: CGRect) -> Path {
        let rect = rect.insetBy(dx: insetAmount, dy: insetAmount)
        let w = rect.width
        let h = rect.height
        let big: CGFloat = 5000000
        
        let x1 = w/2 + big * CGFloat(cos(angle.radians))
        let y1 = h/2 + big * CGFloat(sin(angle.radians))
        let x2 = w/2 - big * CGFloat(cos(angle.radians))
        let y2 = h/2 - big * CGFloat(sin(angle.radians))
        
        let points = lineRectIntersection(x1, y1, x2, y2, rect.minX, rect.minY, w, h)
        
        guard points.count > 1 else {
            return Path { p in
                p.move(to: CGPoint(x: rect.minX, y: rect.midY))
                p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            }
        }
        
        let (p1, p2) = (points[0], points[1])
        let distance = distance(from: p1, to: p2)
        var rads: Double = angle.radians
        rads.formTruncatingRemainder(dividingBy: .pi / 2)
        
        var p: Path
        
        switch cap {
        case .square:
            let length = distance - thickness * tan(rads)
            p = Rectangle()
                .path(in: CGRect(x: -length/2, y: -thickness/2, width: length, height: thickness))
        case .round:
            // TODO: Come back with correct equation of inset
            let dl: Double = 2 * (1/sqrt(2) - 0.5) * thickness * tan(rads)
            let length: Double = distance - dl
            p = Capsule()
                .path(in: CGRect(x: -length/2, y: -thickness/2, width: length, height: thickness))
        }
        return p
            .applying(.init(rotationAngle: angle.radians))
            .offsetBy(dx: rect.width/2, dy: rect.height/2)
    }
}

extension AdaptiveLine: InsettableShape {
    public func inset(by amount: CGFloat) -> some InsettableShape {
        var shape = self
        shape.insetAmount += amount
        return shape
    }
}

#Preview {
    VStack {
        Color.green
            .border(Color.red)
            .overlay(content: {
                AdaptiveLine(thickness: 40, angle: .degrees(90))
            })
            .overlay(content: {
                AdaptiveLine(thickness: 40, angle: .degrees(90), cap: .square)
                    .stroke(Color.blue)
            })
            .overlay(Circle().foregroundStyle(.blue).frame(width: 10, height: 10))
            .padding(10)
        
        Color.green
            .border(Color.red)
            .overlay(content: {
                AdaptiveLine(thickness: 40, angle: .degrees(45))
            })
            .overlay(content: {
                AdaptiveLine(thickness: 40, angle: .degrees(45), cap: .square)
                    .stroke(Color.blue)
            })
            .overlay(Circle().foregroundStyle(.blue).frame(width: 10, height: 10))
            .padding(10)
        
        Color.green
            .border(Color.red)
            .overlay(content: {
                AdaptiveLine(thickness: 40, angle: .degrees(30))
            })
            .overlay(content: {
                AdaptiveLine(thickness: 40, angle: .degrees(30), cap: .square)
                    .strokeBorder(Color.blue)
            })
            .overlay(Circle().foregroundStyle(.blue).frame(width: 10, height: 10))
            .padding(10)
        
        Color.green
            .border(Color.red)
            .overlay(content: {
                AdaptiveLine(thickness: 40, angle: .degrees(15))
            })
            .overlay(content: {
                AdaptiveLine(thickness: 40, angle: .degrees(15), cap: .square)
                    .stroke(Color.blue)
            })
            .overlay(Circle().foregroundStyle(.blue).frame(width: 10, height: 10))
            .padding(10)
        
        Color.green
            .border(Color.red)
            .overlay(content: {
                AdaptiveLine(thickness: 40, angle: .degrees(0))
            })
            .overlay(content: {
                AdaptiveLine(thickness: 40, angle: .degrees(0), cap: .square)
                    .stroke(Color.blue)
            })
            .overlay(Circle().foregroundStyle(.blue).frame(width: 10, height: 10))
            .padding(10)
    }
}
