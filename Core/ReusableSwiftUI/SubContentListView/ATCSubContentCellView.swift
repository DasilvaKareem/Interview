//
//  ATCSubContentListView.swift
//  FitnessApp
//
//  Copyright © 2020 iOSAppTemplates. All rights reserved.
//

import SwiftUI

struct ATCSubContentCellView: View, AppConfigProtocol {
    private let subContent: SubContentModelProtocol
    private let numericalOrder: String?
    private let needsLikeIcon: Bool
    init(numericalOrder: String? = nil, subContent: SubContentModelProtocol, needsLikeIcon: Bool = true) {
        self.numericalOrder = numericalOrder
        self.subContent = subContent
        self.needsLikeIcon = needsLikeIcon
    }
    var body: some View {
        HStack(alignment: .center) {
            if numericalOrder != nil {
                Text(numericalOrder!)
                    .modifier(ATCTextModifier(font: appConfig.regularSmallFont,
                                              color: .gray))
            }
            Image(subContent.image)
                .frame(width: 70, height: 70, alignment: .center)
                .cornerRadius(8)
            VStack(alignment: .leading, spacing: 8) {
                Text(subContent.title)
                    .multilineTextAlignment(.leading)
                    .modifier(ATCTextModifier(font: appConfig.mediumBoldFont,
                                              color: .black))
                Text(subContent.category.content)
                    .modifier(ATCTextModifier(font: appConfig.regularSmallFont,
                                              color: .gray))
            }
            Spacer()
            if needsLikeIcon {
                Image("fitness-heart-gray")
            }
        }.padding()
    }
}
