//
//  ATCFeedBasicInfoView.swift
//  FitnessApp
//
//  Copyright © 2020 iOSAppTemplates. All rights reserved.
//

import SwiftUI

struct ATCFeedBasicInfoView: View, AppConfigProtocol {
    let statusContent: String?
    let hashtagContent: String?
    let image: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                if statusContent != nil {
                    Text(statusContent!).modifier(ATCTextModifier(font: appConfig.regularMediumFont, color: .black))
                }
                if hashtagContent != nil {
                Text(hashtagContent!).modifier(ATCTextModifier(font: appConfig.regularMediumFont, color: appConfig.mainThemeForegroundColor))
                }
            }
            if image != nil {
            Image(image!)
                .resizable()
                .frame(height: 193.0)
                .cornerRadius(10)
            }
        }
    }
}
