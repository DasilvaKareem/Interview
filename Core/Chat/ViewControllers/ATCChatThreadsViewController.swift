//
//  ATCChatThreadsViewController.swift
//  ChatApp
//
//  Created by Florian Marcu on 8/20/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit

protocol ATCChatThreadsViewControllerDelegate: class {
    func threadsViewControllerDidTapEmptyStateAction(_ vc: ATCChatThreadsViewController)
}

class ATCChatThreadsViewController: ATCGenericCollectionViewController {

    let chatConfig: ATCChatUIConfiguration
    let chatServiceConfig: ATCChatServiceConfigProtocol
    
    weak var delegate: ATCChatThreadsViewControllerDelegate?

    init(configuration: ATCGenericCollectionViewControllerConfiguration,
         selectionBlock: ATCollectionViewSelectionBlock?,
         viewer: ATCUser,
         chatConfig: ATCChatUIConfiguration,
         chatServiceConfig: ATCChatServiceConfigProtocol) {
        self.chatServiceConfig = chatServiceConfig
        self.chatConfig = chatConfig
        super.init(configuration: configuration, selectionBlock: selectionBlock)
        self.use(adapter: ATCChatThreadAdapter(uiConfig: configuration.uiConfig, viewer: viewer), for: "ATCChatChannel")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func handleEmptyViewCallToAction() {
        delegate?.threadsViewControllerDidTapEmptyStateAction(self)
    }

    static func firebaseThreadsVC(uiConfig: ATCUIGenericConfigurationProtocol,
                                  dataSource: ATCGenericCollectionViewControllerDataSource,
                                  viewer: ATCUser,
                                  reportingManager: ATCUserReportingProtocol?,
                                  chatConfig: ATCChatUIConfiguration,
                                  chatServiceConfig: ATCChatServiceConfigProtocol,
                                  emptyViewModel: CPKEmptyViewModel?) -> ATCChatThreadsViewController {
        let collectionVCConfiguration = ATCGenericCollectionViewControllerConfiguration(
            pullToRefreshEnabled: false,
            pullToRefreshTintColor: uiConfig.mainThemeBackgroundColor,
            collectionViewBackgroundColor: uiConfig.mainThemeBackgroundColor,
            collectionViewLayout: ATCLiquidCollectionViewLayout(),
            collectionPagingEnabled: false,
            hideScrollIndicators: false,
            hidesNavigationBar: false,
            headerNibName: nil,
            scrollEnabled: false,
            uiConfig: uiConfig,
            emptyViewModel: emptyViewModel
        )

        let vc = ATCChatThreadsViewController(configuration: collectionVCConfiguration,
                                              selectionBlock: ATCChatThreadsViewController.selectionBlock(viewer: viewer,
                                                                                                          chatConfig: chatConfig,
                                                                                                          chatServiceConfig: chatServiceConfig,
                                                                                                          reportingManager: reportingManager),
                                              viewer: viewer,
                                              chatConfig: chatConfig,
                                              chatServiceConfig: chatServiceConfig)
        vc.genericDataSource = dataSource
        return vc
    }

    static func selectionBlock(viewer: ATCUser,
                               chatConfig: ATCChatUIConfiguration,
                               chatServiceConfig: ATCChatServiceConfigProtocol,
                               reportingManager: ATCUserReportingProtocol?) -> ATCollectionViewSelectionBlock? {
        return {(navController, object, indexPath) in
            if let channel = object as? ATCChatChannel {
                let vc = ATCChatThreadViewController(user: viewer,
                                                     channel: channel,
                                                     uiConfig: chatConfig,
                                                     reportingManager: reportingManager,
                                                     chatServiceConfig: chatServiceConfig,
                                                     recipients: channel.participants)
                if channel.participants.count == 2 {
                    let otherUser = (viewer.uid == channel.participants.first?.uid) ? channel.participants[1] : channel.participants[0]
                    vc.title = otherUser.fullName()
                }
                navController?.pushViewController(vc, animated: true)
            }
        }
    }
}
