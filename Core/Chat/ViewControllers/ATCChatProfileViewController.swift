//
//  ATCChatProfileViewController.swift
//  ChatApp
//
//  Created by Osama Naeem on 22/05/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCChatProfileViewController: ATCProfileViewController, AccountDetailsViewControllerDelegate {

    let loginManager: ATCFirebaseLoginManager

    init(uiConfig: ATCUIGenericConfigurationProtocol,
         profileManager: ATCProfileManager?) {
        self.loginManager = ATCFirebaseLoginManager()

        super.init(items: ATCChatProfileViewController.selfProfileItems(),
                   uiConfig: uiConfig)
      
        self.selectionBlock = {[weak self] (nav, model, index) in
            guard let `self` = self else { return }
            if let _ = model as? ATCProfileButtonItem {
                // Logout
                NotificationCenter.default.post(name: kLogoutNotificationName, object: nil)
            } else if let item = model as? ATCProfileItem {
                if item.title == "Settings".localizedChat {
                    let settingsVC = ATCSettingsViewController()
                    settingsVC.user = self.user
                    nav?.pushViewController(settingsVC, animated: true)
                } else if item.title == "Account Details".localizedChat {
                    if let user = self.user {
                        let editAccountVC = ATCChatAccountDetailsViewController(user: user, manager: profileManager, cancelEnabled: true)
                        editAccountVC.delegate = self
                        nav?.pushViewController(editAccountVC, animated: true)
                        }
                } else {
                    let contactVC = ATCChatContactViewController()
                    nav?.pushViewController(contactVC, animated: true)
                    }
                }
            }
        self.title = "Profile".localizedChat
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func accountDetailsVCDidUpdateProfile() {
        // Gets the new persistent user with updated profile and updates the view controller
        if let user = self.user {
            loginManager.resyncPersistentUser(user: user) { (newUser) in
                guard let newUser = newUser else { return }
                self.user = newUser
            }
        }
    }
    
    fileprivate static func selfProfileItems() -> [ATCGenericBaseModel] {
        var items: [ATCGenericBaseModel] = []
        // Add the remaining items, such as Account Details, Settings and Contact Us
        items.append(contentsOf: [ATCProfileItem(icon: UIImage.localImage("account-male-icon", template: true),
                                                 title: "Account Details".localizedChat,
                                                 type: .arrow,
                                                 color: UIColor(hexString: "#6979F8")),
                                  ATCProfileItem(icon: UIImage.localImage("settings-menu-item", template: true),
                                                 title: "Settings".localizedChat,
                                                 type: .arrow,
                                                 color: UIColor(hexString: "#3F3356")),
                                  ATCProfileItem(icon: UIImage.localImage("contact-call-icon", template: true),
                                                 title: "Contact Us".localizedChat,
                                                 type: .arrow,
                                                 color: UIColor(hexString: "#64E790"))
            ]);
        return items
    }    
}
