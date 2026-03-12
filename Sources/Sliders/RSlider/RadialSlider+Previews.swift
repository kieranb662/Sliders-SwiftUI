//
//  RadialSlider+Previews.swift
//  Sliders
//

import SwiftUI

// MARK: - Preview Styles

struct CircularArc: Shape {
    var percent: Double
    var animatableData: Double {
        get { percent }
        set { percent = newValue }
    }
    
    var inset: CGFloat = 0.0
    
    func path(in rect: CGRect) -> Path {
        let rect = rect.insetBy(dx: inset, dy: inset)
        
        return Circle()
            .path(in: rect)
            .trimmedPath(from: 0, to: percent)
    }
}

extension CircularArc: InsettableShape {
    func inset(by amount: CGFloat) -> some InsettableShape {
        var arc = self
        arc.inset += amount
        return arc
    }
}


struct DiagnosticRSliderStyle: RSliderStyle {
    let thickness = 24.0
    
    func makeThumb(configuration: RSliderConfiguration) -> some View {
        Circle()
            .foregroundColor(configuration.isActive ? Color.orange : Color.white)
            .frame(width: thickness, height: thickness)
            .offset(x: -thickness / 2 * cos(configuration.angle.radians),
                    y: -thickness / 2 * sin(configuration.angle.radians))
    }
    
    func makeTrack(configuration: RSliderConfiguration) -> some View {
        return ZStack {
            Circle()
                .strokeBorder(Color.gray, style: StrokeStyle(lineWidth: thickness, lineCap: .round))
            
            if configuration.maxWinds > 2 {
                ForEach(0..<Int(configuration.maxWinds), id: \.self) { wind in
                    
                    if wind == Int(configuration.currentWind) {
                        CircularArc(percent: configuration.withinWind)
                            .strokeBorder(
                                Color.orange
                                    .mix(with: Color.black.opacity(0.2), by: Double(wind)/configuration.maxWinds),
                                style: StrokeStyle(lineWidth: thickness, lineCap: .round)
                            )
                            .rotationEffect(configuration.originAngle)
                        
                    } else if wind < Int(configuration.currentWind) {
                        CircularArc(percent: 1)
                            .strokeBorder(
                                Color.orange
                                    .mix(with: Color.black.opacity(0.2), by: Double(wind)/configuration.maxWinds),
                                lineWidth: thickness
                            )
                            .rotationEffect(configuration.originAngle)
                    }
                }
            } else {
                CircularArc(percent: configuration.percent == 1 && configuration.maxWinds >= 1 ? 1.0 : configuration.withinWind)
                    .strokeBorder(Color.orange, style: StrokeStyle(lineWidth: thickness, lineCap: .round))
                    .rotationEffect(configuration.originAngle)
            }

            VStack {
                Text("withinWind: \(Text(configuration.withinWind, format: .number))")
                Text("Current Wind: \(Text(configuration.currentWind, format: .number))")
                Text("Value: \(Text(configuration.value, format: .number))")
            }
            .font(.caption)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - Previews

#Preview("Diagnotistic Style") {
    @Previewable @State var value = 0.5
    VStack(spacing: 16) {
        HStack {
            RSlider($value)
                .radialSliderStyle(DiagnosticRSliderStyle())
            
            RSlider($value, originAngle: .degrees(90))
                .radialSliderStyle(DiagnosticRSliderStyle())
        }
        
        HStack {
            RSlider($value, maxWinds: 3)
                .radialSliderStyle(DiagnosticRSliderStyle())
            
            RSlider($value, maxWinds: 0.25)
                .radialSliderStyle(DiagnosticRSliderStyle())
        }
        
        Text(String(format: "Value: %.2f", value))
            .font(.caption)
    }
    .padding()
}
