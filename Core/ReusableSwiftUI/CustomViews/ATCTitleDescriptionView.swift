//
//  ATCTitleDescriptionView.swift
//  FitnessApp
//
//  Created by Duy Bui on 1/15/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import SwiftUI

struct ATCTitleDescriptionView: View {
    private let title: String?
    private let titleFont: UIFont
    private let titleColor: UIColor
    private let description: String?
    private let descriptionFont: UIFont
    private let descriptionColor: UIColor
    
    init(title: String?,
         titleFont: UIFont? = nil,
         titleColor: UIColor? = nil,
         description: String?,
         descriptionFont: UIFont? = nil,
         descriptionColor: UIColor? = nil,
         appConfig: ATCUIGenericConfigurationProtocol) {
        self.title = title
        self.description = description
        self.titleFont = titleFont ?? appConfig.boldSuperLargeFont
        self.titleColor = titleColor ?? appConfig.colorGray0
        self.descriptionFont = descriptionFont ?? appConfig.regularMediumFont
        self.descriptionColor = descriptionColor ?? appConfig.colorGray3
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 13) {
            title.map {
                Text($0)
                    .modifier(ATCTextModifier(font: titleFont,
                                              color: titleColor))
            }
            description.map {
                Text($0)
                    .modifier(ATCTextModifier(font: descriptionFont,
                                              color: descriptionColor))
            }
        }
    }
}
