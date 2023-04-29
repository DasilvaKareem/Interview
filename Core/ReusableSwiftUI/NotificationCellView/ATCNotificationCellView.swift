//
//  ATCNotificationCellView.swift
//  FitnessApp
//
//  Copyright © 2020 iOSAppTemplates. All rights reserved.
//

import SwiftUI

struct ATCNotificationCellView: View, AppConfigProtocol {
    
    // MARK: - Private properties
    private let imageIcon: String
    private let notificationContent: String?
    private let actionTime: String
    private let post: FitnessPostProtocol
    private let notificationPayload: FitnessNotificationPayloadProtocol
    
    // MARK: - Initialization
    init(notificationPayload: FitnessNotificationPayloadProtocol) {
        self.notificationPayload = notificationPayload
        self.notificationContent = notificationPayload.interactionType.content
        self.imageIcon = notificationPayload.interactionType.imageIcon
        self.actionTime = notificationPayload.actionTime
        self.post = FitnessMockingData.shared.getPost(from: 1)
    }
    
    var body: some View {
        VStack {
            HStack {
                HStack(alignment: .top, spacing: 16) {
                    ATCAvatarView(image: imageIcon,
                                  squareLength: 40.0)
                    VStack(alignment: .leading, spacing: 8) {
                        ContentNotificationView(interactionType: notificationPayload.interactionType)
                        Text(actionTime).modifier(ATCTextModifier(font: appConfig.regularFont(size: 12), color: .gray))
                        if self.notificationPayload.interactionType.isCommentType {
                            QuickCommentView(postImage: post.image ?? "", contentComment: notificationContent ?? "")
                        }
                    }
                    Spacer()
                }
                if !notificationPayload.readMessage {
                    UnreadIcon()
                }
            }
        }.padding([.top, .bottom], 20)
    }
}
