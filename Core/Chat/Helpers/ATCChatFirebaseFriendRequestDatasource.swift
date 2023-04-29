//
//  ATCChatFirebaseFriendRequestDatasource.swift
//  ChatApp
//
//  Created by Osama Naeem on 04/06/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//


import UIKit

class ATCChatFirebaseFriendshipsDataSource: ATCGenericCollectionViewControllerDataSource {
    weak var delegate: ATCGenericCollectionViewControllerDataSourceDelegate?

    let socialManager: ATCSocialGraphManagerProtocol?
    var friendships: [ATCChatFriendship] = []
    var user: ATCUser
    
    init(user: ATCUser) {
        self.user = user
        self.socialManager = ATCFirebaseSocialGraphManager()
    }

    func object(at index: Int) -> ATCGenericBaseModel? {
        if index < friendships.count {
            return friendships[index]
        }
        return nil
    }

    func numberOfObjects() -> Int {
        return friendships.count
    }

    func loadFirst() {
        self.socialManager?.fetchFriendships(viewer: user) { (friendships) in
            self.friendships = friendships
            self.delegate?.genericCollectionViewControllerDataSource(self, didLoadFirst: friendships)
        }
    }

    func loadBottom() {}
    func loadTop() {}
}
