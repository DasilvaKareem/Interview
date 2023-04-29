//
//  ATCAuthorView.swift
//  FitnessApp
//
//  Copyright © 2020 iOSAppTemplates. All rights reserved.
//

import SwiftUI

struct ATCAuthorView: View, AppConfigProtocol {
    let fitnessArticle: FitnessArticleProtocol
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(fitnessArticle.author)
                    .modifier(ATCTextModifier(font: appConfig.regularMediumFont,
                                              color: .black))
                Text("\(fitnessArticle.category.content) - \(fitnessArticle.time)")
                    .modifier(ATCTextModifier(font: appConfig.regularSmallFont,
                                              color: .gray))
            }
            Spacer()
            Image("fitness-heart-gray")
        }
    }
}
