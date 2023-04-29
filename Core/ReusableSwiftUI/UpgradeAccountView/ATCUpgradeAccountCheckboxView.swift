//
//  ATCUpgradeAccountCheckboxView.swift
//  DatingApp
//
//  Created by Duy Bui on 12/19/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import SwiftUI

struct ATCUpgradeAccountCheckboxView: View {
    @Binding var isChecked: Bool
    @State private var showingAlert = true
    let nameType: String
    let subscription: ATCSubscription
    let uiConfig: ATCUIGenericConfigurationProtocol
    let completionHandler: () -> ()
    let freeTrialCompletionHandler: () -> Void
    var body: some View {
        VStack {
            Spacer()
            HStack(alignment: .center) {
                Button(action: {
                    self.isChecked.toggle()
                    self.completionHandler()
                }) {
                    HStack {
                        Image(isChecked ? "dating-full-circle-icon": "dating-empty-circle-icon")
                            .scaledToFit()
                        Text(splitString(self.nameType)[0]).font(.system(size: 22)).foregroundColor(Color.black)
                            + Text("/").foregroundColor(Color.black)
                            + Text(splitString(self.nameType)[1]).foregroundColor(Color.black)
                    }
                }.buttonStyle(PlainButtonStyle())
                Spacer()
                // This button is used for Free Trial
                Button(action: {
                    self.freeTrialCompletionHandler()
                }) {
                    Text("Free Trial")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 150, height: 50)
                        .background(Color(uiConfig.mainThemeForegroundColor))
                        .cornerRadius(25.0)
                }
            }
            Spacer()
        }
    }
    
    private func splitString(_ originalString: String) -> [String] {
        return originalString.components(separatedBy: "/")
    }
}
