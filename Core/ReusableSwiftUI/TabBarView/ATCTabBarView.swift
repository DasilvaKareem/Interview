//
//  ATCTabBarView.swift
//  FitnessApp
//
//  Copyright © 2020 iOSAppTemplates. All rights reserved.
//

import SwiftUI

struct ATCTabBarView: View, AppConfigProtocol {
    @State var showSheetView = false
    @State var selected = 0
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                if self.selected == 0 {
                    FitnessHomeView()
                } else if self.selected == 1 {
                    FitnessPodcastView()
                } else if self.selected == 2 {
                    FitnessFeedView()
                } else if self.selected == 3 {
                    FitnessMyProfileProgressView()
                }
                Spacer()
                ZStack(alignment: .bottom) {
                    ATCTabBarBottomView(selected: self.$selected)
                        .padding()
                        .padding(.horizontal, 22)
                        .background(ATCCurvedShape())
                    Button(action: {
                        self.showSheetView.toggle()
                    }) {
                        Image("fitness-center-tabBar-icon")
                            .renderingMode(.original)
                    }.clipShape(Circle())
                        .offset(y: -32)
                        .shadow(radius: 5)
                        .padding(.bottom, -13)
                }
            }
        }.background(Color(appConfig.mainThemeBackgroundColor))
        .sheet(isPresented: $showSheetView) {
            FitnessCreatePostView(showSheetView: self.$showSheetView)
        }
    }
}
