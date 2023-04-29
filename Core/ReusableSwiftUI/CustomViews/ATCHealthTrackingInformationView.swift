//
//  ATCHealthTrackingInformationView.swift
//  FitnessApp
//
//  Copyright © 2020 iOSAppTemplates. All rights reserved.
//

import SwiftUI

struct ATCHealthTrackingInformationView: View, AppConfigProtocol {
    private let image: String
    private let trackingInformation: String
    private let value: String
    private let subDescription: String?
    init(image: String, trackingInformation: String, value: String, subDescription: String? = nil) {
        self.image = image
        self.trackingInformation = trackingInformation
        self.value = value
        self.subDescription = subDescription
    }
    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            Image(image)
            VStack(alignment: .leading, spacing: 10) {
                Text(trackingInformation)
                    .modifier(ATCTextModifier(font: appConfig.regularMediumFont,
                                              color: .black))
                if subDescription != nil {
                    Text(subDescription!)
                        .modifier(ATCTextModifier(font: appConfig.regularFont(size: 13),
                                                  color: .gray))
                }
            }
            Spacer()
            Text(value)
                .modifier(ATCTextModifier(font: appConfig.mediumBoldFont,
                                          color: .black))
        }
    }
}

struct ATCHealthTrackingInformationView_Previews: PreviewProvider {
    static var previews: some View {
        ATCHealthTrackingInformationView(image: "fitness-information-steps",
                                         trackingInformation: "Steps",
                                         value: "50")
    }
}
