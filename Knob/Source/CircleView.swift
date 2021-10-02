//
//  CircleView.swift
//  Knob
//
//  Created by Simon on 30/09/2021.
//

import SwiftUI

struct CircleView<S: ShapeStyle>: View {
    let stroke: S
    let lineWidth: CGFloat
    let diameter: CGFloat
    let fillPercentage: CGFloat

    var body: some View {
        Circle()
            .trim(from: 0, to: fillPercentage)
            .stroke(stroke, style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt, lineJoin: .round))
            .rotationEffect(Angle(degrees: -90))
            .frame(width: diameter, height: diameter)
    }
}
