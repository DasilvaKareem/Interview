//
//  ATCUpgradeAccountConsumerTypesView.swift
//  DatingApp
//
//  Created by Duy Bui on 12/15/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import SwiftUI

struct ATCUpgradeAccountConsumerTypesView: View {
    @State var isFirstSubSelected: Bool = false
    @State var isSecondSubSelected: Bool = false
    @Binding var selectedSubscription: ATCSubscription?
    let appConfig: ATCUpgradeAccountConfigurationUIProtocol
    let uiConfig: ATCUIGenericConfigurationProtocol
    let freeTrialCompletionHandler: () -> Void
    var body: some View {
        VStack(spacing: 20.0) {
            ATCUpgradeAccountConsumerTypeView(isChecked: $isFirstSubSelected,
                                              nameType: appConfig.firstSubscription.name,
                                              subscription: appConfig.firstSubscription,
                                              uiConfig: uiConfig,
                                              freeTrialCompletionHandler: freeTrialCompletionHandler) {
                                                if self.isFirstSubSelected {
                                                    self.isSecondSubSelected = false
                                                    self.selectedSubscription = self.appConfig.firstSubscription
                                                }
                                                self.clearData()
            }
            ATCUpgradeAccountConsumerTypeView(isChecked: $isSecondSubSelected,
                                              nameType: appConfig.secondSubscription.name,
                                              subscription: appConfig.secondSubscription,
                                              uiConfig: uiConfig,
                                              freeTrialCompletionHandler: freeTrialCompletionHandler) {
                                                if self.isSecondSubSelected {
                                                    self.isFirstSubSelected = false
                                                    self.selectedSubscription = self.appConfig.secondSubscription
                                                }
                                                self.clearData()
            }
        }
    }
    
    private func clearData() {
        if !isFirstSubSelected && !isSecondSubSelected {
            self.selectedSubscription = nil
        }
    }
}
