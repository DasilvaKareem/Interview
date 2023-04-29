//
//  ATCCurvedShape.swift
//  FitnessApp
//
//  Copyright © 2020 iOSAppTemplates. All rights reserved.
//

import SwiftUI

struct ATCCurvedShape : View {
    var body : some View{
        Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: UIScreen.main.bounds.width, y: 0))
            path.addLine(to: CGPoint(x: UIScreen.main.bounds.width, y: 55))
            path.addArc(center: CGPoint(x: UIScreen.main.bounds.width / 2, y: 55), radius: 40, startAngle: .zero, endAngle: .init(degrees: 180), clockwise: true)
            path.addLine(to: CGPoint(x: 0, y: 55))
        }
        .fill(Color.white)
        .edgesIgnoringSafeArea(.bottom)
        .rotationEffect(.init(degrees: 180))
    }
}
