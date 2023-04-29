//
//  ATCChatFriendship.swift
//  ChatApp
//
//  Created by Florian Marcu on 6/5/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

enum ATCFriendshipType {
    case mutual
    case inbound
    case outbound
}

class ATCChatFriendship: ATCGenericBaseModel {

    var currentUser: ATCUser
    var otherUser: ATCUser
    var type: ATCFriendshipType

    var description: String {
        return currentUser.description + otherUser.description + String(type.hashValue)
    }

    init(currentUser: ATCUser, otherUser: ATCUser, type: ATCFriendshipType) {
        self.currentUser = currentUser
        self.otherUser = otherUser
        self.type = type
    }

    required public init(jsonDict: [String: Any]) {
        fatalError()
    }

}
