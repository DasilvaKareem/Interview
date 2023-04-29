//
//  ATCFeedHeaderInfoView.swift
//  FitnessApp
//
//  Copyright © 2020 iOSAppTemplates. All rights reserved.
//

import SwiftUI

struct ATCFeedHeaderInfoView<Content>: AppConfigProtocol, View where Content: View {
    private let image: String
    private let username: String
    private let trackingTime: String?
    private let squareLength: CGFloat
    private let content: Content
    init(image: String,
         squareLength: CGFloat,
         username: String,
         trackingTime: String? = nil,
         @ViewBuilder content: () -> Content) {
        self.image = image
        self.username = username
        self.squareLength = squareLength
        self.trackingTime = trackingTime
        self.content = content()
    }
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ATCAvatarView(image: image, squareLength: squareLength)
            VStack(alignment: .leading, spacing: 2) {
                Text(username).modifier(ATCTextModifier(font: appConfig.mediumBoldFont,
                                                        color: .black))
                if self.trackingTime != nil {
                    Text(trackingTime!).modifier(ATCTextModifier(font: appConfig.regularSmallFont,
                                                                 color: .gray))
                }
            }
            Spacer()
            content
        }
    }
}
