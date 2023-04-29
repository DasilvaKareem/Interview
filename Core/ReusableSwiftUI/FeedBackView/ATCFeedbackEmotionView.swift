//
//  ATCFeedbackEmotionView.swift
//  FitnessApp
//
//  Copyright © 2020 iOSAppTemplates. All rights reserved.
//

import SwiftUI

struct ATCFeedbackEmotionView: View, AppConfigProtocol {
    let unSelectedImage: String
    let selectedImage: String
    @Binding var isSelected: Bool
    let completionHandler: () -> ()
    
    var body: some View {
        Button(action: {
            self.isSelected.toggle()
            self.completionHandler()
        }) {
            Image(isSelected ? selectedImage : unSelectedImage)
        }.buttonStyle(PlainButtonStyle())
    }
}
