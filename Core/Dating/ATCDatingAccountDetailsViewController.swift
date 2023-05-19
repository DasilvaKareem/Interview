//
//  ATCDatingAccountDetailsViewController.swift
//  DatingApp
//
//  Created by Florian Marcu on 2/19/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import Eureka
import UIKit

protocol ATCDatingAccountDetailsViewControllerDelegate: class {
    func accountDetailsVCDidUpdateProfile() -> Void
}

class ATCDatingAccountDetailsViewController: FormViewController , ATCDatingProfileEditManagerDelegate{
    var user: ATCUser
    var manager: ATCDatingProfileEditManager
    var profile: ATCDatingProfile? = nil
    let cancelEnabled: Bool

    weak var delegate: ATCDatingAccountDetailsViewControllerDelegate?

    init(user: ATCUser,
         manager: ATCDatingProfileEditManager,
         cancelEnabled: Bool) {
        self.user = user
        self.manager = manager
        self.cancelEnabled = cancelEnabled
        super.init(nibName: nil, bundle: nil)
        self.manager.delegate = self
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
        self.manager.fetchDatingProfile(for: user)
        self.title = "Edit Profile"
    }

    func profileEditManager(_ manager: ATCDatingProfileEditManager, didFetch datingProfile: ATCDatingProfile) -> Void {
        self.profile = datingProfile

        form +++ Eureka.Section("Public Profile")
            <<< TextRow(){ row in
                row.title = "First Name"
                row.placeholder = "Your first name"
                row.value = datingProfile.firstName
                row.tag = "firstname"
            }
            <<< TextRow(){ row in
                row.title = "Last Name"
                row.placeholder = "Your last name"
                row.value = datingProfile.lastName
                row.tag = "lastname"
            }
            <<< TextRow(){ row in
                row.title = "Bio"
                row.placeholder = "Say something about you"
                row.value = datingProfile.bio
                row.tag = "bio"
            }
        
            <<< TextRow(){ row in
                row.title = "Graduation Year "
                row.placeholder = "e.g. 2021"
                row.value = datingProfile.age
                row.tag = "age"
            }
            <<< TextRow(){ row in
                row.title = "School"
                row.placeholder = "School"
                row.value = datingProfile.school
                row.tag = "school"
            }
            <<< ActionSheetRow<String>() {
                $0.title = "Status"
                $0.selectorTitle = "Choose your status"
                $0.options = ["Job Seeker","Recruiter"]
//                $0.value = datingProfile.gender
//                $0.tag = "gender"
            }
        <<< ActionSheetRow<String>() {
            $0.title = "Employment Type"
            $0.selectorTitle = "Choose your status"
            $0.options = ["Part time","Full time","Internship","Co-op"]
//            $0.value = datingProfile.gender
//            $0.tag = "employmentType"
        }
        <<< ActionSheetRow<String>() {
            $0.title = "Industry"
            $0.selectorTitle = "Choose your desired industry"
            $0.options = ["Sales","Developer", "Customer Service", "Marketing", "Accounting"]
//            $0.value = datingProfile.gender
//            $0.tag = "gender"
        }
            +++ Eureka.Section("Preferences")
            <<< ActionSheetRow<String>() {
                $0.title = "Status Preference"
                $0.selectorTitle = "Match me with "
                $0.options = ["Job Seeker", "Recruiter", "Both"]
                $0.value = datingProfile.genderPreference
                $0.tag = "gender_preference"
            }
            <<< ActionSheetRow<String>() {
                $0.title = "Location Radius"
                $0.selectorTitle = "Match me with jobs in this area"
                $0.options = ["5 miles", "10 miles", "20 miles", "50 miles", "100 miles"]
                $0.value = datingProfile.locationPreference
                $0.tag = "location_preference"
            }
        
            <<< ActionSheetRow<String>() {
                $0.title = "Salary"
                $0.selectorTitle = "Choose your desired Salary"
                $0.options = ["$40-60K","$60-80K", "$80-100K", "$100K"]
            //                $0.value = datingProfile.gender
            //                $0.tag = "gender"
            }
            +++ Eureka.Section("Private Details")
            <<< TextRow(){ row in
                row.title = "E-mail Address"
                row.placeholder = "Your e-mail address"
                row.value = datingProfile.email
                row.tag = "email"
        }
    }

    func profileEditManager(_ manager: ATCDatingProfileEditManager, didUpdateProfile success: Bool) -> Void {
        if (success) {
            delegate?.accountDetailsVCDidUpdateProfile()
            self.dismiss(animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Error",
                                          message: "There was an issue while updating the profile. Please try again.",
                                          preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }

    @objc private func didTapDone() {
        guard let profile = profile else { return }

        var lastName = ""
        var firstName = ""
        var email = ""
        var bio = ""
        var age = ""
        var school = ""
        var gender = ""
        var genderPreference = ""
        var locationPreference = ""

        if let row = form.rowBy(tag: "lastname") as? TextRow {
            lastName = row.value ?? ""
        }
        if let row = form.rowBy(tag: "firstname") as? TextRow {
            firstName = row.value ?? ""
        }
        if let row = form.rowBy(tag: "email") as? TextRow {
            email = row.value ?? ""
        }
        if let row = form.rowBy(tag: "age") as? TextRow {
            age = row.value ?? ""
        }
        if let row = form.rowBy(tag: "bio") as? TextRow {
            bio = row.value ?? ""
        }
        if let row = form.rowBy(tag: "school") as? TextRow {
            school = row.value ?? ""
        }
        if let row = form.rowBy(tag: "gender") as? ActionSheetRow<String> {
            gender = row.value ?? ""
        }
        if let row = form.rowBy(tag: "gender_preference") as? ActionSheetRow<String> {
            genderPreference = row.value ?? ""
        }
        if let row = form.rowBy(tag: "location_preference") as? ActionSheetRow<String> {
            locationPreference = row.value ?? ""
        }

        if school == "" || email == "" || age == "" || firstName == "" || gender == "" || genderPreference == "" {
            let alertVC = UIAlertController(title: "Please complete your profile",
                                            message: "Fill out all the blank fields",
                                            preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertVC, animated: true, completion: nil)
            return
        }
        self.manager.update(profile: profile,
                            email: email,
                            firstName: firstName,
                            lastName: lastName,
                            age: age,
                            bio: bio,
                            school: school,
                            gender: gender,
                            genderPreference: genderPreference,
                            locationPreference: locationPreference)
    }

    @objc private func didTapCancel() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}
