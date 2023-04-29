//
//  ATCDatingMatchesDataSource.swift
//  DatingApp
//
//  Created by Florian Marcu on 1/26/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCDatingMatchesDataSource: ATCGenericCollectionViewControllerDataSource {
    weak var delegate: ATCGenericCollectionViewControllerDataSourceDelegate?

    func object(at index: Int) -> ATCGenericBaseModel? {
        return nil
    }

    func numberOfObjects() -> Int {
        return 0
    }

    func loadFirst() {
        self.delegate?.genericCollectionViewControllerDataSource(self, didLoadFirst: [])
    }

    func loadBottom() {
        self.delegate?.genericCollectionViewControllerDataSource(self, didLoadBottom: [])
    }

    func loadTop() {
        self.delegate?.genericCollectionViewControllerDataSource(self, didLoadTop: [])
    }
}
