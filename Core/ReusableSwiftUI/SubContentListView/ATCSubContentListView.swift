//
//  ATCSubContentCellView.swift
//  FitnessApp
//
//  Copyright © 2020 iOSAppTemplates. All rights reserved.
//

import SwiftUI

struct ATCSubContentListView: View, AppConfigProtocol {
    let title: String
    let subContents: [SubContentModelProtocol]
    init(title: String, subContents: [SubContentModelProtocol]) {
        self.title = title
        self.subContents = subContents
    }
    var body: some View {
        VStack {
            FitnessTitleContainerView(title: title,
                                      font: appConfig.boldFont(size: 20))
                .padding([.top, .leading, .trailing])
            VStack {
                ForEach(subContents, id: \.id) { subContent in
                    ATCSubContentCellView(subContent: subContent).frame(height: 98, alignment: .center)
                }
            }
        }.background(Color.white)
    }
}
