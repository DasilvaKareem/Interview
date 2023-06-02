//
//  ATCDatingFeedFirebaseDataSource.swift
//  DatingApp
//
//  Created by Florian Marcu on 2/18/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import FirebaseFirestore
import UIKit

class ATCDatingFeedFirebaseDataSource: ATCDatingFeedDataSource {

    var viewer: ATCDatingProfile? = nil
    var recommendations: [ATCDatingProfile] = []
    let firebaseReporter = ATCFirebaseUserReporter()

    weak var delegate: ATCGenericCollectionViewControllerDataSourceDelegate?

    func object(at index: Int) -> ATCGenericBaseModel? {
        if (index >= recommendations.count) {
            return nil
        }
        return recommendations[index]
    }

    func numberOfObjects() -> Int {
        return recommendations.count
    }

    func loadFirst() {
        // self.delegate?.genericCollectionViewControllerDataSource(self, didLoadFirst: [])
    }

    func loadBottom() {
        // self.delegate?.genericCollectionViewControllerDataSource(self, didLoadBottom: [])
    }

    func loadTop() {
        self.fetchDatingRecommendations()
    }

    func fetchDatingRecommendations() {
        guard let viewer = self.viewer else { return }
        //Filter by location
        let distanceMap: [String: Double] = ["5 miles": 5.0, "10 miles": 10.0, "20 miles": 20.0, "50 miles": 50.0, "100 miles": 100.0]
        let distanceThresholdInMiles: Double = distanceMap[viewer.locationPreference ?? ""] ?? 100000

        // First, we fetch all the users reported or blocked by the viewer, so we don't show those profiles again
        //Filter By Blocked List
        firebaseReporter.userIDsBlockedOrReported(by: viewer) {[weak self] (blockedUsers) in
            guard let `self` = self else { return }

            // Secondly, we fetch all the swipes for the current user, so we don't show those profiles again
            self.fetchAllSwipes { [weak self] (swipes) in
                guard let `self` = self else {
                    return
                }

                // Then we fetch all the users in the database and filter out those who've already been swiped by the current user
                let usersRef = Firestore.firestore().collection("users")
                usersRef.getDocuments { [weak self] (querySnapshot, error) in
                    guard let `self` = self else {
                        return
                    }
                    if let _ = error {
                        return
                    }
                    guard let querySnapshot = querySnapshot else {
                        return
                    }
                    var users: [ATCDatingProfile] = []
                    let documents = querySnapshot.documents
                    for document in documents {
                        let data = document.data()
                        let user = ATCDatingProfile(representation: data)
                        if user.uid != viewer.uid {
                            users.append(user)
                        }
                    }

                    // We filter out all the users who were reported or blocked by the current viewer
                 /*   users = users.filter({ (profile) -> Bool in
                        if let uid = profile.uid {
                            return !blockedUsers.contains(uid)
                        }
                        return true
                    })*/

                    // We filter out all users who've been swiped already
                    /*users = users.filter({ (profile) -> Bool in
                        return !swipes.contains(where: { (swipe) -> Bool in
                            return (swipe.swipedProfile == profile.uid)
                        })
                    })*/

                    // We filter out all users who don't match the gender preference
                    guard let genderPreference = viewer.genderPreference else { return }
                    if genderPreference != "Both" {
                        users = users.filter({ (profile) -> Bool in
                            return genderPreference == profile.gender
                        })
                    }

                    // We filter out all users who don't match the location preference
                    // If viewer didn't set location preference, show everyone
               /*     if let viewLocation = viewer.location {
                        users = users.filter({ (profile) -> Bool in
                            guard let otherProfileLocation = profile.location else { return false } // filter out everyone without a location
                            return otherProfileLocation.isInRange(to: viewLocation, by: distanceThresholdInMiles) // keep only those within range
                        })
                    }*/
                    // We also filter out users who have uncompleted profiles
                   /* users = users.filter({ (profile) -> Bool in
                        return profile.isComplete
                    })*/
                    self.recommendations = users
                    // Now that we have everything from the server, we update the UI:
                    self.delegate?.genericCollectionViewControllerDataSource(self, didLoadTop: users)
                }
            }
        }
    }

    func fetchAllSwipes(completion: @escaping (_ swipes: [ATCDatingSwipe]) -> Void) {
        guard let viewer = self.viewer else { return }
        let swipesRef = Firestore.firestore().collection("swipes").whereField("author", isEqualTo: viewer.uid ?? "defaultid")
        swipesRef.getDocuments { [weak self] (querySnapshot, error) in
            guard self != nil else {
                return
            }
            if let _ = error {
                return
            }
            guard let querySnapshot = querySnapshot else {
                return
            }
            var swipes: [ATCDatingSwipe] = []
            let documents = querySnapshot.documents
            for document in documents {
                let data = document.data()
                let swipe = ATCDatingSwipe(representation: data)
                swipes.append(swipe)
            }
            completion(swipes)
        }
    }
}
