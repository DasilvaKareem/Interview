//
//  ATCModifiers.swift
//  FitnessApp
//
//  Created by Duy Bui on 1/8/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import SwiftUI

struct ATCTextModifier: ViewModifier {
    let font: UIFont
    let color: UIColor
    
    func body(content: Content) -> some View {
        content
            .fixedSize(horizontal: false, vertical: true)
            .font(.custom(font.fontName, size: font.pointSize))
            .foregroundColor(Color(color))
            .multilineTextAlignment(.center)
            .lineLimit(nil)
    }
}

struct ATCShadowModifier: ViewModifier {
    let color: UIColor
    func body(content: Content) -> some View {
        content
            .shadow(color: Color(color), radius: 5.0, x: 3, y: 3)
    }
}

struct ATCButtonModifier: ViewModifier {
    private let font: UIFont
    private let color: UIColor
    private let textColor: UIColor
    private let width: CGFloat?
    private let height: CGFloat?
    
    init(font: UIFont, color: UIColor, textColor: UIColor = .white, width: CGFloat? = nil, height: CGFloat? = nil) {
        self.font = font
        self.color = color
        self.textColor = textColor
        self.width = width
        self.height = height
    }
    
    func body(content: Content) -> some View {
        content
            .modifier(ATCTextModifier(font: font,
                                      color: textColor))
            .padding()
            .frame(width: width, height: height)
            .background(Color(color))
            .cornerRadius(25.0)
    }
}
