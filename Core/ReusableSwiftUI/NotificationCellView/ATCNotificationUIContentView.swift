//
//  NotificationUIContentView.swift
//  FitnessApp
//
//  Copyright © 2020 iOSAppTemplates. All rights reserved.
//

// This file is used for decorating the content of notification content. For example, if someone comments, it will have the content of the comment, the user's name will be bold, so on.
import SwiftUI

// This struct is used for like and comment type
struct NotificationInformView: View, AppConfigProtocol {
    let userName: String?
    let informingContent: String
    var body: some View {
        HStack {
            Text(userName ?? "")
                .font(.custom(appConfig.mediumBoldFont.fontName,
                              size: appConfig.mediumBoldFont.pointSize))
                + Text(" " + informingContent)
                    .font(.custom(appConfig.regularMediumFont.fontName,
                                  size: appConfig.mediumBoldFont.pointSize))
        }
    }
}

// This struct is used for system notification type
struct NotificationSystemView: View, AppConfigProtocol {
    let content: String
    var body: some View {
        Text(content)
            .font(.custom(appConfig.regularMediumFont.fontName,
                          size: appConfig.mediumBoldFont.pointSize))
    }
}

// This struct includes views with all notification types
struct ContentNotificationView: View, AppConfigProtocol {
    let interactionType: InteractionType
    var body: some View {
        VStack {
            containedView
        }
    }
    
    private var containedView: AnyView {
        switch interactionType {
        case .like(let viewer):
            return AnyView(NotificationInformView(userName: viewer.userName,
                                                  informingContent: "liked your recent post"))
        case .comment(let viewer, _):
            return AnyView(NotificationInformView(userName: viewer.userName,
                                                  informingContent: "left a comment under your post"))
        case .systemNotification(let content):
            return AnyView(NotificationSystemView(content: content))
        }
    }
}
