//
//  ATCFriendRequestAdapter.swift
//  ChatApp
//
//  Created by Osama Naeem on 04/06/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

protocol ATCFriendshipRowAdapterDelegate: class {
    func friendshipAdapter(_ adapter: ATCFriendshipRowAdapter, didTakeActionOn friendship: ATCChatFriendship)
}

class ATCFriendshipRowAdapter: ATCGenericCollectionRowAdapter {

    let uiConfig: ATCUIGenericConfigurationProtocol
    weak var delegate: ATCFriendshipRowAdapterDelegate?
    
    init(uiConfig: ATCUIGenericConfigurationProtocol) {
        self.uiConfig = uiConfig
    }
    
    func configure(cell: UICollectionViewCell, with object: ATCGenericBaseModel) {
        if let viewModel = object as? ATCChatFriendship, let cell = cell as? ATCMessengerUserCollectionViewCell {
            let user = viewModel.otherUser
            if let url = user.profilePictureURL {
                cell.avatarImageView.kf.setImage(with: URL(string: url))
            } else {
                // placeholder
            }

            cell.avatarImageView.contentMode = .scaleAspectFill
            cell.avatarImageView.clipsToBounds = true
            cell.avatarImageView.layer.cornerRadius = 40/2.0

            cell.nameLabel.text = (user.firstName ?? "") + " " +  (user.lastName ?? "")
            cell.nameLabel.font = uiConfig.boldSmallFont
            cell.nameLabel.textColor = uiConfig.mainTextColor

            cell.borderView.backgroundColor = UIColor.darkModeColor(hexString: "#e6e6e6")

            cell.chekedImageView.image = UIImage.localImage("checked-icon")
            cell.chekedImageView.isHidden = true
            
            cell.addButton.setTitle("Accept".localizedChat, for: .normal)
            cell.addButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            cell.addButton.layer.cornerRadius = 15
            
            cell.delegate = self

            let addButton = cell.addButton
            switch viewModel.type {
            case .inbound:
                addButton?.setTitle("Accept".localizedChat, for: .normal)
                addButton?.isHidden = false
                break
            case .outbound:
                addButton?.setTitle("Cancel".localizedCore, for: .normal)
                addButton?.isHidden = false
                break
            case .mutual:
                addButton?.isHidden = true
                break
            }
            cell.friendship = viewModel
            cell.user = nil
            cell.containerView.backgroundColor = .clear
            cell.nameContainerView.backgroundColor = .clear
            cell.avatarContainerView.backgroundColor = .clear

            cell.setNeedsLayout()
        }
    }
    
    
    func cellClass() -> UICollectionViewCell.Type {
        return ATCMessengerUserCollectionViewCell.self
    }
    
    func size(containerBounds: CGRect, object: ATCGenericBaseModel) -> CGSize {
        guard object is ATCChatFriendship else { return .zero }
        return CGSize(width: containerBounds.width, height: 60)
    }
}

extension ATCFriendshipRowAdapter: ATCMessengerUserCollectionViewCellDelegate {
    func messengerUserCell(_ cell: ATCMessengerUserCollectionViewCell, didTapAddFriendButtonFor user: ATCUser) {}

    func messengerUserCell(_ cell: ATCMessengerUserCollectionViewCell, didTapButtonFor friendship: ATCChatFriendship) {
        delegate?.friendshipAdapter(self, didTakeActionOn: friendship)
    }
}
