//
//  ATCSubFooterView.swift
//  FitnessApp
//
//  Created by Duy Bui on 1/10/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import SwiftUI

struct ATCSubFooterView: View {
    private let subText: String?
    private let buttonText: String?
    private let appConfig: ATCUIGenericConfigurationProtocol
    
    public init(subText: String?,
                buttonText: String?,
                appConfig: ATCUIGenericConfigurationProtocol) {
        self.subText = subText
        self.buttonText = buttonText
        self.appConfig = appConfig
    }
    
    var body: some View {
        HStack {
            subText.map {
                Text($0)
                    .modifier(ATCTextModifier(font: appConfig.regularMediumFont,
                                              color: appConfig.colorGray3))
            }
            buttonText.map { text in
                Button(action: {
                    // Action here
                }) {
                    Text(text)
                        .modifier(ATCTextModifier(font: appConfig.regularMediumFont,
                                                  color: appConfig.mainThemeForegroundColor))
                }
            }
        }
    }
}
