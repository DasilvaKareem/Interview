//
//  FitnessEventCalenderView.swift
//  FitnessApp
//
//  Copyright © 2020 iOSAppTemplates. All rights reserved.
//

import SwiftUI

struct FitnessEventCalenderView: View, AppConfigProtocol {
    let nearbyEvent: FitnessNearbyEventProtocol
    var body: some View {
        VStack(alignment: .center) {
            Text(nearbyEvent.month)
                .modifier(ATCTextModifier(font: appConfig.boldFont(size: 10), color: .white))
                .padding()
                .frame(width: 50, height: 16.7)
                .background(Color(appConfig.mainThemeForegroundColor))
            Text(nearbyEvent.day)
                .modifier(ATCTextModifier(font: appConfig.mediumBoldFont,
                                                color: .black))
                .padding()
                .frame(width: 50, height: 33.3)
                .background(Color(appConfig.mainThemeBackgroundColor))
        }.cornerRadius(3).frame(width: 50,
                                height: 50,
                                alignment: .center)
        
    }
}
