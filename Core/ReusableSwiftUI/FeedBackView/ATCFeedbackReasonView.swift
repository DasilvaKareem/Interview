//
//  ATCFeedbackReasonView.swift
//  FitnessApp
//
//  Copyright © 2020 iOSAppTemplates. All rights reserved.
//

import SwiftUI

struct ATCFeedbackReasonView: View, AppConfigProtocol {
    
    let title: String
    // make it into @binding when applying data
    @State private var isChosen: Bool = false
    
    var body: some View {
        VStack {
            Button(action: {
                self.isChosen.toggle()
            }) {
                if isChosen {
                    Text(title).modifier(ATCButtonModifier(font: appConfig.mediumBoldFont,
                                                         color: appConfig.hairlineColor,
                                                         textColor: appConfig.mainThemeForegroundColor,
                                                         height: 50))
                } else {
                    Text(title)
                        .modifier(ATCButtonModifier(font: appConfig.regularSmallFont,
                                                    color: UIColor(hexString: "#efeff4"),
                                                    textColor: .black,
                                                    height: 50))
                }
            }.buttonStyle(PlainButtonStyle())
        }
    }
}
