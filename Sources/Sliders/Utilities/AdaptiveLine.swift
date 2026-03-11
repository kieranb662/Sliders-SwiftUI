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
    var percentFilled: Double
    var cap: Cap
    var adjustmentForThumb: Double
    
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
    public init(
        thickness: Double = 40,
        angle: Angle = .zero,
        percentFilled: Double = 1.0,
        cap: Cap = .round,
        adjustmentForThumb: Double = 0
    ) {
        self.thickness = thickness
        self.angle = angle
        self.percentFilled = percentFilled
        self.cap = cap
        self.adjustmentForThumb = adjustmentForThumb
    }
    
    public func path(in rect: CGRect) -> Path {
        let rect = rect.insetBy(dx: insetAmount, dy: insetAmount)
        let w = rect.width
        let h = rect.height
        let T = thickness
        
        let θ = angle.radians
        let absCos = abs(cos(θ))
        let absSin = abs(sin(θ))
        let epsilon: Double = 1e-10
        
        let p: Path
        
        switch cap {
        case .square:
            let rectMaxFromWidth:  Double = absCos > epsilon ? (w - T * absSin) / absCos : .infinity
            let rectMaxFromHeight: Double = absSin > epsilon ? (h - T * absCos) / absSin : .infinity
            let rectLength = max(0, min(rectMaxFromWidth, rectMaxFromHeight))
            
            let filledWidth = rectLength * percentFilled + adjustmentForThumb

            p = Rectangle()
                .path(in: CGRect(x: -rectLength / 2, y: -T / 2, width: filledWidth, height: T))
        case .round:
            let capsuleMaxFromWidth:  Double = absCos > epsilon ? (w - T) / absCos + T : .infinity
            let capsuleMaxFromHeight: Double = absSin > epsilon ? (h - T) / absSin + T : .infinity
            let capsuleLength = max(0, min(capsuleMaxFromWidth, capsuleMaxFromHeight))
            let width = capsuleLength * percentFilled + adjustmentForThumb
            
            p = RoundedRectangle(cornerRadius: T/2)
                .path(
                    in: CGRect(
                    x: -capsuleLength / 2,
                    y: -T / 2,
                    width: max(width, T),
                    height: T)
                )
        }

        return p
            .applying(.init(rotationAngle: θ))
            .offsetBy(dx: rect.midX, dy: rect.midY)
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
