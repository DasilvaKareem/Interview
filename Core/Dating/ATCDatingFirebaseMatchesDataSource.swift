//
//  ATCDatingFirebaseMatchesDataSource.swift
//  DatingApp
//
//  Created by Florian Marcu on 3/31/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import Firebase
import UIKit

class ATCDatingFirebaseMatchesDataSource: ATCDatingFeedDataSource {
    var viewer: ATCDatingProfile? = nil
    weak var delegate: ATCGenericCollectionViewControllerDataSourceDelegate?
    var matches: [ATCDatingProfile] = []


    func object(at index: Int) -> ATCGenericBaseModel? {
        if index < matches.count {
            return matches[index]
        }
        return nil
    }

    func numberOfObjects() -> Int {
        return matches.count
    }

    func loadFirst() {
        guard let viewer = viewer else { return }
        ATCDatingFirebaseSocialGraphManager.fetchMatches(for: viewer) {[weak self] (matches) in
            guard let `self` = self else { return }
            self.matches = matches
            self.delegate?.genericCollectionViewControllerDataSource(self, didLoadFirst: matches)
        }
    }

    func loadBottom() {
        self.delegate?.genericCollectionViewControllerDataSource(self, didLoadBottom: [])
    }

    func loadTop() {
        self.delegate?.genericCollectionViewControllerDataSource(self, didLoadTop: [])
    }
}
