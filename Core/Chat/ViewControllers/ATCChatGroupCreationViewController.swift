//
//  ATCChatGroupCreationViewController.swift
//  ChatApp
//
//  Created by Florian Marcu on 9/20/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit

class ATCChatGroupCreationViewController: ATCGenericCollectionViewController {

    fileprivate var selectedFriends: Set<ATCUser> = Set()
    let viewer: ATCUser
    let reportingManager: ATCUserReportingProtocol?
    let uiConfig: ATCUIGenericConfigurationProtocol
    let chatServiceConfig: ATCChatServiceConfigProtocol
    
    init(uiConfig: ATCUIGenericConfigurationProtocol,
         selectionBlock: ATCollectionViewSelectionBlock?,
         viewer: ATCUser,
         chatServiceConfig: ATCChatServiceConfigProtocol,
         reportingManager: ATCUserReportingProtocol?) {

        self.viewer = viewer
        self.uiConfig = uiConfig
        self.reportingManager = reportingManager
        self.chatServiceConfig = chatServiceConfig
        
        let emptyViewModel = CPKEmptyViewModel(image: nil,
                                               title: "No Friends".localizedChat,
                                               description: "Add some friends and then create a group.".localizedChat,
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
            scrollEnabled: false,
            uiConfig: uiConfig,
            emptyViewModel: emptyViewModel
        )

        super.init(configuration: collectionVCConfiguration)
        self.selectionBlock = self.selectionBlock(viewer: viewer)
        self.use(adapter: ATCChatGroupSelectionAdapter(uiConfig: uiConfig), for: "ATCChatUserSelectionViewModel")
        self.genericDataSource = ATCChatFriendsSelectionDataSource(user: viewer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func selectionBlock(viewer: ATCUser) -> ATCollectionViewSelectionBlock? {
        return {[weak self] (navController, object, indexPath) in
            guard let `self` = self else { return }
            if let viewModel = object as? ATCChatUserSelectionViewModel {
                if viewModel.isSelected {
                    self.selectedFriends.remove(viewModel.user)
                    viewModel.isSelected = false
                } else {
                    self.selectedFriends.insert(viewModel.user)
                    viewModel.isSelected = true
                }
                self.collectionView?.reloadItems(at: [indexPath])
                if self.selectedFriends.count > 1 {
                    self.navigationItem.rightBarButtonItem = self.okBarButton
                } else {
                    self.navigationItem.rightBarButtonItem = nil
                }
            }
        }
    }

    @objc func okTapped() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        let hud = CPKProgressHUD.progressHUD(style: .loading(text: "Creating".localizedChat))
        hud.show(in: view)
        ATCChatFirebaseManager.createChannel(creator: viewer, friends: selectedFriends) {[weak self] (channel) in
            guard let `self` = self else { return }
            hud.dismiss()
            guard var channel = channel else {
                self.activityIndicator.stopAnimating()
                self.navigationItem.rightBarButtonItem = self.okBarButton
                return
            }
            let uiConfig = ATCChatUIConfiguration(uiConfig: self.uiConfig)
            if let navController = self.navigationController {
                navController.popViewController(animated: false)
                let groupCreator = self.viewer
                groupCreator.isAdmin = true
                channel.participants = self.selectedFriends + [groupCreator]
                let vc = ATCChatThreadViewController(user: self.viewer,
                                                     channel: channel,
                                                     uiConfig: uiConfig,
                                                     reportingManager: self.reportingManager,
                                                     chatServiceConfig: self.chatServiceConfig,
                                                     recipients: channel.participants)
                navController.pushViewController(vc, animated: false)
            }
        }
    }

    lazy var activityIndicator: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.snp.makeConstraints({ (maker) in
            maker.width.equalTo(40.0)
            maker.height.equalTo(40.0)
        })
        spinner.startAnimating()
        return spinner
    }()
    lazy var okBarButton = UIBarButtonItem(title: "Create Group".localizedChat,
                                           style: .done,
                                           target: self,
                                           action: #selector(okTapped))
}
