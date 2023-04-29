//
//  ATCChatGroupUpdateViewController.swift
//  ChatApp
//
//  Created by Florian Marcu on 9/20/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit

let kATCAddedGroupMemberNotification = Notification.Name("kATCAddedGroupMemberNotification")

class ATCChatGroupUpdateViewController: ATCGenericCollectionViewController {

    fileprivate var selectedFriends: Set<ATCUser> = Set()
    let viewer: ATCUser
    let reportingManager: ATCUserReportingProtocol?
    let uiConfig: ATCUIGenericConfigurationProtocol
    let chatServiceConfig: ATCChatServiceConfigProtocol
    var channel: ATCChatChannel
    var recipients: [ATCUser]

    init(uiConfig: ATCUIGenericConfigurationProtocol,
         selectionBlock: ATCollectionViewSelectionBlock?,
         viewer: ATCUser,
         chatServiceConfig: ATCChatServiceConfigProtocol,
         reportingManager: ATCUserReportingProtocol?,
         channel: ATCChatChannel,
         recipients: [ATCUser]) {

        self.viewer = viewer
        self.uiConfig = uiConfig
        self.reportingManager = reportingManager
        self.chatServiceConfig = chatServiceConfig
        self.channel = channel
        self.recipients = recipients
        
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
        self.genericDataSource = ATCChatNewFriendsSelectionDataSource(user: viewer, oldFriends: self.recipients)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func selectionBlock(viewer: ATCUser) -> ATCollectionViewSelectionBlock? {
        return {[weak self] (navController, object, indexPath) in
            guard let `self` = self else { return }
            if let viewModel = object as? ATCChatUserSelectionViewModel {
                let friend = viewModel.user
                friend.isAdmin = false
                if viewModel.isSelected {
                    self.selectedFriends.remove(friend)
                    viewModel.isSelected = false
                } else {
                    self.selectedFriends.insert(friend)
                    viewModel.isSelected = true
                }
                self.collectionView?.reloadItems(at: [indexPath])
                if self.selectedFriends.count > 0 {
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
        ATCChatFirebaseManager.addNewMembersToChannel(creator: viewer, channel: self.channel, friends: selectedFriends) {[weak self] (friends) in
            guard let `self` = self else { return }
            hud.dismiss()
            
            self.recipients.append(contentsOf: friends)
            NotificationCenter.default.post(name: kATCAddedGroupMemberNotification, object: nil, userInfo: ["recipients": self.recipients])
            self.navigationController?.popViewController(animated: true)
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
    lazy var okBarButton = UIBarButtonItem(title: "Update Group".localizedChat,
                                           style: .done,
                                           target: self,
                                           action: #selector(okTapped))
}
