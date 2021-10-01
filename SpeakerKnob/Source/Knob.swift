//
//  Knob.swift
//  SpeakerKnob
//
//  Created by Simon on 30/09/2021.
//

import SwiftUI

struct Knob<FillStyle: ShapeStyle, BackgroundStyle: ShapeStyle>: View {
    let backgroundStyle: BackgroundStyle
    let fillStyle: FillStyle
    let lineWidth: CGFloat
    @Binding var value: Double

    @State private var isRotating = false
    @State private var previousAngle: Angle = .zero

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                CircleView(
                    stroke: backgroundStyle,
                    lineWidth: lineWidth,
                    diameter: geometry.minimumLength,
                    fillPercentage: 1)
                CircleView(
                    stroke: fillStyle,
                    lineWidth: lineWidth,
                    diameter: geometry.minimumLength,
                    fillPercentage: value)
            }.gesture(rotationDragGesture(geometry: geometry))
        }
    }
}

private extension Knob {
    private func rotationDragGesture(geometry: GeometryProxy) -> some Gesture {
        let frame = geometry.frame(in: .local)
        let center = CGPoint(x: frame.midX, y: frame.midY)
        return DragGesture(minimumDistance: 0) .onChanged { dragValue in
            let angle = rotationAngle(of: dragValue.location, around: center)
            let rotatedAngle = rotatedCircleAngle(from: angle)
            if !isRotating {
                isRotating = true
                value = min(max(rotatedAngle.degrees / 360, 0), 1)
                previousAngle = rotatedAngle
            } else {
                let angleDiff = rotatedAngle - previousAngle
                let degreesThreshold: Double = 10
                let isSignificantChange = abs(angleDiff.degrees) > 90
                if isSignificantChange && rotatedAngle < .degrees(degreesThreshold) {
                    value = 1
                } else if isSignificantChange && rotatedAngle > .degrees(360 - degreesThreshold) {
                    value = 0
                } else {
                    value = min(max(rotatedAngle.degrees / 360, 0), 1)
                    previousAngle = rotatedAngle
                }
            }
        }.onEnded { _ in
            isRotating = false
            previousAngle = .zero
        }
    }

    private func rotationAngle(of point: CGPoint, around center: CGPoint) -> Angle {
        let deltaY = point.y - center.y
        let deltaX = point.x - center.x
        return Angle(radians: Double(atan2(deltaY, deltaX)))
    }

    private func rotatedCircleAngle(from angle: Angle) -> Angle {
        if angle >= .degrees(0) {
            return .degrees(90 + 180 * (angle.degrees / 180))
        } else if angle >= .degrees(-90) {
            return .degrees(90 - (90 * (abs(angle.degrees) / 90)))
        } else {
            return .degrees(270 + 90 * (90 - (abs(angle.degrees) - 90)) / 90)
        }
    }
}

private extension GeometryProxy {
    var minimumLength: CGFloat {
        return min(size.width, size.height)
    }
}
