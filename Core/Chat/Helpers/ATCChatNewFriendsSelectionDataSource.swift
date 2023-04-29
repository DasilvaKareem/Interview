//
//  ATCChatNewFriendsSelectionDataSource.swift
//  ChatApp
//
//  Created by Florian Marcu on 9/20/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit

class ATCChatNewFriendsSelectionDataSource: ATCGenericCollectionViewControllerDataSource {
    weak var delegate: ATCGenericCollectionViewControllerDataSourceDelegate?
    let socialManager: ATCSocialGraphManagerProtocol?
    
    var friends: [ATCChatUserSelectionViewModel] = []
    var user: ATCUser
    var oldFriends: [ATCUser]
    
    init(user: ATCUser, oldFriends: [ATCUser]) {
        self.user = user
        self.oldFriends = oldFriends
        self.socialManager = ATCFirebaseSocialGraphManager()
    }
    
    func object(at index: Int) -> ATCGenericBaseModel? {
        if index < friends.count {
            return friends[index]
        }
        return nil
    }
    
    func numberOfObjects() -> Int {
        return friends.count
    }
    
    func loadFirst() {
        loadIfNeeded()
    }
    
    func loadBottom() {}
    func loadTop() {}
    
    fileprivate func loadIfNeeded() {
        self.socialManager?.fetchFriends(viewer: user) { (friends) in
            let allFriends = friends.map({ATCChatUserSelectionViewModel(user: $0, selected: false)})
            var newFriends: [ATCChatUserSelectionViewModel] = []
            for friend in allFriends {
                if (self.oldFriends.filter{ $0.uid == friend.user.uid }.isEmpty) {
                    newFriends.append(friend)
                }
            }
            self.friends = newFriends
            self.delegate?.genericCollectionViewControllerDataSource(self, didLoadFirst: friends)
        }
    }
}
