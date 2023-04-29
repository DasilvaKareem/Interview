//
//  ATCChatGroupMembersTableViewCell.swift
//  designPurpose
//
//  Created by Mac  on 05/02/20.
//  Copyright © 2020 kannan. All rights reserved.
//

import UIKit

protocol ChatGroupMembersCellDelegate: class {
    func moreActionPressed(cell: ATCChatGroupMembersTableViewCell, otherUser: ATCUser)
}

class ATCChatGroupMembersTableViewCell: UITableViewCell {

    @IBOutlet weak var memberImage: UIImageView!
    @IBOutlet weak var memberName: UILabel!
    @IBOutlet weak var memberActionBtn: UIButton!
    @IBOutlet weak var adminLabel: UILabel!
    
    var delegate: ChatGroupMembersCellDelegate?
    var user: ATCUser?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        memberImage.layer.cornerRadius = memberImage.frame.size.width / 2
    }
    
    open func configureCell(user: ATCUser?, isAdmin: Bool) {
        
        self.user = user
        
        if let url = user?.profilePictureURL {
            memberImage.kf.setImage(with: URL(string: url))
        }
        memberName.text = user?.fullName()
        
        if isAdmin {
            memberActionBtn.isHidden = false
            memberActionBtn.addTarget(self, action: #selector(self.moreActionBtnPressed(_:)), for: .touchUpInside)
        } else {
            memberActionBtn.isHidden = true
        }
        
        if let user = self.user {
            adminLabel.isHidden = !user.isAdmin
        }
    }
    
    @objc func moreActionBtnPressed(_ button: UIButton) {
     
        if let user = self.user {
            delegate?.moreActionPressed(cell: self, otherUser: user)
        }
    }
}
