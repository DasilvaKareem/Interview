//
//  ATCUpgradeAccountConfigurationUIProtocol.swift
//  DatingApp
//
//  Created by Duy Bui on 2/21/20.
//  Copyright © 2020 Instamobile. All rights reserved.
//

import Foundation

protocol ATCUpgradeAccountConfigurationUIProtocol {
    var firstSubscription: ATCSubscription {get}
    var secondSubscription: ATCSubscription {get}
    var freeTrialSubscription: ATCSubscription {get}
    var carouselData: [ATCCarouselModel] {get}
}
