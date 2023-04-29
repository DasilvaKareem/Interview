//
//  ATCSubscription.swift
//  DatingApp
//
//  Copyright © 2020 iOSAppTemplates. All rights reserved.
//

import Foundation

enum ATCIAPProduct: String {
    case autoRenewableSubscription = "com.instaswipey.InstaswipeyAutoRenewableSubscription"
    case autoRenewableSubscriptionByYear = "com.instaswipey.InstaswipeyAutoRenewableSubscriptionByYear"
    case freeTrialAutoRenewableSubscription = "com.instaswipey.FreeTrial.InstaswipeyAutoRenewableSubscriptionByMonth"
    case freeTrialAutoRenewableSubscriptionByYear = "com.instaswipey.FreeTrial.InstaswipeyAutoRenewableSubscriptionByYear"
    
    var content: String {
        return rawValue
    }
}

struct ATCSubscription {
    let name: String
    let startDate: Date?
    let endDate: Date?
    let type: ATCIAPProduct
}
