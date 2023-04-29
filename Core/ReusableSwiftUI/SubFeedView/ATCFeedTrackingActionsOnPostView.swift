//
//  ATCFeedTrackingActionsOnPostView.swift
//  FitnessApp
//
//  Copyright © 2020 iOSAppTemplates. All rights reserved.
//

import SwiftUI

struct ATCFeedTrackingActionOnPostView: View, AppConfigProtocol {
    let number: String
    let image: String
    
    var body: some View {
        HStack {
            Image(image)
            Text(number).modifier(ATCTextModifier(font: appConfig.regularSmallFont, color: .gray))
        }
    }
}

struct ATCFeedTrackingActionsOnPostView: View, AppConfigProtocol {
    let numberOfLikes: String
    let numberOfComments: String
    
    var body: some View {
        HStack(spacing: 20) {
            ATCFeedTrackingActionOnPostView(number: numberOfLikes, image: "fitness-heart-gray")
            ATCFeedTrackingActionOnPostView(number: numberOfComments, image: "fitness-comment-light")
        }
    }
}
