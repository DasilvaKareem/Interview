//
//  ATCTextAndToggleView.swift
//  FitnessApp
//
//  Copyright © 2020 iOSAppTemplates. All rights reserved.
//

import SwiftUI

struct ATCTextAndToggleView: View, AppConfigProtocol {
    private let text: String
    private let subText: String?
    private let isToggleShown: Bool
    private let useThemeColor: Bool
    @State private var isToggled = true
    init(text: String, subText: String? = nil, isToggleShown: Bool = false, useThemeColor: Bool = false) {
        self.text = text
        self.subText = subText
        self.isToggleShown = isToggleShown
        self.useThemeColor = useThemeColor
        UISwitch.appearance().onTintColor = UIColor(hexString: "#3ec8bc")
    }
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                Text(text)
                    .foregroundColor(useThemeColor ? Color(appConfig.mainThemeForegroundColor) : .black)
                if subText != nil {
                     Text(subText!)
                        .modifier(ATCTextModifier(font: appConfig.regularFont(size: 12),
                                                  color: .gray))
                }
            }
            Spacer()
            if isToggleShown {
                Toggle(isOn: $isToggled) {
                    EmptyView()
                }
            }
            // Uncomment this line of code if do something with UI if any
            // if isToggled {}
            }
    }
}

struct ATCTextAndToggleView_Previews: PreviewProvider {
    static var previews: some View {
        ATCTextAndToggleView(text: "Duy", useThemeColor: true)
    }
}
