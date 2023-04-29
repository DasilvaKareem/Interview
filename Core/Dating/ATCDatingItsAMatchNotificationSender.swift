//
//  ATCDatingItsAMatchNotificationSender.swift
//  DatingApp
//
//  Created by Florian Marcu on 1/27/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCDatingItsAMatchNotificationSender {
    func sendNotificationIfPossible(user: ATCUser, recipient: ATCUser) {
        let sender = ATCPushNotificationSender()
        if let token = recipient.pushToken {
            sender.sendPushNotification(to: token, title: "Instaswipey", body: "You've just got a new match. Send them a message.")
        }
    }
}
