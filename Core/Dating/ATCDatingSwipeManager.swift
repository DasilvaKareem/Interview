//
//  ATCDatingSwipeManager.swift
//  DatingApp
//
//  Created by Florian Marcu on 2/18/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

protocol ATCDatingSwipeManager: class {
    func recordSwipe(author: String, swipedProfile: String, type: String) -> Void
    func checkIfPositiveSwipeExists(author: String, profile: String, completion: @escaping (_ result: Bool) -> Void) -> Void
}
