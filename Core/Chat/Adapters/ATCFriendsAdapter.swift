//
//  ATCFriendsAdapter.swift
//  ChatApp
//
//  Created by Osama Naeem on 04/06/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCFriendsAdapter: ATCGenericCollectionRowAdapter {
    let uiConfig: ATCUIGenericConfigurationProtocol
    
    init(uiConfig: ATCUIGenericConfigurationProtocol) {
        self.uiConfig = uiConfig
    }
    
    func configure(cell: UICollectionViewCell, with object: ATCGenericBaseModel) {
        if let user = object as? ATCUser, let cell = cell as? ATCMessengerUserCollectionViewCell {
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
            
            cell.borderView.backgroundColor = UIColor(hexString: "#A8c4A3")
            
            cell.chekedImageView.image = UIImage.localImage("checked-icon")
            cell.chekedImageView.isHidden = true
            
            cell.addButton.isHidden = true
            cell.setNeedsLayout()
        }
    }
    
    func cellClass() -> UICollectionViewCell.Type {
        return ATCMessengerUserCollectionViewCell.self
    }
    
    func size(containerBounds: CGRect, object: ATCGenericBaseModel) -> CGSize {
        guard object is ATCUser else { return .zero }
        return CGSize(width: containerBounds.width, height: 60)
    }
}
