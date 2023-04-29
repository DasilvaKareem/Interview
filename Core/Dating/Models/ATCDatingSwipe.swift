//
//  ATCDatingSwipe.swift
//  DatingApp
//
//  Created by Florian Marcu on 2/18/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCDatingSwipe: ATCGenericBaseModel {

    var author: String?
    var swipedProfile: String?
    var type: String?

    init(author: String? = nil, swipedProfile: String?, type: String?) {
        self.author = author
        self.swipedProfile = swipedProfile
        self.type = type
    }

    init(representation: [String: Any]) {
        self.author =  representation["author"] as? String
        self.swipedProfile = representation["swipedProfile"] as? String
        self.type = representation["type"] as? String
    }

    required public init(jsonDict: [String: Any]) {
        fatalError()
    }

    public var description: String {
        return "swipe"
    }
}
