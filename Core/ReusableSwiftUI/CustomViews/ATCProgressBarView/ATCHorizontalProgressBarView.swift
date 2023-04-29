//
//  ATCProgressBarView.swift
//  FitnessApp
//
//  Copyright © 2020 iOSAppTemplates. All rights reserved.
//

import SwiftUI

struct ATCHorizontalProgressBarView: View, AppConfigProtocol {
    @State var isShowing = false
    @Binding var progress: CGFloat
    private let width: CGFloat = 250.0
    private let height: CGFloat = 5.0
    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .foregroundColor(Color.gray)
                .opacity(0.3)
                .frame(width: width, height: height)
            Rectangle()
                .foregroundColor(Color(appConfig.mainThemeForegroundColor))
                .frame(width: self.isShowing ? width * (self.progress / 100.0) : 0.0, height: height)
                .animation(.linear(duration: 0.6))
        }
        .onAppear {
            self.isShowing = true
        }
        .cornerRadius(10.0)
    }
}

#if DEBUG
struct HorizontalProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        ATCHorizontalProgressBarView(progress: .constant(25.0))
    }
}
#endif
