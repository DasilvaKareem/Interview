//
//  ATCFeedFullInfoView.swift
//  FitnessApp
//
//  Copyright © 2020 iOSAppTemplates. All rights reserved.
//

import SwiftUI

struct ATCFeedFullInfoView: View, AppConfigProtocol {
    let post: FitnessPostProtocol
    private let user: FitnessUserProtocol
    init(post: FitnessPostProtocol) {
        self.post = post
        user = FitnessMockingData.shared.getUser(from: post.postId)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            ATCFeedHeaderInfoView(image: user.imageIcon,
                                  squareLength: 65,
                                  username: user.userName,
                                  trackingTime: post.postTime) { EmptyView() }
            
            ATCFeedBasicInfoView(statusContent: post.content,
                                     hashtagContent: post.hashtag ?? "",
                                     image: post.image ?? "")
            ATCFeedTrackingActionsOnPostView(numberOfLikes: post.numberOfLikes ?? "0",
                                            numberOfComments: post.numberOfComments ?? "0")
        }
    }
}
