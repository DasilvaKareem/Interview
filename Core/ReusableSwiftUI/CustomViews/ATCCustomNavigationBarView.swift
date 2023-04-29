//
//  ATCCustomNavigationBarView.swift
//  FitnessApp
//
//  Copyright © 2020 iOSAppTemplates. All rights reserved.
//

import SwiftUI

struct ATCCustomNavigationBarView: View, AppConfigProtocol {
    
    private let title: String?
    private let subTitle: String?
    private let leftIcon: String?
    private let rightIcon: RightIconCustomNavigation?
    private let rightButtonAction: ButtonAction?
    private let leftButtonAction: ButtonAction?
    typealias ButtonAction = () -> Void
    
    enum RightIconCustomNavigation {
        case standardIcon(image: String)
        case avatar(user: FitnessUserProtocol)
        
        var containedView: AnyView {
            switch self {
            case .standardIcon(let image):
                return AnyView(Image(image))
            case .avatar(let user):
                return AnyView(ATCAvatarView(image: user.imageIcon,
                                             squareLength: 50))
            }
        }
    }
    
    init(title: String? = nil,
         subTitle: String? = nil,
         leftIcon: String? = "fitness-menu-icon",
         rightIcon: RightIconCustomNavigation? = nil,
         leftButtonAction: ButtonAction? = nil,
         rightButtonAction: ButtonAction? = nil) {
        self.title = title
        self.subTitle = subTitle
        self.leftIcon = leftIcon
        self.rightIcon = rightIcon
        self.leftButtonAction = leftButtonAction
        self.rightButtonAction = rightButtonAction
    }
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if leftIcon != nil {
                    Button(action: {
                        self.leftButtonAction!()
                    }) {
                        Image(leftIcon!)
                            .renderingMode(.original)
                    }
                }
                Spacer()
                if rightIcon != nil  {
                    Button(action: {
                        self.rightButtonAction!()
                    }) {
                        rightIcon!.containedView
                    }.buttonStyle(PlainButtonStyle())
                }
            }.frame(height: 50)
            VStack(alignment: .leading) {
                if title != nil {
                    Text(title!)
                        .modifier(ATCTextModifier(font: self.appConfig.boldFont(size: 30),
                                                  color: .black))
                }
                if subTitle != nil {
                    Text(subTitle!)
                        .modifier(ATCTextModifier(font: self.appConfig.boldFont(size: 30),
                                                  color: .black))
                }
            }
        }.padding()
    }
}

struct ATCCustomNavigationBarView_Previews: PreviewProvider {
    static var previews: some View {
        ATCCustomNavigationBarView()
    }
}
