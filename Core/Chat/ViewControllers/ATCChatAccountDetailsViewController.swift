//
//  ATCChatAccountDetailsViewController.swift
//  ChatApp
//
//  Created by Osama Naeem on 28/05/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit
import Eureka

protocol AccountDetailsViewControllerDelegate: class {
    func accountDetailsVCDidUpdateProfile() -> Void
}

class ATCChatAccountDetailsViewController : FormViewController, ATCProfileManagerDelegate {
    
    var user: ATCUser
    var manager: ATCProfileManager?
    let cancelEnabled: Bool
    let hud = CPKProgressHUD.progressHUD(style: .loading(text: "Updating"))
    
    weak var delegate: AccountDetailsViewControllerDelegate?
    
    init(user: ATCUser,
         manager: ATCProfileManager?,
         cancelEnabled: Bool) {
        self.user = user
        self.manager = manager
        self.cancelEnabled = cancelEnabled
        
        super.init(nibName: nil, bundle: nil)
        self.manager?.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDone))
        if (cancelEnabled) {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancel))
        }
        
        didUpdateUser()
        
        self.title = "Edit Profile"
    }

    func profileEditManager(_ manager: ATCProfileManager, didFetch user: ATCUser) {
        // ...
    }
    
    func profileEditManager(_ manager: ATCProfileManager, didUpdateProfile success: Bool) {
        hud.dismiss()
        if (success) {
            delegate?.accountDetailsVCDidUpdateProfile()
            NotificationCenter.default.post(name: kATCLoggedInUserDataDidChangeNotification, object: nil)
            self.navigationController?.popViewController(animated: true)
        } else {
            let alert = UIAlertController(title: "Error",
                                          message: "There was an issue while updating the profile. Please try again.",
                                          preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    private func didUpdateUser() {
        form +++ Eureka.Section("Public Profile")
            <<< TextRow(){ row in
                row.title = "First Name"
                row.placeholder = "Your first name"
                row.value = user.firstName
                row.tag = "firstname"
            }
            <<< TextRow(){ row in
                row.title = "Last Name"
                row.placeholder = "Your last name"
                row.value = user.lastName
                row.tag = "lastname"
            }
            +++ Eureka.Section("Private Details")
            <<< TextRow(){ row in
                row.title = "E-mail Address"
                row.placeholder = "Your e-mail address"
                row.value = user.email
                row.tag = "email"
            }
            <<< TextRow(){ row in
                row.title = "Phone Number"
                row.placeholder = "Your phone number"
                row.value = user.phoneNumber
                row.tag = "phone"
        }
    }
    
    @objc func didTapDone() {

        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.impactOccurred()

        var lastName = ""
        var firstName = ""
        var email = ""
        var phone = ""

        if let row = form.rowBy(tag: "lastname") as? TextRow {
            lastName = row.value ?? ""
        }
        if let row = form.rowBy(tag: "firstname") as? TextRow {
            firstName = row.value ?? ""
        }
        if let row = form.rowBy(tag: "email") as? TextRow {
            email = row.value ?? ""
        }
        if let row = form.rowBy(tag: "phone") as? TextRow {
            phone = row.value ?? ""
        }
        hud.show(in: view)
        self.manager?.update(profile: self.user,
                             email: email,
                             firstName: firstName,
                             lastName: lastName, phone: phone)
        
    }
    
    @objc private func didTapCancel() {
        self.navigationController?.popViewController(animated: true)
    }
}
