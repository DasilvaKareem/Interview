//
//  ATCFeedbackNoteView.swift
//  FitnessApp
//
//  Copyright © 2020 iOSAppTemplates. All rights reserved.
//

import SwiftUI

struct ATCFeedbackNoteView: View, AppConfigProtocol {
    @State var name: String = ""
    var body: some View {
        VStack(alignment: .leading) {
            Text("Notes")
                .modifier(ATCTextModifier(font: appConfig.mediumBoldFont,
                                      color: .black))
            ZStack(alignment: .top) {
                Rectangle()
                    .fill(Color(UIColor(hexString: "#efeff4")))
                    .frame(height: 105)
                    .cornerRadius(10)
                TextField("How can we do better?", text: $name)
                    .font(.custom(appConfig.regularMediumFont.fontName,
                                  size: appConfig.regularMediumFont.pointSize))
                    .foregroundColor(Color(appConfig.hairlineColor))
                    .padding()
            }
        }
    }
}
