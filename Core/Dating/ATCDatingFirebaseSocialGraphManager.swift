//
//  ATCDatingFirebaseSocialGraphManager.swift
//  DatingApp
//
//  Created by Florian Marcu on 3/31/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import FirebaseFirestore
import UIKit

class ATCDatingFirebaseSocialGraphManager: NSObject {
    static func fetchMatches(for user: ATCDatingProfile, completion: @escaping (_ friends: [ATCDatingProfile]) -> Void) {
        guard user.uid != nil else { return }
        let swipesRef = Firestore.firestore().collection("swipes").whereField("author", isEqualTo: user.uid ?? "")
        let reverseSwipesRef = Firestore.firestore().collection("swipes").whereField("swipedProfile", isEqualTo: user.uid ?? "")
        let usersRef = Firestore.firestore().collection("users")

        let userReporter = ATCFirebaseUserReporter()
        userReporter.userIDsBlockedOrReported(by: user) { (illegalUserIDs) in
            swipesRef.getDocuments { (querySnapshot, error) in
                if error != nil {
                    return
                }
                guard let querySnapshot = querySnapshot else {
                    return
                }
                let documents = querySnapshot.documents
                if documents.count == 0 {
                    completion([])
                    return
                }
                let swipes = documents.map({ATCDatingSwipe(representation: $0.data())})
                reverseSwipesRef.getDocuments(completion: { (querySnapshot, error) in
                    if error != nil {
                        return
                    }
                    guard let querySnapshot = querySnapshot else {
                        return
                    }
                    let reverseDocuments = querySnapshot.documents
                    if reverseDocuments.count == 0 {
                        completion([])
                        return
                    }
                    let reverseSwipes = reverseDocuments.map({ATCDatingSwipe(representation: $0.data())})
                    var matchesUIDs: [String] = []
                    // Compute all the mutual swipes
                    for swipe in swipes {
                        let reverseSwipeExists = reverseSwipes.contains(where: { (reverseSwipe) -> Bool in
                            swipe.author == reverseSwipe.swipedProfile && swipe.swipedProfile == reverseSwipe.author
                        })
                        if reverseSwipeExists {
                            matchesUIDs.append(swipe.swipedProfile ?? "")
                        }
                    }
                    // We filter out the blocked/reported users, even if they matched
                    matchesUIDs = matchesUIDs.filter({return !illegalUserIDs.contains($0)})

                    // Now we have all the user IDs whom the current user matched, and did not block/report
                    // We fetch their profile from the users Firebase table
                    var matches: [ATCDatingProfile] = []
                    var totalFetched = 0
                    for userID in matchesUIDs {
                        usersRef.document(userID).getDocument(completion: { (document, error) in
                            totalFetched += 1
                            if let document = document,
                                let data = document.data() {
                                let matchedProfile = ATCDatingProfile(representation: data)
                                matches.append(matchedProfile)
                            }
                            if (totalFetched == matchesUIDs.count) {
                                completion(matches)
                            }
                        })
                    }
                })
            }
        }
    }
}
