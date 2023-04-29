//
//  ATCDatingProfileEditManager.swift
//  DatingApp
//
//  Created by Florian Marcu on 2/19/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

protocol ATCDatingProfileEditManagerDelegate: class {
    func profileEditManager(_ manager: ATCDatingProfileEditManager, didFetch datingProfile: ATCDatingProfile) -> Void
    func profileEditManager(_ manager: ATCDatingProfileEditManager, didUpdateProfile success: Bool) -> Void
}

protocol ATCDatingProfileEditManager: class {
    var delegate: ATCDatingProfileEditManagerDelegate? {get set}
    func fetchDatingProfile(for user: ATCUser?) -> Void
    func update(profile: ATCDatingProfile,
                email: String,
                firstName: String,
                lastName: String,
                age: String,
                bio: String,
                school: String,
                gender: String,
                genderPreference: String,
                locationPreference: String) -> Void
    func updateVipAccount(profile: ATCDatingProfile?,
                          isVipAccount: Bool,
                          startVipAccountDate: Date?,
                          endVipAccountDate: Date?,
                          completionHandler: @escaping (Error?)->())
    func updateNumberOfSwipes(profile: ATCDatingProfile?,
                              completionHandler: @escaping (Error?)->())
}
