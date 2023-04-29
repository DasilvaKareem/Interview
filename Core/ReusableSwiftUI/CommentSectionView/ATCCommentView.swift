//
//  ATCCommentView.swift
//  FitnessApp
//
//  Copyright © 2020 iOSAppTemplates. All rights reserved.
//

import SwiftUI

struct ATCCommentView<Content>: AppConfigProtocol, View where Content: View {
    private let comment: FitnessCommentProtocol
    private let user: FitnessUserProtocol
    private let content: Content
    
    init(comment: FitnessCommentProtocol, @ViewBuilder content: () -> Content) {
        self.user = FitnessMockingData.shared.getUser(from: comment.userCommentId)
        self.comment = comment
        self.content = content()
    }
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                ATCFeedHeaderInfoView(image: user.imageIcon,
                                      squareLength: 40.0,
                                      username: user.userName,
                                      trackingTime: comment.commentTime) { content }
                Text(comment.content)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                    .modifier(ATCTextModifier(font: appConfig.regularFont(size: 13), color: .black))
                    .padding(.leading, 60.0)
            }
        }
    }
}
