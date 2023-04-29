//
//  ATCArticlesView.swift
//  FitnessApp
//
//  Copyright © 2020 iOSAppTemplates. All rights reserved.
//

import SwiftUI

struct ATCArticlesView: View, AppConfigProtocol {
    let fitnessArticles: [FitnessArticle]
    var body: some View {
        ScrollView(.horizontal, content: {
            HStack(spacing: 15) {
                ForEach(fitnessArticles, id: \.articleId) { article in
                    ATCArticleView(fitnessArticle: article)
                        .frame(width: 316, height: 256, alignment: .center)
                }
            }
        }).background(Color(appConfig.mainThemeBackgroundColor))
    }
}
