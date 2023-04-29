//
//  ATCChatUserStoryAdapter.swift
//  ChatApp
//
//  Created by Florian Marcu on 8/21/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit
import Firebase

class ATCChatUserStoryAdapter: ATCGenericCollectionRowAdapter {
    let uiConfig: ATCUIGenericConfigurationProtocol
    let chatServiceConfig: ATCChatServiceConfigProtocol
    let loggedInUser: ATCUser?
    init(uiConfig: ATCUIGenericConfigurationProtocol,
         loggedInUser: ATCUser,
         chatServiceConfig: ATCChatServiceConfigProtocol) {
        self.uiConfig = uiConfig
        self.loggedInUser = loggedInUser
        self.chatServiceConfig = chatServiceConfig
    }

    func configure(cell: UICollectionViewCell, with object: ATCGenericBaseModel) {
        guard let viewModel = object as? ATCUser else {
            return
        }
        guard let cell = cell as? ATCUserStoryCollectionViewCell else {
            return
            
        }
        guard let loggedInUser = loggedInUser else { return }
        guard let loggedInUserUID = loggedInUser.uid else { return }
        guard let viewModelUID = viewModel.uid else { return }
        
        if let url = viewModel.profilePictureURL {
            cell.storyImageView.kf.setImage(with: URL(string: url))
        } else {
            // placeholder
        }
        
        cell.storyImageView.contentMode = .scaleAspectFill
        cell.storyImageView.clipsToBounds = true
        cell.storyImageView.layer.cornerRadius = 50.0/2.0

        cell.imageContainerView.layer.cornerRadius = 60.0/2.0
//        cell.whiteBorderView.layer.cornerRadius = 55.0/2.0

        
        if loggedInUserUID == viewModelUID {
            cell.storyTitleLabel.text = "Your Story".localizedChat
            cell.storyTitleLabel.font = uiConfig.regularFont(size: 11)
            cell.storyTitleLabel.textColor = uiConfig.mainSubtextColor
        }else {
            cell.storyTitleLabel.text = viewModel.firstWordFromName()
            cell.storyTitleLabel.font = uiConfig.regularFont(size: 13)
            cell.storyTitleLabel.textColor = uiConfig.mainSubtextColor
        }

        let showOnlineStatus = chatServiceConfig.showOnlineStatus ? viewModel.showOnlineStatus() : false

        cell.onlineStatusView.isHidden = !showOnlineStatus
        cell.onlineStatusView.layer.cornerRadius = 15.0/2.0
        cell.onlineStatusView.layer.borderColor = UIColor.white.cgColor
        cell.onlineStatusView.layer.borderWidth = 3
        cell.onlineStatusView.backgroundColor = UIColor(hexString: "#4acd1d")
        cell.backgroundColor = .clear
        cell.containerView.backgroundColor = .clear

        cell.whiteBorderView.backgroundColor = uiConfig.mainThemeBackgroundColor
        cell.whiteBorderView.layer.cornerRadius = 50.0/2.0

        cell.setNeedsLayout()
    }

    func cellClass() -> UICollectionViewCell.Type {
        return ATCUserStoryCollectionViewCell.self
    }

    func size(containerBounds: CGRect, object: ATCGenericBaseModel) -> CGSize {
        guard object is ATCUser else { return .zero }
        return CGSize(width: 75, height: 90)
    }
}
