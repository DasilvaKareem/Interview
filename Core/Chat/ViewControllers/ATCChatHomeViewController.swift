//
//  ATCChatHomeViewController.swift
//  ChatApp
//
//  Created by Florian Marcu on 8/21/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit

class ATCChatHomeViewController: ATCGenericCollectionViewController, ATCSearchBarAdapterDelegate {
    let userSearchDataSource: ATCGenericSearchViewControllerDataSource
    let threadsDataSource: ATCGenericCollectionViewControllerDataSource
    var viewer: ATCUser? = nil
    let uiGenericConfig: ATCUIGenericConfigurationProtocol
    let reportingManager: ATCUserReportingProtocol?
    let chatServiceConfig: ATCChatServiceConfigProtocol
    let loginManager = ATCFirebaseLoginManager()
    var friendsDataSource: ATCChatFirebaseFriendsDataSource? = nil
    
    init(configuration: ATCGenericCollectionViewControllerConfiguration,
         uiConfig: ATCUIGenericConfigurationProtocol,
         selectionBlock: ATCollectionViewSelectionBlock?,
         threadsDataSource: ATCGenericCollectionViewControllerDataSource,
         userSearchDataSource: ATCGenericSearchViewControllerDataSource,
         chatServiceConfig: ATCChatServiceConfigProtocol,
         reportingManager: ATCUserReportingProtocol?) {
        self.userSearchDataSource = userSearchDataSource
        self.threadsDataSource = threadsDataSource
        self.uiGenericConfig = uiConfig
        self.reportingManager = reportingManager
        self.chatServiceConfig = chatServiceConfig
        super.init(configuration: configuration, selectionBlock: selectionBlock)
        
        self.title = "Chat".localizedChat
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateSocialGraph), name: kSocialGraphDidUpdateNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateSocialGraph), name: kUserReportingDidUpdateNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateProfileInfo),name: kATCLoggedInUserDataDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateFriendsPresence),name: kFriendsPresenceUpdateNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didRequestLogout), name: kLogoutNotificationName, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func homeVC(uiConfig: ATCUIGenericConfigurationProtocol,
                       threadsDataSource: ATCGenericCollectionViewControllerDataSource,
                       userSearchDataSource: ATCGenericSearchViewControllerDataSource,
                       chatServiceConfig: ATCChatServiceConfigProtocol,
                       reportingManager: ATCUserReportingProtocol?) -> ATCChatHomeViewController {
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
            emptyViewModel: nil
        )
        
        let homeVC = ATCChatHomeViewController(configuration: collectionVCConfiguration, uiConfig: uiConfig, selectionBlock: { (navController, object, indexPath) in
            
        }, threadsDataSource: threadsDataSource, userSearchDataSource: userSearchDataSource, chatServiceConfig: chatServiceConfig, reportingManager: reportingManager)
        return homeVC
    }
    
    
    func storiesViewController(uiConfig: ATCUIGenericConfigurationProtocol,
                               dataSource: ATCGenericCollectionViewControllerDataSource,
                               viewer: ATCUser) -> ATCGenericCollectionViewController {
        let layout = ATCCollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        let configuration = ATCGenericCollectionViewControllerConfiguration(pullToRefreshEnabled: false,
                                                                            pullToRefreshTintColor: uiConfig.mainThemeBackgroundColor,
                                                                            collectionViewBackgroundColor: uiConfig.mainThemeBackgroundColor,
                                                                            collectionViewLayout: layout,
                                                                            collectionPagingEnabled: false,
                                                                            hideScrollIndicators: true,
                                                                            hidesNavigationBar: false,
                                                                            headerNibName: nil,
                                                                            scrollEnabled: true,
                                                                            uiConfig: uiConfig,
                                                                            emptyViewModel: nil)
        let vc = ATCGenericCollectionViewController(configuration: configuration,
                                                    selectionBlock: self.storySelectionBlock(viewer: viewer,
                                                                                             uiConfig: uiConfig))
        vc.genericDataSource = dataSource
        vc.use(adapter: ATCChatUserStoryAdapter(uiConfig: uiConfig, loggedInUser: viewer, chatServiceConfig: chatServiceConfig), for: "ATCUser")
        return vc
    }
    
    func storySelectionBlock(viewer: ATCUser, uiConfig: ATCUIGenericConfigurationProtocol) -> ATCollectionViewSelectionBlock? {
        return {[weak self] (navController, object, indexPath) in
            guard let `self` = self else { return }
            let uiConfig = ATCChatUIConfiguration(uiConfig: uiConfig)
            if let user = object as? ATCUser {
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
        
        // Update user search data source
        userSearchDataSource.viewer = viewer
        
        // Configure search bar
        let searchBar = ATCSearchBar(placeholder: "Search for friends".localizedChat)
        let searchAdapter = ATCSearchBarAdapter(uiConfig: uiGenericConfig)
        searchAdapter.delegate = self
        self.use(adapter: searchAdapter, for: "ATCSearchBar")
        
        // Configure Stories carousel
        self.friendsDataSource = ATCChatFirebaseFriendsDataSource(user: viewer,
                                                                  chatServiceConfig: self.chatServiceConfig)
        
        if let friendsDataSource = self.friendsDataSource {
            let storiesVC = self.storiesViewController(uiConfig: uiGenericConfig,
                                                       dataSource: friendsDataSource,
                                                       viewer: viewer)
            let storiesCarousel = ATCCarouselViewModel(title: nil,
                                                       viewController: storiesVC,
                                                       cellHeight: 105)
            storiesCarousel.parentViewController = self
            // Configure list of message threads
            let chatConfig = ATCChatUIConfiguration(uiConfig: uiGenericConfig)
            
            let emptyViewModel = CPKEmptyViewModel(image: nil,
                                                   title: "No Conversations".localizedChat,
                                                   description: "Add friends and start conversations with them. Your conversations will show up here.".localizedChat,
                                                   callToAction: "Add Friends".localizedChat)
            let threadsVC = ATCChatThreadsViewController.firebaseThreadsVC(uiConfig: uiGenericConfig,
                                                                           dataSource: threadsDataSource,
                                                                           viewer: viewer,
                                                                           reportingManager: reportingManager,
                                                                           chatConfig: chatConfig,
                                                                           chatServiceConfig: chatServiceConfig,
                                                                           emptyViewModel: emptyViewModel)
            threadsVC.delegate = self
            
            let threadsViewModel = ATCViewControllerContainerViewModel(viewController: threadsVC,
                                                                       cellHeight: nil,
                                                                       subcellHeight: 85,
                                                                       minTotalHeight: 200)
            threadsViewModel.parentViewController = self
            self.use(adapter: ATCViewControllerContainerRowAdapter(), for: "ATCViewControllerContainerViewModel")
            
            self.registerReuseIdentifiers()
            
            if let threadsDataSource = threadsDataSource as? ATCChatFirebaseChannelDataSource {
                threadsDataSource.user = user
            }
            self.genericDataSource = ATCGenericLocalHeteroDataSource(items: [searchBar, storiesCarousel, threadsViewModel])
            self.genericDataSource?.loadFirst()
        }
    }
    
    // MARK: - ATCSearchBarAdapterDelegate
    func searchAdapterDidFocus(_ adapter: ATCSearchBarAdapter) {
        openSearchScreen()
    }
    
    // MAR: - Private
    @objc
    private func didUpdateSocialGraph() {
        guard let viewer = viewer else { return }
        // This will update the home screen
        self.update(user: viewer)
    }
    
    @objc private func updateFriendsPresence() {
        if let friendsDataSource = self.friendsDataSource {
            friendsDataSource.delegate?.genericCollectionViewControllerDataSource(friendsDataSource, didLoadFirst: friendsDataSource.friends)
        }
    }
    
    @objc private func updateProfileInfo() {
        if let viewer = self.viewer {
            loginManager.resyncPersistentUser(user: viewer) { (newUser) in
                guard let newUser = newUser else { return }
                self.update(user: newUser)
            }
        }
    }
    
    fileprivate func openSearchScreen() {
        guard let viewer = viewer else { return }
        let searchVC = ATCChatUserSearchViewController.searchVC(uiConfig: self.configuration.uiConfig,
                                                                searchDataSource: userSearchDataSource,
                                                                viewer:viewer,
                                                                reportingManager: reportingManager,
                                                                chatServiceConfig: chatServiceConfig)
        let navController = ATCNavigationController(rootViewController: searchVC, topNavigationLeftViews: nil, topNavigationRightViews: nil, topNavigationLeftImage: nil, topNavigationTintColor: nil)
        searchVC.cancelBlock = {() -> Void in
            searchVC.navigationController?.dismiss(animated: true, completion: nil)
        }
        self.present(navController, animated: true, completion: nil)
    }
    
    @objc fileprivate func didRequestLogout() {
        if self.chatServiceConfig.showOnlineStatus || self.chatServiceConfig.showLastSeen {
            self.friendsDataSource?.socialManager?.removeFriendListeners()
        }
    }
}

extension ATCChatHomeViewController: ATCChatThreadsViewControllerDelegate {
    func threadsViewControllerDidTapEmptyStateAction(_ vc: ATCChatThreadsViewController) {
        openSearchScreen()
    }
}

