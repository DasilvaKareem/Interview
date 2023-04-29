//
//  ATCInstagramPhotoImporter.swift
//  DatingApp
//
//  Created by Florian Marcu on 3/7/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCInstagramPhotoImporter {

    var accessToken: String

    private let networkingManager: ATCNetworkingManager = ATCNetworkingManager()

    init(accessToken: String) {
        self.accessToken = accessToken
    }

    func importPhotos(_ completion: (_ photos: [String]?) -> Void) {
    }
}
