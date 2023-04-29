//
//  DatingAppConfiguration.swift
//  DatingApp
//
//  Created by Florian Marcu on 1/23/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

protocol DatingInAppConfigurationProtocol: ATCOnboardingServerConfigurationProtocol, ATCUpgradeAccountConfigurationUIProtocol {
    var numberOfSwipes: Int {get}
}

class DatingAppConfiguration: DatingInAppConfigurationProtocol {
    var isPhoneAuthEnabled: Bool = false
    var appIdentifier: String = "dating-swift-ios"
    var isFirebaseAuthEnabled: Bool = true
    var isFirebaseDatabaseEnabled: Bool = true
    var isInstagramIntegrationEnabled: Bool = false
    var firstSubscription = ATCSubscription(name: "4.99$/month",
                                                  startDate: Date(),
                                                  endDate: Calendar.current.date(byAdding: .month, value: 1, to: Date()),
                                                  type: .autoRenewableSubscription)
    var secondSubscription = ATCSubscription(name: "89.99$/year",
                                                   startDate: Date(),
                                                   endDate: Calendar.current.date(byAdding: .year, value: 1, to: Date()),
                                                   type: .autoRenewableSubscriptionByYear)
    
    var freeTrialSubscription = ATCSubscription(name: "Free Trial",
                                                startDate: Date(),
                                                endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()),
                                                type: .freeTrialAutoRenewableSubscription)
    // This property is used for limiting number of swipes per day for non-VIP users
    var numberOfSwipes = 25
    
    // data for carousel views in upgrade views
    var carouselData = [
        ATCCarouselModel(id: 0, image: "dating-onboarding1-icon", title: "Go VIP", description: "When you subscribe, you get unlimited daily swipes, undo actions, VIP badge and more."),
        ATCCarouselModel(id: 1, image: "dating-onboarding2-icon", title: "Get a Personal Trainer", description: "Our premium package includes a weekly 1-hour session with a personal trainer."),
        ATCCarouselModel(id: 2, image: "dating-onboarding3-icon", title: "VIP Guest Membership", description: "As a valued member, you can place your friends, family on your VIP guest list to work together."),
        ATCCarouselModel(id: 3, image: "dating-onboarding4-icon", title: "Professional Gymnastics", description: "Come along with it, you get instant unlimited access to Professional Gymnastics courses."),
        ATCCarouselModel(id: 4, image: "dating-onboarding5-icon", title: "VIP Environment", description: "You only need to workout as passionately as you work. Let us take care the rest.")
    ]
}

class DatingChatServiceConfig: ATCChatServiceConfigProtocol {
    var isTypingIndicatorEnabled: Bool = false
    
    var showOnlineStatus: Bool = false
    
    var showLastSeen: Bool = false

    var emptyViewTitleButton: String = ""
    var emptyViewDescription: String = ""
    var isAudioMessagesEnabled = true
}
