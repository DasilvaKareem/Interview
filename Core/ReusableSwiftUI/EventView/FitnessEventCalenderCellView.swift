//
//  FitnessEventCalenderCellView.swift
//  FitnessApp
//
//  Copyright © 2020 iOSAppTemplates. All rights reserved.
//

import SwiftUI

struct FitnessEventCalenderCellView: View, AppConfigProtocol {
    @State private var isChecked: Bool = false
    let nearbyEvent: FitnessNearbyEventProtocol
    var body: some View {
        HStack(spacing: 16) {
            FitnessEventCalenderView(nearbyEvent: nearbyEvent)
            VStack(alignment: .leading, spacing: 10) {
                Text(nearbyEvent.title)
                    .modifier(ATCTextModifier(font: appConfig.regularMediumFont,
                                              color: .black))
                Text(nearbyEvent.eventDescription)
                    .modifier(ATCTextModifier(font: appConfig.regularSmallFont,
                                              color: .gray))
            }
            Spacer()
            Button(action: {
                self.isChecked.toggle()
            }) {
                Image(isChecked ? "fitness-heart-gray" : "fitness-heart-color")
            }.buttonStyle(PlainButtonStyle())
        }
    }
}
