//
//  ATCNotificationExtraUIView.swift
//  FitnessApp
//
//  Copyright © 2020 iOSAppTemplates. All rights reserved.
//

import SwiftUI

struct UnreadIcon: View, AppConfigProtocol {
    var body: some View {
        Circle()
            .fill(Color(appConfig.mainSubtextColor))
            .frame(width: 10.0, height: 10.0)
    }
}

struct QuickCommentView: View, AppConfigProtocol {
    let postImage: String?
    let contentComment: String
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if postImage != nil {
                Image(postImage!)
                .resizable()
                .frame(width: 64.0, height: 64.0)
                .cornerRadius(6)
            }
            Text(contentComment)
                .multilineTextAlignment(.leading)
                .modifier(ATCTextModifier(font: appConfig.regularFont(size: 13), color: .gray))
        }
    }
}
