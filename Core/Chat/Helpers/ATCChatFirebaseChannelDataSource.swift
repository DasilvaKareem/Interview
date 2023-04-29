//
//  ATCChatFirebaseChannelDataSource.swift
//  ChatApp
//
//  Created by Florian Marcu on 9/15/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import FirebaseFirestore
import UIKit

class ATCChatFirebaseChannelDataSource: ATCGenericCollectionViewControllerDataSource {
    weak var delegate: ATCGenericCollectionViewControllerDataSourceDelegate?

    var channels: [ATCChatChannel] = []
    var user: ATCUser? = nil
    var participationListener: ListenerRegistration? = nil
    var channelListener: ListenerRegistration? = nil
    var isLoading: Bool = false

    deinit {
        participationListener?.remove()
        channelListener?.remove()
    }

    func object(at index: Int) -> ATCGenericBaseModel? {
        if index < channels.count {
            return channels[index]
        }
        return nil
    }

    func numberOfObjects() -> Int {
        return channels.count
    }

    func loadFirst() {
        participationListener = Firestore.firestore().collection("channel_participation").addSnapshotListener({[weak self] (querySnapshot, error) in
            guard let strongSelf = self else { return }
            guard let snapshot = querySnapshot else {
                print("Error listening for channel participation updates: \(error?.localizedDescription ?? "No error")")
                return
            }

            snapshot.documentChanges.forEach { change in
                let data = change.document.data()
                var channelNeedsUpdate = false
                
                if let channel = data["channel"] as? String {
                    channelNeedsUpdate = strongSelf.channels.filter { $0.id == channel }.count != 0
                }
                if data["user"] as? String == strongSelf.user?.uid || channelNeedsUpdate {
                    strongSelf.loadIfNeeded()
                }
            }
        })

        channelListener = Firestore.firestore().collection("channels").addSnapshotListener({[weak self] (querySnapshot, error) in
            guard let strongSelf = self else { return }
            guard querySnapshot != nil else {
                print("Error listening for channel participation updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            guard (strongSelf.user?.uid) != nil else { return }
            strongSelf.loadIfNeeded()
        })
        loadIfNeeded()
    }

    func loadBottom() {}
    func loadTop() {}

    fileprivate func loadIfNeeded() {
        guard let user = user else {
            self.channels = []
            self.delegate?.genericCollectionViewControllerDataSource(self, didLoadFirst: channels)
            return
        }
        if isLoading == true {
            return
        }
        isLoading = true
        ATCChatFirebaseManager.fetchChannels(user: user) {[weak self] (channels) in
            guard let strongSelf = self else { return }
            strongSelf.channels = channels
            strongSelf.isLoading = false
            strongSelf.delegate?.genericCollectionViewControllerDataSource(strongSelf, didLoadFirst: channels)
        }
    }
}
