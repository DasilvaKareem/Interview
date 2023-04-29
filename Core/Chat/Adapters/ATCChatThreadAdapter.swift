//
//  ATCChatThreadAdapter.swift
//  ChatApp
//
//  Created by Florian Marcu on 8/20/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import Kingfisher
import UIKit

class ATCChatThreadAdapter: ATCGenericCollectionRowAdapter {
    let uiConfig: ATCUIGenericConfigurationProtocol
    let viewer: ATCUser

    init(uiConfig: ATCUIGenericConfigurationProtocol, viewer: ATCUser) {
        self.uiConfig = uiConfig
        self.viewer = viewer
    }

    func configure(cell: UICollectionViewCell, with object: ATCGenericBaseModel) {
        guard let viewModel = object as? ATCChatChannel, let cell = cell as? ATCThreadCollectionViewCell else { return }

        let participants = viewModel.participants
        let imageURLs = self.imageURLs(participants: participants)
        if imageURLs.count < 2 {
            if let url = imageURLs.first {
                cell.singleImageView.kf.setImage(with: URL(string: url))
            } else {
                // placeholder
            }
            cell.singleImageView.contentMode = .scaleAspectFill
            cell.singleImageView.clipsToBounds = true
            cell.singleImageView.layer.cornerRadius = 60.0/2.0
            cell.secondImageView.isHidden = true
            cell.firstImageContainerView.isHidden = true
            cell.singleImageView.isHidden = false
            cell.onlineStatusView.isHidden = false
        } else {
            if let url = imageURLs.first {
                cell.firstImageView.kf.setImage(with: URL(string: url))
            }
            cell.firstImageView.contentMode = .scaleAspectFill
            cell.firstImageView.clipsToBounds = true
            cell.firstImageView.layer.cornerRadius = 40.0/2.0

            cell.secondImageView.contentMode = .scaleAspectFill
            cell.secondImageView.clipsToBounds = true
            cell.secondImageView.layer.cornerRadius = 40.0/2.0
            cell.secondImageView.kf.setImage(with: URL(string: imageURLs[1]))

            cell.firstImageContainerView.layer.cornerRadius = 50.0/2.0
            cell.firstImageContainerView.backgroundColor = uiConfig.mainThemeBackgroundColor

            cell.secondImageView.isHidden = false
            cell.firstImageContainerView.isHidden = false
            cell.singleImageView.isHidden = true
            cell.onlineStatusView.isHidden = true
        }

        let unseenByMe = true
        cell.titleLabel.text = self.title(channel: viewModel)
        cell.titleLabel.font = unseenByMe ? uiConfig.mediumBoldFont : uiConfig.regularMediumFont
        cell.titleLabel.textColor = uiConfig.mainTextColor

        let lastMessage = viewModel.lastMessage.htmlToAttributedString(textColor: UIColor.black)
        let subtitle = NSMutableAttributedString(attributedString: lastMessage)
        subtitle.append(NSAttributedString(string: " \u{00B7} " + TimeFormatHelper.chatString(for: viewModel.lastMessageDate)))
        cell.subtitleLabel.attributedText = subtitle
        cell.subtitleLabel.font = uiConfig.regularSmallFont
        cell.subtitleLabel.textColor = uiConfig.mainSubtextColor

        cell.onlineStatusView.layer.cornerRadius = 15.0/2.0
        cell.onlineStatusView.layer.borderColor = UIColor.white.cgColor
        cell.onlineStatusView.layer.borderWidth = 3
        cell.onlineStatusView.backgroundColor = uiConfig.mainThemeForegroundColor

        cell.avatarContainerView.backgroundColor = uiConfig.mainThemeBackgroundColor
        cell.containerView.backgroundColor = uiConfig.mainThemeBackgroundColor

        cell.setNeedsLayout()
    }

    func cellClass() -> UICollectionViewCell.Type {
        return ATCThreadCollectionViewCell.self
    }

    func size(containerBounds: CGRect, object: ATCGenericBaseModel) -> CGSize {
        guard object is ATCChatChannel else { return .zero }
        return CGSize(width: containerBounds.width, height: 85)
    }

    fileprivate func imageURLs(participants: [ATCUser]) -> [String] {
        var res: [String] = []
        for p in participants {
            if p.uid != viewer.uid, let profilePictureURL = p.profilePictureURL {
                res.append(profilePictureURL)
            }
        }
        res.shuffle()
        return Array(res.prefix(2))
    }

    fileprivate func title(channel: ATCChatChannel) -> String {
        if channel.name.count > 0 {
            return channel.name
        }
        let participants = channel.participants
        var name = ""
        for p in participants {
            if p.uid != viewer.uid {
                let tmp = (participants.count > 2) ? p.firstWordFromName() : p.fullName()
                if name.count == 0 {
                    name += tmp
                } else {
                    name += ", " + tmp
                }
            }
        }
        return name
    }
}
