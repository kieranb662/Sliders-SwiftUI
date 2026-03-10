// Swift toolchain version 6.0
// Running macOS version 26.3
// Created on 3/10/26.
//
// Author: Kieran Brown
//

import SwiftUI
import simd

public func lineLineIntersection(_ x1: CGFloat, _ y1: CGFloat, _ x2: CGFloat, _ y2: CGFloat, _ x3: CGFloat, _ y3: CGFloat, _ x4: CGFloat, _ y4: CGFloat) -> (Bool, CGPoint) {
    // calculate the direction of the lines
    let uA = ((x4-x3)*(y1-y3) - (y4-y3)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));
    let uB = ((x2-x1)*(y1-y3) - (y2-y1)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));
    // if uA and uB are between 0-1, lines are colliding
    if (uA >= 0 && uA <= 1 && uB >= 0 && uB <= 1) {
        // optionally, draw a circle where the lines meet
        let intersectionX = x1 + (uA * (x2-x1));
        let intersectionY = y1 + (uA * (y2-y1));
        
        return (true , CGPoint(x: intersectionX, y: intersectionY))
    }
    return (false, .zero)
}

public func lineRectIntersection(_ x1: CGFloat, _ y1: CGFloat, _ x2: CGFloat, _ y2: CGFloat, _ rx: CGFloat, _ ry: CGFloat, _ rw: CGFloat, _ rh: CGFloat) -> [CGPoint] {
    var points = [CGPoint]()
    // check if the line has hit any of the rectangle's sides
    // uses the Line/Line function below
    let left =   lineLineIntersection(x1,y1,x2,y2, rx,ry,rx, ry+rh);
    let right =  lineLineIntersection(x1,y1,x2,y2, rx+rw,ry, rx+rw,ry+rh);
    let top =    lineLineIntersection(x1,y1,x2,y2, rx,ry, rx+rw,ry);
    let bottom = lineLineIntersection(x1,y1,x2,y2, rx,ry+rh, rx+rw,ry+rh);
    
    if left.0 {points.append(left.1)}
    if right.0 {points.append(right.1)}
    if top.0 {points.append(top.1)}
    if bottom.0 {points.append(bottom.1)}
    
    return points
}

/// Projects the point `p` onto the line segment defined by the points `L1` and `L2`
public func project(_ L1: CGPoint, _ L2: CGPoint, _ p: CGPoint) -> CGPoint {
    let onTo = L1-L2
    let vector = L1 - p
    let top = onTo.x*vector.x + onTo.y*vector.y
    let scalar = top/CGFloat(onTo.magnitudeSquared)
    return CGPoint(x: scalar*onTo.x, y: scalar*onTo.y)
}

/// Projects the first vector onto the second vector
public func project(_ vector: CGSize, _ onto: CGSize) -> CGSize {
    let top = onto.width*vector.width + onto.height*vector.height
    let scalar = top/CGFloat(onto.magnitudeSquared)
    return CGSize(width: scalar*onto.width, height: scalar*onto.height)
}

/// Projects the point `p` onto the vector defined by the points `L1` and `L2`,  uses the parametric
///  form of the line segment from `L1` to `L2` to constrain the projected point to be on the line segment
public func calculateParameter(_ L1: CGPoint, _ L2: CGPoint, _ p: CGPoint) -> CGFloat {
    let temp = project(L1, L2, p)
    
    if L1.x == L2.x && L1.y != L2.y {
        return max(min((temp.y)/(L1.y - L2.y), 1), 0)
    } else if L1.x != L2.x  {
        return max(min((temp.x)/(L1.x - L2.x), 1), 0)
    } else {
        return  0
    }
}

// MARK: - CGPoint VectorArithmetic Conformance

extension CGPoint: VectorArithmetic {
    public static func -= (lhs: inout CGPoint, rhs: CGPoint) {
        lhs.x -= rhs.x
        lhs.y -= rhs.y
    }
    
    public static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    public static func += (lhs: inout CGPoint, rhs: CGPoint) {
        lhs.x += rhs.x
        lhs.y += rhs.y
    }
    
    public mutating func scale(by rhs: Double) {
        x *= CGFloat(rhs)
        y *= CGFloat(rhs)
    }
    
    public var magnitudeSquared: Double {
        Double(x*x+y*y)
    }
    
    public static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
}

// MARK: - CGSize VectorArithmetic Conformance

extension CGSize: VectorArithmetic {
    public static func -= (lhs: inout CGSize, rhs: CGSize) {
        lhs.width -= rhs.width
        lhs.height -= rhs.height
    }
    
    public static func + (lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width+rhs.width,
               height: lhs.height+rhs.height)
    }
    
    public static func - (lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width-rhs.width,
               height: lhs.height-rhs.height)
    }
    
    public mutating func scale(by rhs: Double) {
        width *= CGFloat(rhs)
        height *= CGFloat(rhs)
    }
    
    public var magnitudeSquared: Double {
        Double(width*width+height*height)
    }
    
    public static func += (lhs: inout CGSize, rhs: CGSize) {
        lhs.width += rhs.width
        lhs.height += rhs.height
    }
    
}

// MARK: Clamping

extension FloatingPoint {
    public func clamped(to range: ClosedRange<Self>) -> Self {
        return max(min(self, range.upperBound), range.lowerBound)
    }
}

extension BinaryInteger {
    public func clamped(to range: ClosedRange<Self>) -> Self {
        return max(min(self, range.upperBound), range.lowerBound)
    }
}

/// Returns only positive values between [0, 2π]
public func atanP(x: Double, y: Double) -> Double {
    if x>0 && y>=0 {
        return atan(y/x)
        
    } else if x>0 && y<0 {
        return 2*Double.pi + atan(y/x)
        
    } else if x<0 && y>=0 {
        return .pi + atan(y/x)
        
    } else if x<0 && y<0 {
        return .pi + atan(y/x)
        
    } else if x==0 && y>=0 {
        return .pi/2
        
    } else if x==0 && y<0 {
        return 3/2*Double.pi
        
    } else {
        return 0
    }
    
}

/// Returns only positive values between [0, 2π]
public func atanP(x: CGFloat, y: CGFloat) -> CGFloat {
    CGFloat(atanP(x: Double(x), y: Double(y)))
}

/// Calculated the direction between two points relative to the vector pointing in the trailing direction
public func calculateDirection(_ pt1: CGPoint, _ pt2: CGPoint) -> Double {
    let a = pt2.x - pt1.x
    let b = pt2.y - pt1.y
    
    return Double(atanP(x: a, y: b)/(2 * .pi))
}

// MARK: - CGSize Convienience

extension CGSize {
    func toPoint() -> CGPoint {
        CGPoint(x: width, y: height)
    }
}

/// Iterates through all path elements and samples interpolated points on that segment (1 + numberOfDivisions) times
/// using the parametric representation of the specific Bézier curve.
/// - parameters:
///  - path: The path to be sampled
///  - capacity: The maximum number of sampled points (**Default**: 500)
///
public func generateLookupTable(path: Path, capacity: Int = 500) -> [CGPoint] {
    let elements = path.elements
    let lookupTableCapacity = capacity
    var lookupTable = [CGPoint]()
    let threshold: Double = 1
    
    let count = elements.count
    guard count > 0 else { return [] }
    var lastPoint: CGPoint = .zero
    var startingPoint: CGPoint = .zero
    let totalLength = quickLengths(path: path).reduce(0, +)
    guard totalLength > 0 else {return []}
    for element in elements {
        switch element {
            
        case .move(let to):
            lookupTable.append(to)
            startingPoint = to
            lastPoint = to
            
        case .line(let to):
            let numOfDivisions = Double(lookupTableCapacity)*segmentLength(lastPoint: lastPoint, element: element)/totalLength
            let divisions = 0...Int(numOfDivisions)
            
            divisions.forEach { (i) in
                
                let nextPossible = linearInterpolation(t: Float(i)/Float(numOfDivisions), start: lastPoint, end: to)
                if sqrt((nextPossible - lookupTable.last!).magnitudeSquared) > threshold {
                    lookupTable.append(nextPossible)
                }
            }
            lastPoint = to
            
        case .quadCurve(let to, let control):
            let numOfDivisions = Double(lookupTableCapacity)*segmentLength(lastPoint: lastPoint, element: element)/totalLength
            let divisions = 0...Int(numOfDivisions)
            
            divisions.forEach { (i) in
                let nextPossible = quadraticBezierInterpolation(t: Float(i)/Float(numOfDivisions), start: lastPoint, control: control, end: to)
                if sqrt((nextPossible - lookupTable.last!).magnitudeSquared) > threshold {
                    lookupTable.append(nextPossible)
                }
            }
            lastPoint = to
            
        case .curve(let to, let control1, let control2):
            let numOfDivisions = Double(lookupTableCapacity)*segmentLength(lastPoint: lastPoint, element: element)/totalLength
            let divisions = 0...Int(numOfDivisions)
            divisions.forEach { (i) in
                let nextPossible = cubicBezierInterpolation(t: Float(i)/Float(numOfDivisions), start: lastPoint, control1: control1, control2: control2, end: to)
                if sqrt((nextPossible - lookupTable.last!).magnitudeSquared) > threshold {
                    lookupTable.append(nextPossible)
                }
            }
            lastPoint = to
            
        case .closeSubpath:
            let length: Double = sqrt((lastPoint-startingPoint).magnitudeSquared)
            let numOfDivisions = Double(lookupTableCapacity)*length/totalLength
            let divisions = 0...Int(numOfDivisions)
            divisions.forEach { (i) in
                let nextPossible = linearInterpolation(t: Float(i)/Float(numOfDivisions), start: lastPoint, end: startingPoint)
                if sqrt((nextPossible - lookupTable.last!).magnitudeSquared) > threshold {
                    lookupTable.append(nextPossible)
                }
            }
            
        }
    }
    return lookupTable
}

/// Returns the approximate closest point on the path from the given point
public func getClosestPoint(_ from: CGPoint, lookupTable: [CGPoint]) -> CGPoint {
    let minimum = {
        (0..<lookupTable.count).map {
            (distance: distance_squared(simd_double2(x: Double(from.x), y:Double(from.y)), simd_double2(x: Double(lookupTable[$0].x), y: Double(lookupTable[$0].y))), index: $0)
        }.min {
            $0.distance < $1.distance
        }
    }()
    
    return lookupTable[minimum!.index]
}

/// Returns the percent based location in the lookup table
public func getPercent(_ from: CGPoint, lookupTable: [CGPoint]) -> CGFloat {
    let minimum = {
        (0..<lookupTable.count).map {
            (distance: distance_squared(simd_double2(x: Double(from.x), y:Double(from.y)), simd_double2(x: Double(lookupTable[$0].x), y: Double(lookupTable[$0].y))), index: $0)
        }.min {
            $0.distance < $1.distance
        }
    }()
    guard lookupTable.count >= 2 && minimum != nil else {return 0}
    
    return CGFloat(minimum!.index)/CGFloat(lookupTable.count-1)
}

extension CGPoint {
    func tosimd() -> simd_float2 {
        simd_float2(Float(x), Float(y))
    }
}

/// # Linear Interpolation
///
/// Calculates and returns the point at the value `t` on the line defined by the start and end points
///
/// - parameters:
///     - t: parametric variable of some value on [0,1]
///     - start: The starting location of the line
///     - end: The ending location of the line
public func linearInterpolation(t: Float, start: CGPoint, end: CGPoint) -> CGPoint {
    let p0 = start.tosimd()
    let p1 = end.tosimd()
    let point = mix(p0, p1, t: t)
    return CGPoint(x: CGFloat(point.x), y: CGFloat(point.y))
}

/// # Quadratic Bézier Interpolation
///
/// Calculates and returns  the point at the value `t` on the quadratic Bézier curve
/// `B(t) = (1-t)²P₀ + 2t(1-t)P₁ + t²P₂ `
/// `           =    a     +     b     +   c `
///
/// - parameters:
///     - t: parametric variable of some value on [0,1]
///     - start: The starting location of the curve
///     - control: The control point of the curve
///     - endPoint: The ending location of the curve
public func quadraticBezierInterpolation(t: Float, start: CGPoint, control: CGPoint , end: CGPoint) -> CGPoint {
    let p0 = start.tosimd()
    let p1 = control.tosimd()
    let p2 = end.tosimd()

    // Splitting up the expression for the quadratic Bézier curve to keep in a human readable form
    let a = (1-t)*(1-t)*p0
    let b = 2*(1-t)*t*p1
    let c = t*t*p2
    
    let point = a + b + c
    
    return CGPoint(x: CGFloat(point.x), y: CGFloat(point.y))
}

/// # Cubic Bézier Interpolation
///
/// Calculates and returns the point at the value `t` on the cubic Bézier curve.
///  `B(t) = (1-t)³P₀ + 3t(1-t)²P₁ + 3t²(1-t)P₂ + t³P₃`
///  `           =    a     +     b      +     c      +  d`
///
/// - parameters:
///     - t: parametric variable of some value on [0,1]
///     - start: The starting location of the curve
///     - control1: The first control point of the curve
///     - control2: The second control point of the curve
///     - endPoint: The ending location of the curve
public func cubicBezierInterpolation(t: Float, start: CGPoint, control1: CGPoint, control2: CGPoint , end: CGPoint) -> CGPoint {
    
    let p0 = start.tosimd()
    let p1 = control1.tosimd()
    let p2 = control2.tosimd()
    let p3 = end.tosimd()
    
    // Splitting up the expression for the cubic Bézier curve to keep in a human readable form
    let a = powf((1-t), 3)*p0
    let b = 3*(1-t)*(1-t)*t*p1
    let c = 3*(1-t)*t*t*p2
    let d = powf(t, 3)*p3
    
    let point = a + b + c + d
    
    return CGPoint(x: CGFloat(point.x), y: CGFloat(point.y))
}

public func segmentLength(lastPoint: CGPoint, element: Path.Element) -> Double {
    switch element {
        
    case .move(_):
        return 0
    case .line(let to):
        return sqrt((to - lastPoint).magnitudeSquared)
    case .quadCurve(let to, let control):
        var tempTotal: Double = 0
        var tempLast: CGPoint = lastPoint
        for i in 1...20 {
            let new = quadraticBezierInterpolation(t: Float(i)/Float(20), start: lastPoint, control: control, end: to)
            tempTotal += sqrt((new-tempLast).magnitudeSquared)
            tempLast = new
        }
        return tempTotal
    case .curve(let to, let control1, let control2):
        var tempTotal: Double = 0
        var tempLast: CGPoint = lastPoint
        for i in 1...20 {
            let new = cubicBezierInterpolation(t: Float(i)/Float(20), start: lastPoint, control1: control1, control2: control2, end: to)
            tempTotal += sqrt((new-tempLast).magnitudeSquared)
            tempLast = new
        }
        return tempTotal
    case .closeSubpath:
        return 0
    }
}

/// Calculates the length of a `Path` using linear interpolation for speed.
public func quickLengths(path: Path) -> [Double] {
    let elements = path.elements
    var lastPoint: CGPoint = .zero
    var startingPoint: CGPoint = .zero
    var segmentLengths: [Double] = []
    for element in elements {
        switch element {
            
        case .move(let to):
            startingPoint = to
            lastPoint = to
        case .line(let to):
            segmentLengths.append(sqrt((to - lastPoint).magnitudeSquared))
            lastPoint = to
        case .quadCurve(let to, let control):
            var tempTotal: Double = 0
            var tempLast: CGPoint = lastPoint
            for i in 1...20 {
                let new = quadraticBezierInterpolation(t: Float(i)/Float(20), start: lastPoint, control: control, end: to)
                tempTotal += sqrt((new-tempLast).magnitudeSquared)
                tempLast = new
            }
            segmentLengths.append(tempTotal)
            lastPoint = to
            
        case .curve(let to, let control1, let control2):
            var tempTotal: Double = 0
            var tempLast: CGPoint = lastPoint
            for i in 1...20 {
                let new = cubicBezierInterpolation(t: Float(i)/Float(20), start: lastPoint, control1: control1, control2: control2, end: to)
                tempTotal += sqrt((new-tempLast).magnitudeSquared)
                tempLast = new
            }
            segmentLengths.append(tempTotal)
            lastPoint = to
        case .closeSubpath:
            segmentLengths.append(sqrt((lastPoint - startingPoint).magnitudeSquared))
            lastPoint = startingPoint
        }
    }
    return segmentLengths
}
