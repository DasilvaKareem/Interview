//
//  ATCLineChartIndicatorPoint.swift
//  FitnessApp
//
//  Copyright © 2020 iOSAppTemplates. All rights reserved.
//

import SwiftUI

struct ATCLineChartIndicatorPoint: View, AppConfigProtocol {
    var body: some View {
        ZStack{
            Circle()
                .fill(Color.purple)
            Circle()
                .stroke(Color.white, style: StrokeStyle(lineWidth: 4))
        }
        .frame(width: 14, height: 14)
        .shadow(color: Color(appConfig.shadowColor), radius: 6, x: 0, y: 6)
    }
}

struct IndicatorPoint_Previews: PreviewProvider {
    static var previews: some View {
        ATCLineChartIndicatorPoint()
    }
}
