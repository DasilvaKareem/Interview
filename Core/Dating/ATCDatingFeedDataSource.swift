//
//  ATCDatingFeedDataSource.swift
//  DatingApp
//
//  Created by Florian Marcu on 1/23/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

protocol ATCDatingFeedDataSource: ATCGenericCollectionViewControllerDataSource {
    var delegate: ATCGenericCollectionViewControllerDataSourceDelegate? {get set}
    var viewer: ATCDatingProfile? {get set}
}
