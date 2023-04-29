//
//  ATCVerticalProgressBarView.swift
//  FitnessApp
//
//  Copyright © 2020 iOSAppTemplates. All rights reserved.
//

import SwiftUI

struct ATCVerticalProgressBarView: View, AppConfigProtocol {
    @State var isShowing = false
    @Binding var progress: CGFloat
    private let width: CGFloat = 10.0
    private let height: CGFloat = 30.0
    var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .foregroundColor(Color.gray)
                .opacity(0.3)
                .frame(width: width, height: height)
            Rectangle()
                .foregroundColor(Color(appConfig.mainThemeForegroundColor))
                .frame(width: width, height: self.isShowing ? height * (self.progress / 100.0) : 0.0)
                .animation(.linear(duration: 0.6))
        }
        .onAppear {
            self.isShowing = true
        }
        .cornerRadius(10.0)
    }
}

#if DEBUG
struct VerticalProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        ATCVerticalProgressBarView(progress: .constant(25.0))
    }
}
#endif
