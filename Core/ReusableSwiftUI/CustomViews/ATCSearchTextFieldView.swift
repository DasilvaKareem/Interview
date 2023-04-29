//
//  ATCSearchTextFieldView.swift
//  FitnessApp
//
//  Copyright © 2020 iOSAppTemplates. All rights reserved.
//

import SwiftUI

struct ATCSearchTextFieldView: View, AppConfigProtocol {
    var body: some View {
        HStack {
            Image("social-search-icon")
            TextField("Search topic", text: .constant(""))
                .foregroundColor(Color.red)
                .font(.custom(appConfig.regularMediumFont.fontName,
                              size: appConfig.regularMediumFont.pointSize))
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
}
