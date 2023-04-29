//
//  ATCFriendsCollectionView.swift
//  ChatApp
//
//  Created by Osama Naeem on 20/05/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class ATCFriendsCollectionViewController: ATCGenericCollectionViewController {
    
    var viewer: ATCUser? = nil
    let uiConfig: ATCUIGenericConfigurationProtocol
    let db = Firestore.firestore()
    let reportingManager: ATCUserReportingProtocol?
    let chatServiceConfig: ATCChatServiceConfigProtocol
    let socialManager: ATCFirebaseSocialGraphManager

    init(uiConfig: ATCUIGenericConfigurationProtocol, chatServiceConfig: ATCChatServiceConfigProtocol, reportingManager: ATCUserReportingProtocol?) {
        self.uiConfig = uiConfig
        self.reportingManager = reportingManager
        self.chatServiceConfig = chatServiceConfig
        self.socialManager = ATCFirebaseSocialGraphManager()

        let emptyViewModel = CPKEmptyViewModel(image: nil,
                                               title: "No Friends".localizedChat,
                                               description: "Your friends will show up here. Search and add your friends.".localizedChat,
                                               callToAction: nil)
        let collectionVCConfiguration = ATCGenericCollectionViewControllerConfiguration(
            pullToRefreshEnabled: false,
            pullToRefreshTintColor: uiConfig.mainThemeBackgroundColor,
            collectionViewBackgroundColor: uiConfig.mainThemeBackgroundColor,
            collectionViewLayout: ATCLiquidCollectionViewLayout(),
            collectionPagingEnabled: false,
            hideScrollIndicators: false,
            hidesNavigationBar: false,
            headerNibName: nil,
            scrollEnabled: true,
            uiConfig: uiConfig,
            emptyViewModel: emptyViewModel
        )

        super.init(configuration: collectionVCConfiguration)
        let adapter = ATCFriendshipRowAdapter(uiConfig: uiConfig)
        adapter.delegate = self
        self.use(adapter: adapter, for: "ATCChatFriendship")
        self.title = "Contacts".localizedChat

        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateSocialGraph), name: kSocialGraphDidUpdateNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateSocialGraph), name: kUserReportingDidUpdateNotificationName, object: nil)
    }
    
    func friendSelectionBlock(viewer: ATCUser, uiConfig: ATCUIGenericConfigurationProtocol)  -> ATCollectionViewSelectionBlock? {
        return {[weak self] (navController, object, indexPath) in
            guard let `self` = self else { return }
            let uiConfig = ATCChatUIConfiguration(uiConfig: uiConfig)
            if let friendship = object as? ATCChatFriendship {
                let user = friendship.otherUser
                let id1 = (user.uid ?? "")
                let id2 = (viewer.uid ?? "")
                let channelId = id1 < id2 ? id1 + id2 : id2 + id1
                var channel = ATCChatChannel(id: channelId, name: user.fullName())
                channel.participants = [user, viewer]
                var audioVideoChatPresenter: ATCAudioVideoChatPresenter? = nil
                if self.chatServiceConfig.isAudioVideoCallEnabled() {
                    audioVideoChatPresenter = ATCAudioVideoChatPresenter()
                }
                let vc = ATCChatThreadViewController(user: viewer,
                                                     channel: channel,
                                                     uiConfig: uiConfig,
                                                     reportingManager: self.reportingManager,
                                                     chatServiceConfig: self.chatServiceConfig,
                                                     recipients: [user],
                                                     audioVideoChatPresenter: audioVideoChatPresenter)
                navController?.pushViewController(vc, animated: true)
            }
        }
    }

    func update(user: ATCUser) {
        self.viewer = user
        guard let viewer = viewer else { fatalError() }

        self.selectionBlock = self.friendSelectionBlock(viewer: viewer, uiConfig: uiConfig)

        // Now that we have an user, we fetch friendships & users from Firebase
        self.genericDataSource = ATCChatFirebaseFriendshipsDataSource(user: viewer)
        self.genericDataSource?.loadFirst()
    }

    private func sendPushNotification(to user: ATCUser) {
        guard let viewer = viewer else { return }
        let message = "\(viewer.fullName()) " + "accepted your friend request".localizedChat
        
        let notificationSender = ATCPushNotificationSender()
        if let token = user.pushToken, user.uid != viewer.uid {
            notificationSender.sendPushNotification(to: token, title: "iMessenger", body: message)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func didUpdateSocialGraph() {
        self.genericDataSource?.loadFirst()
    }
}

extension ATCFriendsCollectionViewController: ATCFriendshipRowAdapterDelegate {
    func friendshipAdapter(_ adapter: ATCFriendshipRowAdapter, didTakeActionOn friendship: ATCChatFriendship) {
        switch friendship.type {
        case .inbound:
            // Accept friendship
            let hud = CPKProgressHUD.progressHUD(style: .loading(text: nil))
            hud.show(in: view)
            self.socialManager.acceptFriendRequest(viewer: friendship.currentUser,
                                                   from: friendship.otherUser) {[weak self] in
                                                    hud.dismiss()
                                                    guard let self = self else { return }
                                                    self.genericDataSource?.loadFirst()
            }
            sendPushNotification(to: friendship.otherUser)
                break
            case .outbound:
                // Cancel friend request
                let hud = CPKProgressHUD.progressHUD(style: .loading(text: "Loading".localizedCore))
                hud.show(in: view)
                self.socialManager.cancelFriendRequest(viewer: friendship.currentUser,
                                                       to: friendship.otherUser, completion: {
                                                        hud.dismiss()
                                                        self.genericDataSource?.loadFirst()
            })
        default: break
        }
    }
}
