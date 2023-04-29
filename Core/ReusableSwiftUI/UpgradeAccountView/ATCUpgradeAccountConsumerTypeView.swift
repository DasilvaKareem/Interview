//
//  ATCUpgradeAccountConsumerTypeView.swift
//  DatingApp
//
//  Created by Duy Bui on 12/19/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import SwiftUI

struct ATCUpgradeAccountConsumerTypeView: View {
    @Binding var isChecked: Bool
    let nameType: String
    let subscription: ATCSubscription
    let uiConfig: ATCUIGenericConfigurationProtocol
    let freeTrialCompletionHandler: () -> Void
    let completionHandler: () -> Void
    
    var body: some View {
        VStack {
            ATCUpgradeAccountCheckboxView(isChecked: $isChecked,
                                  nameType: nameType,
                                  subscription: subscription,
                                  uiConfig: uiConfig,
                                  completionHandler: completionHandler,
                                  freeTrialCompletionHandler: freeTrialCompletionHandler)
        }
        .frame(width: 360, height: 60, alignment: .center)
        .padding()
        .background(Color.white)
        .cornerRadius(20.0)
        .shadow(color: Color(UIColor(hexString: "#DCE6E6")), radius: 5.0, x: 3, y: 3)
    }
}

