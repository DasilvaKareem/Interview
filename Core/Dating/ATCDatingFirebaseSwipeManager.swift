//
//  ATCDatingFirebaseSwipeManager.swift
//  DatingApp
//
//  Created by Florian Marcu on 2/18/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import FirebaseFirestore
import UIKit

class ATCDatingFirebaseSwipeManager: ATCDatingSwipeManager {
    func recordSwipe(author: String, swipedProfile: String, type: String) -> Void {
        let data = ["author": author, "swipedProfile": swipedProfile, "type": type]
        let swipesRef = Firestore.firestore().collection("swipes")
        swipesRef.addDocument(data: data)
    }
    
    func checkIfPositiveSwipeExists(author: String, profile: String, completion: @escaping (_ result: Bool) -> Void) -> Void {
        let swipesRef = Firestore.firestore().collection("swipes").whereField("author", isEqualTo: author).whereField("swipedProfile", isEqualTo: profile)
        swipesRef.getDocuments { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                return
            }
            if let _ = error {
                return
            }
            let documents = querySnapshot.documents
            for document in documents {
                let data = document.data()
                let swipe = ATCDatingSwipe(representation: data)
                if swipe.type == "like" || swipe.type == "superlike" {
                    completion(true)
                    return
                }
            }
            completion(false)
        }
    }
}
