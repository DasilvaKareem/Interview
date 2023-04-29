//
//  ATCChatSearchViewController.swift
//  ChatApp
//
//  Created by Florian Marcu on 8/21/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit
import Firebase

class ATCChatUserSearchViewController: ATCGenericSearchViewController<ATCUser> {
    
    var searchResultsViewController: ATCChatUserSearchViewController? = nil
    var viewer: ATCUser? = nil
    var userSearchDataSource: ATCGenericSearchViewControllerDataSource? = nil
    var uiConfig: ATCUIGenericConfigurationProtocol? = nil
    var socialGraphManager: ATCFirebaseSocialGraphManager? = nil
    var chatServiceConfig: ATCChatServiceConfigProtocol? = nil
    
    static func searchVC(uiConfig: ATCUIGenericConfigurationProtocol,
                         searchDataSource: ATCGenericSearchViewControllerDataSource,
                         viewer: ATCUser,
                         reportingManager: ATCUserReportingProtocol?,
                         chatServiceConfig: ATCChatServiceConfigProtocol) -> ATCChatUserSearchViewController {
        let vc = ATCChatUserSearchViewController(configuration: ATCGenericSearchViewControllerConfiguration(searchBarPlaceholderText: "Search for friends".localizedChat,
                                                                                                            uiConfig: uiConfig,
                                                                                                            cellPadding: 0))
        vc.searchResultsViewController = vc
        vc.viewer = viewer
        vc.userSearchDataSource = searchDataSource
        vc.uiConfig = uiConfig
        vc.chatServiceConfig = chatServiceConfig
        vc.socialGraphManager = ATCFirebaseSocialGraphManager()

        vc.searchResultsController.selectionBlock = { (navController, object, indexPath) in
            if let user = object as? ATCUser {
                let uiConfig = ATCChatUIConfiguration(uiConfig: uiConfig)
                let id1 = (user.uid ?? "")
                let id2 = (viewer.uid ?? "")
                let channelId = id1 < id2 ? id1 + id2 : id2 + id1
                var channel = ATCChatChannel(id: channelId, name: user.fullName())
                channel.participants = [user, viewer]
                var audioVideoChatPresenter: ATCAudioVideoChatPresenter? = nil
                if chatServiceConfig.isAudioVideoCallEnabled() {
                    audioVideoChatPresenter = ATCAudioVideoChatPresenter()
                }
                let threadsVC = ATCChatThreadViewController(user: viewer,
                                                            channel: channel,
                                                            uiConfig: uiConfig,
                                                            reportingManager: reportingManager,
                                                            chatServiceConfig: chatServiceConfig,
                                                            recipients: [user],
                                                            audioVideoChatPresenter: audioVideoChatPresenter)
                vc.navigationController?.pushViewController(threadsVC, animated: true)
            }
        }
        return vc
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchFriends()
    }

    func fetchFriends() {
        guard let viewer = viewer else { return }
        ATCFirebaseSocialGraphManager().fetchFriends(viewer: viewer) {[weak self] (fetchedFriends) in
            guard let `self` = self, let uiConfig = self.uiConfig else { return }
            let adapter = ATCMessengerUserAdapter(uiConfig: uiConfig, friends: fetchedFriends)
            adapter.delegate = self
            self.use(adapter: adapter, for: "ATCUser")
            self.searchResultsController.registerReuseIdentifiers()
            self.searchDataSource = self.userSearchDataSource
        }
    }

    private func sendPushNotification(to user2: ATCUser?) {
        guard let user2 = user2 else { return }
        guard let viewer = viewer else { return }
        let message = "\(viewer.fullName()) " + "sent you a friend request".localizedChat

        let notificationSender = ATCPushNotificationSender()
        if let token = user2.pushToken, user2.uid != viewer.uid {
            notificationSender.sendPushNotification(to: token, title: "iMessenger", body: message)
        }
    }
}

extension ATCChatUserSearchViewController : ATCMessengerUserAdapterDelegate {
    func userAdapter(_ userAdapter: ATCMessengerUserAdapter, didTapAddUser user: ATCUser) {
        guard let viewer = viewer else { fatalError() }
        let hud = CPKProgressHUD.progressHUD(style: .loading(text: "Adding".localizedChat))
        hud.show(in: self.searchResultsController.view)
        socialGraphManager?.sendFriendRequest(viewer: viewer, to: user) {[weak self] in
            guard let `self` = self else { return }
            self.userSearchDataSource?.update {[weak self] in
                hud.dismiss()
                guard let `self` = self else { return }
                self.updateSearchResults(for: self.searchController)
                self.sendPushNotification(to: user)
            }
        }
    }
}
