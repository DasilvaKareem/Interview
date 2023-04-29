//
//  MagnifierRect.swift
//  FitnessApp
//
//  Copyright © 2020 iOSAppTemplates. All rights reserved.
//

import SwiftUI

public struct ATCMagnifierRectView: View, AppConfigProtocol {
    @Binding var currentNumber: Double
    var valueSpecifier:String
    public var body: some View {
        ZStack{
            Text("\(self.currentNumber, specifier: valueSpecifier)")
                .font(.system(size: 18, weight: .bold))
                .offset(x: 0, y: -110)
                .foregroundColor(Color.black)
            RoundedRectangle(cornerRadius: 16)
            .frame(width: 60, height: 280)
            .foregroundColor(Color.white)
            .shadow(color: Color(appConfig.shadowColor), radius: 12, x: 0, y: 6 )
            .blendMode(.multiply)
        }
    }
}
