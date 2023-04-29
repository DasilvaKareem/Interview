//
//  ATCCountryCodeView.swift
//  FitnessApp
//
//  Copyright © 2020 iOSAppTemplates. All rights reserved.
//

import SwiftUI

struct ATCCountryCodeView: View, AppConfigProtocol {
    @State var expand: Bool = false
    
    var body: some View {
        HStack(alignment: .center, spacing: 13) {
            VStack {
                HStack(alignment: .center, spacing: 13) {
                    Image("Romania")
                        .frame(width: 30, height: 21)
                    Text("+40")
                        .modifier(ATCTextModifier(font: appConfig.regularMediumFont,
                                                  color: .black))
                }
                if expand {
                    // To-do: Implement drop down list here
                }
            }
            Image("fitness-dropdown-icon")
                .frame(width: 24, height: 24)
                .onTapGesture {
                    self.expand.toggle()
                    print(self.expand)
            }
        }
    }
}
