//
//  FitnessContainerCalenderEventView.swift
//  FitnessApp
//
//  Copyright © 2020 iOSAppTemplates. All rights reserved.
//

import SwiftUI

struct FitnessTitleContainerView: View, AppConfigProtocol {
    private let title: String
    private let font: UIFont
    private let isNeedMoreOption: Bool
    init(title: String, font: UIFont, isNeedMoreOption: Bool = true) {
        self.title = title
        self.font = font
        self.isNeedMoreOption = isNeedMoreOption
    }
    var body: some View {
        HStack(alignment: .center) {
            Text(title)
                .modifier(ATCTextModifier(font: font,
                                          color: .black))
            Spacer()
            if isNeedMoreOption {
                Image("more-icon-gray")
            }
        }
    }
}
