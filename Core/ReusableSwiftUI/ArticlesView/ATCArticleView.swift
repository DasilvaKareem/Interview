//
//  ATCArticleView.swift
//  FitnessApp
//
//  Copyright © 2020 iOSAppTemplates. All rights reserved.
//

import SwiftUI

struct ATCArticleView: View, AppConfigProtocol {
    let fitnessArticle: FitnessArticleProtocol
    var body: some View {
        VStack {
            Image(fitnessArticle.image)
                .resizable()
                .frame(height: 117, alignment: .center)
            VStack(alignment: .leading, spacing: 20) {
                Text(fitnessArticle.title)
                    .multilineTextAlignment(.leading)
                    .modifier(ATCTextModifier(font: appConfig.boldLargeFont,
                                              color: .black))
                ATCAuthorView(fitnessArticle: fitnessArticle)
            }.padding()
        }
        .background(Color.white)
        .cornerRadius(15)
    }
}
