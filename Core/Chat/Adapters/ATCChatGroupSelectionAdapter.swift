//
//  ATCChatGroupSelectionAdapter.swift
//  ChatApp
//
//  Created by Florian Marcu on 9/20/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit

class ATCChatGroupSelectionAdapter: ATCGenericCollectionRowAdapter {
    let uiConfig: ATCUIGenericConfigurationProtocol

    init(uiConfig: ATCUIGenericConfigurationProtocol) {
        self.uiConfig = uiConfig
    }

    func configure(cell: UICollectionViewCell, with object: ATCGenericBaseModel) {
        if let viewModel = object as? ATCChatUserSelectionViewModel, let cell = cell as? ATCMessengerUserCollectionViewCell {
            let user = viewModel.user
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

            cell.borderView.backgroundColor = UIColor.darkModeColor(hexString: "#A8c4A3")

            cell.chekedImageView.image = UIImage.localImage("checked-icon")
            cell.chekedImageView.isHidden = !viewModel.isSelected
            
            cell.addButton.isHidden = true
            cell.containerView.backgroundColor = .clear
            cell.avatarContainerView.backgroundColor = .clear
            cell.nameContainerView.backgroundColor = .clear
            cell.setNeedsLayout()
        }
    }

    func cellClass() -> UICollectionViewCell.Type {
        return ATCMessengerUserCollectionViewCell.self
    }

    func size(containerBounds: CGRect, object: ATCGenericBaseModel) -> CGSize {
        guard object is ATCChatUserSelectionViewModel else { return .zero }
        return CGSize(width: containerBounds.width, height: 60)
    }
}
