//
//  ATCCommentsView.swift
//  FitnessApp
//
//  Copyright © 2020 iOSAppTemplates. All rights reserved.
//

import SwiftUI

struct ATCCommentsView: View, AppConfigProtocol {
    private let title: String
    private let comments: [FitnessCommentProtocol]
    private let isNeedRating: Bool
    
    init(title: String, comments: [FitnessCommentProtocol], isNeedRating: Bool = false) {
        self.title = title
        self.comments = comments
        self.isNeedRating = isNeedRating
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                .modifier(ATCTextModifier(font: appConfig.boldFont(size: 20), color: .black))
                Spacer()
                if isNeedRating {
                    Image("fitness-rating-star").padding(.trailing)
                }
            }
            VStack {
                ForEach(comments, id: \.commentId) { comment in
                    ATCCommentView(comment: comment){
                        Text("3.5")
                            .modifier(ATCTextModifier(font: self.appConfig.regularMediumFont,
                                                      color: self.appConfig.hairlineColor))
                            .padding()
                            .frame(width: 55, height: 29)
                            .background(Color(self.appConfig.mainThemeForegroundColor))
                            .cornerRadius(15)
                    }.padding([.top, .bottom, .trailing])
                }
            }
        }.padding()
    }
}
