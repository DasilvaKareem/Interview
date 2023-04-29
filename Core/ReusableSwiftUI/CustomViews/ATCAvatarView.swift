//
//  ATCAvatarView.swift
//  FitnessApp
//
//  Copyright © 2020 iOSAppTemplates. All rights reserved.
//

import SwiftUI

struct ATCAvatarView: View, AppConfigProtocol {
    let image: String
    let squareLength: CGFloat
    let needBorder: Bool
    
    init(image: String, squareLength: CGFloat, needBorder: Bool = false) {
        self.image = image
        self.squareLength = squareLength
        self.needBorder = needBorder
    }
    
    var body: some View {
        Image(image)
        .resizable()
        .frame(width: squareLength,
               height: squareLength,
               alignment: .center)
        .padding(4)
            .overlay(Circle().stroke(needBorder ? Color(appConfig.mainThemeForegroundColor) : Color.clear, lineWidth: 2))
    }
}

struct ATCAvatarView_Previews: PreviewProvider {
    static var previews: some View {
        ATCAvatarView(image: "mocking-avatar-icon-1", squareLength: 40.0)
    }
}

