//
//  ATCDrawerMenuView.swift
//  FitnessApp
//
//  Copyright © 2020 iOSAppTemplates. All rights reserved.
//

import SwiftUI

struct ATCDrawerMenuView: View, AppConfigProtocol {
    @Binding var openDrawer: Bool
    let user: FitnessUserProtocol
    let completion: (Int) -> Void
    private var drawerMenuItems: [(icon: String, text: String)] {
        return FitnessAppConfiguration.shared.drawerMenuItems
    }
    var body: some View {
        VStack {
            VStack {
                ATCAvatarView(image: user.imageIcon,
                              squareLength: 90)
                    .padding(.top, 40)
                Text(user.userName)
                    .modifier(ATCTextModifier(font: appConfig.boldLargeFont,
                                              color: .white))
            }.padding(.vertical, 40)
            ForEach(0..<drawerMenuItems.count) { ind in
                if (ind == self.drawerMenuItems.count - 1) {
                    Spacer()
                }
                ATCDrawerMenuRowView(icon: self.drawerMenuItems[ind].icon,
                                     text: self.drawerMenuItems[ind].text)
                    .onTapGesture {
                        self.completion(ind + 1)
                }
            }
        }
        .padding(.vertical, 30)
        .background(Color(appConfig.mainThemeForegroundColor))
        .padding(.trailing, 80)
        .offset(x: openDrawer ? 0 : -UIScreen.main.bounds.width)
        .rotation3DEffect(Angle(degrees: openDrawer ? 0 : 45), axis: (x: 0, y: 20, z: 0))
        .animation(.default)
        .onTapGesture {
            self.openDrawer.toggle()
        }
        .edgesIgnoringSafeArea(.vertical)
    }
}

struct ATCDrawerMenuRowView: View, AppConfigProtocol {
    var icon: String
    var text: String
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 48, height: 32)
                .foregroundColor(Color.white)
            Text(text)
                .modifier(ATCTextModifier(font: appConfig.regularMediumFont,
                                          color: .white))
            Spacer()
        }
        .padding(4)
        .padding(.trailing, 20)
        .offset(x: 20)
    }
}
