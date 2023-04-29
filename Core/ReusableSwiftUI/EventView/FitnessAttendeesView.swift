//
//  FitnessAttendeesView.swift
//  FitnessApp
//
//  Copyright © 2020 iOSAppTemplates. All rights reserved.
//

import SwiftUI

struct FitnessAttendeesView: View, AppConfigProtocol {
    let attendees: [FitnessUserProtocol]
    var body: some View {
        HStack {
            HStack {
                HStack {
                    ATCAvatarView(image: attendees[safeIndex: 0]?.imageIcon ?? "",
                                  squareLength: 30)
                    ATCAvatarView(image: attendees[safeIndex: 1]?.imageIcon ?? "",
                                  squareLength: 30)
                }
                if attendees.count > 2 {
                    Text("+ \(attendees.count - 2)")
                        .modifier(ATCTextModifier(font: appConfig.boldSmallFont,
                                                  color: .white))
                        .padding(8)
                        .background(Color.gray)
                        .cornerRadius(100)
                }
            }
            Spacer()
            Button(action: {
                print("Got here")
            }) {
                Text("Interested")
                    .modifier(ATCButtonModifier(font: appConfig.mediumBoldFont,
                                                color: appConfig.hairlineColor,
                                                textColor: appConfig.mainThemeForegroundColor,
                                                width: 120,
                                                height: 40))
            }
        }
    }
}
