//
//  ATCDatingProfile.swift
//  DatingApp
//
//  Created by Florian Marcu on 1/23/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ATCDatingProfile: ATCUser {

    var school: String? = nil
    var instagramPhotos: [String]? = nil
    var age: String? = nil
    var bio: String? = nil
    var gender: String? = nil
    var genderPreference: String? = nil
    var locationPreference: String? = nil
    var isVipAccount: Bool?
    var startVipDate: String?
    var endVipDate: String?
    var limitedTime: String?
    var numberOfSwipes: Int = 0
    
    public init(uid: String = "abc",
                firstName: String,
                lastName: String,
                avatarURL: String,
                school: String = "",
                distance: String = "",
                photos: [String]? = [],
                instagramPhotos: [String]? = [],
                age: String = "19",
                email: String = "",
                bio: String?,
                gender: String?,
                genderPreference: String?,
                locationPreference: String?,
                pushToken: String? = nil,
                isOnline: Bool = false) {
        super.init(uid: uid, firstName: firstName, lastName: lastName, avatarURL: avatarURL, email: email, pushToken: pushToken, photos: photos ,isOnline: isOnline)
        self.school = school
        self.bio = bio
        self.instagramPhotos = instagramPhotos
        self.age = age
        self.gender = gender
        self.genderPreference = genderPreference
        self.locationPreference = locationPreference
        // when creating the first time, it will be false at default
        self.isVipAccount = false
    }

    public override init(representation: [String: Any]) {
        super.init(representation: representation)
        self.photos = representation["photos"] as? [String]
        self.school =  representation["school"] as? String
        self.gender =  representation["gender"] as? String
        self.genderPreference =  representation["genderPreference"] as? String
        self.locationPreference =  representation["locationPreference"] as? String
        self.bio = representation["bio"] as? String
        self.instagramPhotos = representation["instagramPhotos"] as? [String]
        self.age = representation["age"] as? String
        self.isVipAccount = representation["isVipAccount"] as? Bool
        self.isOnline = false
        self.startVipDate = representation["startVipDate"] as? String
        self.endVipDate = representation["endVipDate"] as? String
        self.numberOfSwipes = (representation["numberOfSwipes"] as? Int) ?? 0
        self.limitedTime = representation["limitedTime"] as? String
    }

    required public init(jsonDict: [String : Any]) {
        fatalError("init(jsonDict:) has not been implemented")
    }

    public convenience required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var isComplete: Bool {
        guard let profilePhoto = profilePictureURL else { return false }
        if profilePhoto == "" {
            return false
        }
        return age != nil && gender != nil && school != nil && firstName != nil
    }
    
    var checkVipStatus: Bool {
        if let checkedVipAccount = self.isVipAccount, checkedVipAccount,
            let endVipDate = self.endVipDate {
            return Date() < endVipDate.convertToDate ?? Date()
        } else {
            return false
        }
    }
    
    func increaseNumberOfSwipes() {
        self.numberOfSwipes = self.numberOfSwipes + 1
    }
}
