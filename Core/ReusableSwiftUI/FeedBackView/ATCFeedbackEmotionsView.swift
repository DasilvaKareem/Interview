//
//  ATCFeedbackEmotionsView.swift
//  FitnessApp
//
//  Copyright © 2020 iOSAppTemplates. All rights reserved.
//

import SwiftUI

struct ATCFeedbackEmotionsView: View, AppConfigProtocol {
    
    // MARK: - Private properties
    private let unSelectedEmotionalIcon = ["angry-icon-gray", "cry-icon-gray", "neutral-icon-gray", "smile-icon-gray", "happy-icon-gray"]
    private let selectedEmotionalIcon = ["angry-icon-color", "cry-icon-color", "neutral-icon-color", "smile-icon-color", "happy-icon-color"]
    private let feedBackTitles = ["Too Bad", "Not So Good", "Fine", "So Good", "Awesome"]
    
    @Binding var isSelected: Int?
    @State private var isLowestOptionSelected: Bool = false
    @State private var isLowOptionSelected: Bool = false
    @State private var isNormalOptionSelected: Bool = false
    @State private var isHighOptionSelected: Bool = false
    @State private var isHighestOptionSelected: Bool = false
    
    var body: some View {
        VStack {
            HStack(spacing: 18.5) {
                ATCFeedbackEmotionView(unSelectedImage: unSelectedEmotionalIcon[0],
                                         selectedImage: selectedEmotionalIcon[0],
                                         isSelected: $isLowestOptionSelected) {
                                            if self.isLowestOptionSelected {
                                                self.isLowOptionSelected = false
                                                self.isNormalOptionSelected = false
                                                self.isHighOptionSelected = false
                                                self.isHighestOptionSelected = false
                                                self.isSelected = 0
                                            }
                                            self.clearData()
                }
                
                ATCFeedbackEmotionView(unSelectedImage: unSelectedEmotionalIcon[1],
                selectedImage: selectedEmotionalIcon[1],
                isSelected: $isLowOptionSelected) {
                                                       if self.isLowOptionSelected {
                                                           self.isLowestOptionSelected = false
                                                           self.isNormalOptionSelected = false
                                                           self.isHighOptionSelected = false
                                                           self.isHighestOptionSelected = false
                                                           self.isSelected = 1
                                                       }
                                                       self.clearData()
                           }
                
                ATCFeedbackEmotionView(unSelectedImage: unSelectedEmotionalIcon[2],
                selectedImage: selectedEmotionalIcon[2],
                isSelected: $isNormalOptionSelected) {
                                            if self.isNormalOptionSelected {
                                                self.isLowestOptionSelected = false
                                                self.isLowOptionSelected = false
                                                self.isHighOptionSelected = false
                                                self.isHighestOptionSelected = false
                                                self.isSelected = 2
                                            }
                                            self.clearData()
                }
                
                ATCFeedbackEmotionView(unSelectedImage: unSelectedEmotionalIcon[3],
                selectedImage: selectedEmotionalIcon[3],
                isSelected: $isHighOptionSelected) {
                                            if self.isHighOptionSelected {
                                                self.isLowestOptionSelected = false
                                                self.isLowOptionSelected = false
                                                self.isNormalOptionSelected = false
                                                self.isHighestOptionSelected = false
                                                self.isSelected = 3
                                            }
                                            self.clearData()
                }
                
                ATCFeedbackEmotionView(unSelectedImage: unSelectedEmotionalIcon[4],
                selectedImage: selectedEmotionalIcon[4],
                isSelected: $isHighestOptionSelected) {
                                            if self.isHighestOptionSelected {
                                                self.isLowestOptionSelected = false
                                                self.isLowOptionSelected = false
                                                self.isNormalOptionSelected = false
                                                self.isHighOptionSelected = false
                                                self.isSelected = 4
                                            }
                                            self.clearData()
                }
            }.padding()
            Text(feedBackTitles[safeIndex: isSelected ?? 5] ?? "")
                .modifier(ATCTextModifier(font: appConfig.boldLargeFont,
                                          color: .black))
                .frame(width: 277,
                       alignment: .center)
        }
    }
    
    private func clearData() {
        if !isLowestOptionSelected && !isLowOptionSelected && !isNormalOptionSelected  && !isHighOptionSelected && !isHighestOptionSelected {
            self.isSelected = nil
        }
    }
    
    private func clearOtherOptions(except index: Int) {
        let options = [isLowestOptionSelected, isLowOptionSelected, isNormalOptionSelected, isHighOptionSelected, isHighestOptionSelected]
        _ = options.indices.filter { $0 != index}.compactMap { options[$0] == false }
    }
}
