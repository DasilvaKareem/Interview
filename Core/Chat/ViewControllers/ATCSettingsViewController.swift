//
//  ATCSettingsViewController.swift
//  ChatApp
//
//  Created by Osama Naeem on 23/05/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ATCSettingsViewController: QuickTableViewController {

    private var pushNotificationToggle: SwitchRow<SwitchCell>!
    private var facetouchIDToggle: SwitchRow<SwitchCell>!
    private var saveButton: TapActionRow<TapActionCell>!
   
    let push_notification_key = "push_notifications_enabled"
    let face_id_key = "face_id_enabled"
    
    var userSettingsJSON : [String : Bool] = [:]
    var user: ATCUser? = nil
    
    private var db = Firestore.firestore()
    private var settingsListener: ListenerRegistration?
    
    var notificationstatus : Bool = false
    var faceIDStatus: Bool = false
    
    private let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings".localizedCore
        
        userSettingsJSON[push_notification_key] = false
        userSettingsJSON[face_id_key] = false

        pushNotificationToggle = SwitchRow(text: "Allow Push Notifications".localizedChat, switchValue: notificationstatus, action: didToggleSelection())
        facetouchIDToggle = SwitchRow (text: "Enable Face/Touch ID".localizedChat, switchValue: faceIDStatus, action: didToggleSelection())
        saveButton = TapActionRow(text: "Save".localizedCore, action: buttonPressed())
        
        tableContents = [
            Section(title: "General".localizedChat, rows: [pushNotificationToggle,facetouchIDToggle]),
            Section(title: "", rows: [saveButton])]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        guard let user = user else { return }
        let results = defaults.value(forKey: "\(user.uid!)") as? [String : Bool]
        if let result = results {
            notificationstatus = result[push_notification_key] ?? false
            faceIDStatus = result[face_id_key] ?? false
        }
        pushNotificationToggle.switchValue = notificationstatus
        facetouchIDToggle.switchValue = faceIDStatus
    }
    
    // MARK: - Actions
    private func buttonPressed() -> (Row) -> Void {
        return { [unowned self] in
            switch $0 {
            case let row as TapActionRow<TapActionCell> where row == self.saveButton:
                self.handleSaveButton()
            default:
                break
            }
        }
    }
    
    private func didToggleSelection() -> (Row) -> Void {
        return { [unowned self]  in
            switch $0 {
            case let row as SwitchRow<SwitchCell> where row == self.pushNotificationToggle:
                self.addSettingsToDictionary(key: (self.push_notification_key), value: row.switchValue)
            case let row as SwitchRow<SwitchCell> where row == self.facetouchIDToggle:
                self.addSettingsToDictionary(key: (self.face_id_key), value: row.switchValue)
            default:
                break
            }
        }
    }
    
    func addSettingsToDictionary(key: String, value: Bool) {
        userSettingsJSON[key] = value
    }
    
    //MARK: - Saving settings to Firebase and User Defaults
    func handleSaveButton() {
        guard let user = user else { return }
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.impactOccurred()
        let hud = CPKProgressHUD.progressHUD(style: .loading(text: nil))
        hud.show(in: view)
        let usersRef = db.collection("users/\(user.uid!)/settings").document("\(user.uid!)")
        usersRef.setData(userSettingsJSON) { (_) in
            hud.dismiss()
            self.defaults.set(self.userSettingsJSON, forKey: "\(user.uid!)")
            self.navigationController?.popViewController(animated: true)
        }
    }
}
