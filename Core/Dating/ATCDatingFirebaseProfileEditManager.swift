//
//  ATCDatingFirebaseProfileEditManager.swift
//  DatingApp
//
//  Created by Florian Marcu on 2/19/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import FirebaseFirestore
import UIKit

class ATCDatingFirebaseProfileEditManager: ATCDatingProfileEditManager {
    
    weak var delegate: ATCDatingProfileEditManagerDelegate?
    func fetchDatingProfile(for user: ATCUser?) -> Void {
        guard let uid = user?.uid else { return }
        let usersRef = Firestore.firestore().collection("users").document(uid)
        usersRef.getDocument {[weak self] (snapshot, error) in
            guard let `self` = self else { return }
            guard let snapshot = snapshot, let data = snapshot.data() else { return }
            let datingProfile = ATCDatingProfile(representation: data)
            self.delegate?.profileEditManager(self, didFetch: datingProfile)
        }
    }

    func update(profile: ATCDatingProfile,
                email: String,
                firstName: String,
                lastName: String,
                age: String,
                bio: String,
                school: String,
                gender: String,
                genderPreference: String,
                locationPreference: String) {
        guard let uid = profile.uid else { return }
        let profileRef = Firestore.firestore().collection("users").document(uid)
        let newData = [
            "firstName": firstName,
            "fullname": firstName + " " + lastName,
            "age": age,
            "bio": bio,
            "school": school,
            "lastName": lastName,
            "email": email,
            "gender": gender,
            "genderPreference": genderPreference,
            "locationPreference": locationPreference
        ]
        profileRef.setData(newData, merge: true) {[weak self] (error) in
            guard let `self` = self else { return }
            self.delegate?.profileEditManager(self, didUpdateProfile: (error == nil))
        }
    }
    
    func updateVipAccount(profile: ATCDatingProfile?,
                          isVipAccount: Bool,
                          startVipAccountDate: Date?,
                          endVipAccountDate: Date?,
                          completionHandler: @escaping (Error?) -> ()) {
        guard let profile = profile, let uid = profile.uid else { return }
        let newData: [String: Any] = ["isVipAccount": isVipAccount,
                                      "startVipDate": startVipAccountDate?.convertToString ?? "",
                                      "endVipDate": endVipAccountDate?.convertToString ?? ""]
        let profileRef = Firestore.firestore().collection("users").document(uid)
        profileRef.setData(newData, merge: true) {(error) in
            completionHandler(error)
        }
    }
    
    func updateNumberOfSwipes(profile: ATCDatingProfile?,
                              completionHandler: @escaping (Error?) -> ()) {
        guard let profile = profile, let uid = profile.uid else { return }
        let newData: [String: Any] = ["limitedTime": profile.limitedTime ?? "",
                                      "numberOfSwipes": profile.numberOfSwipes]
        let profileRef = Firestore.firestore().collection("users").document(uid)
        profileRef.setData(newData, merge: true) {(error) in
            completionHandler(error)
        }
    }
}
