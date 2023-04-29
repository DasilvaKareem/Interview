//
//  ATCDatingChatHomeViewController.swift
//  DatingApp
//
//  Created by Florian Marcu on 1/25/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCDatingChatHomeViewController: ATCGenericCollectionViewController {
    let threadsDataSource: ATCGenericCollectionViewControllerDataSource
    let matchesDataSource: ATCDatingFeedDataSource
    var viewer: ATCUser? = nil
    let uiConfig: ATCUIGenericConfigurationProtocol
    let reportingManager: ATCUserReportingProtocol?
    let chatServiceConfig: ATCChatServiceConfigProtocol
    init(configuration: ATCGenericCollectionViewControllerConfiguration,
         uiConfig: ATCUIGenericConfigurationProtocol,
         selectionBlock: ATCollectionViewSelectionBlock?,
         matchesDataSource: ATCDatingFeedDataSource,
         threadsDataSource: ATCGenericCollectionViewControllerDataSource,
         chatServiceConfig: ATCChatServiceConfigProtocol,
         reportingManager: ATCUserReportingProtocol?) {
        self.chatServiceConfig = chatServiceConfig
        self.threadsDataSource = threadsDataSource
        self.matchesDataSource = matchesDataSource
        self.uiConfig = uiConfig
        self.reportingManager = reportingManager
        super.init(configuration: configuration, selectionBlock: selectionBlock)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView = self.titleView()
    }

    static func homeVC(uiConfig: ATCUIGenericConfigurationProtocol,
                       matchesDataSource: ATCDatingFeedDataSource,
                       threadsDataSource: ATCGenericCollectionViewControllerDataSource,
                       reportingManager: ATCUserReportingProtocol?,
                       chatServiceConfig: ATCChatServiceConfigProtocol) -> ATCDatingChatHomeViewController {
        let collectionVCConfiguration = ATCGenericCollectionViewControllerConfiguration(
            pullToRefreshEnabled: false,
            pullToRefreshTintColor: .white,
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

        let homeVC = ATCDatingChatHomeViewController(configuration: collectionVCConfiguration,
                                                     uiConfig: uiConfig,
                                                     selectionBlock: { (navController, object, indexPath) in

        }, matchesDataSource: matchesDataSource,
           threadsDataSource: threadsDataSource,
           chatServiceConfig: chatServiceConfig,
           reportingManager: reportingManager)
        return homeVC
    }

    func update(user: ATCUser) {
        self.viewer = user
        guard let viewer = viewer else { fatalError() }

        let chatConfig = ATCChatUIConfiguration(uiConfig: uiConfig)
        // Stories tray with matches

        // Configure Stories carousel
        let storiesVC = self.storiesViewController(uiConfig: uiConfig,
                                                   dataSource: matchesDataSource,
                                                   viewer: viewer)
        let storiesCarousel = ATCCarouselViewModel(title: nil,
                                                   viewController: storiesVC,
                                                   cellHeight: 120)
        storiesCarousel.parentViewController = self

        // Configure list of message threads
        let emptyViewModel = CPKEmptyViewModel(image: nil,
                                               title: "No Conversations".localizedChat,
                                               description: "Your conversations will show up here. Match with people and start messaging them.".localizedChat, callToAction: nil)
        let threadsVC = ATCChatThreadsViewController.firebaseThreadsVC(uiConfig: uiConfig,
                                                                       dataSource: threadsDataSource,
                                                                       viewer: viewer,
                                                                       reportingManager: reportingManager,
                                                                       chatConfig: chatConfig,
                                                                       chatServiceConfig: chatServiceConfig,
                                                                       emptyViewModel: emptyViewModel)
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
        self.genericDataSource = ATCGenericLocalHeteroDataSource(items: [storiesCarousel, threadsViewModel])
        self.genericDataSource?.loadFirst()
    }

    func storiesViewController(uiConfig: ATCUIGenericConfigurationProtocol,
                               dataSource: ATCGenericCollectionViewControllerDataSource,
                               viewer: ATCUser) -> ATCGenericCollectionViewController {
        let layout = ATCCollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let emptyViewModel = CPKEmptyViewModel(image: nil,
                                               title: "No Matches".localizedInApp,
                                               description: "Your matches will show up here.".localizedInApp,
                                               callToAction: nil)
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
                                                                            emptyViewModel: emptyViewModel)
        let vc = ATCGenericCollectionViewController(configuration: configuration, selectionBlock: self.storySelectionBlock(viewer: viewer))
        vc.genericDataSource = dataSource
        vc.use(adapter: ATCDatingChatUserStoryAdapter(uiConfig: uiConfig), for: "ATCDatingProfile")
        return vc
    }

    func storySelectionBlock(viewer: ATCUser) -> ATCollectionViewSelectionBlock? {
        return {(navController, object, indexPath) in
            let chatConfig = ATCChatUIConfiguration(uiConfig: self.uiConfig)
            if let user = object as? ATCUser {
                let id1 = (user.uid ?? "")
                let id2 = (viewer.uid ?? "")
                let channelId = id1 < id2 ? id1 + id2 : id2 + id1
                var channel = ATCChatChannel(id: channelId, name: user.fullName())
                channel.participants = [user, viewer]
                let vc = ATCChatThreadViewController(user: viewer,
                                                     channel: channel,
                                                     uiConfig: chatConfig,
                                                     reportingManager: self.reportingManager,
                                                     chatServiceConfig: self.chatServiceConfig,
                                                     recipients: [user])
                navController?.pushViewController(vc, animated: true)
            }
        }
    }

    fileprivate func titleView() -> UIView {
        let titleView = UIImageView(image: UIImage.localImage("chat-filled-icon", template: true))
        titleView.snp.makeConstraints({ (maker) in
            maker.width.equalTo(30.0)
            maker.height.equalTo(30.0)
        })
        titleView.tintColor = uiConfig.mainThemeForegroundColor
        return titleView
    }
}
