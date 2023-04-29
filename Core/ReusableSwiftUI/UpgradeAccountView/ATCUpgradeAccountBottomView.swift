//
//  ATCUpgradeAccountBottomView.swift
//  DatingApp
//
//  Created by Duy Bui on 12/19/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//
import SwiftUI

struct ATCUpgradeAccountBottomView: View {
    @Binding var selectedSubscription: ATCSubscription?
    @State private var showingAlert = true
    let uiConfig: ATCUIGenericConfigurationProtocol
    let subscriptionCompletionHandler: () -> Void
    var body: some View {
        VStack(alignment: .center, spacing: 30.0) {
            VStack(spacing: 1.0) {
                Text(/*@START_MENU_TOKEN@*/"Recurring billing, cancel anytime"/*@END_MENU_TOKEN@*/)
                    .font(.headline)
                Text(/*@START_MENU_TOKEN@*/"Contrary to what many people think, eating healthy is not easier said than done. Just a few good habits can make a great difference"/*@END_MENU_TOKEN@*/)
                .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button(action: {
                self.subscriptionCompletionHandler()
            }) {
                Text("Purchase")
                    .font(.headline)
                    .foregroundColor(.white)
                    .opacity(self.selectedSubscription == nil ? 0.5: 1)
                    .padding()
                    .frame(width: 300, height: 50)
                    .background(Color(uiConfig.mainThemeForegroundColor))
                    .cornerRadius(25.0)
            }.disabled(self.selectedSubscription == nil)
        }.padding(.bottom, 25)
    }
}
