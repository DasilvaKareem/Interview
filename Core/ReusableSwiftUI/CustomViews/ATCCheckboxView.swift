//
//  ATCCheckboxView.swift
//  FitnessApp
//
//  Created by Duy Bui on 2/13/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import SwiftUI

struct ATCCheckboxView: View {
    @Binding var isChecked: Bool
    let content: String
    let isCheckBoxRight: Bool
    
    var body: some View {
        VStack {
            Spacer()
            HStack(alignment: .center) {
                Button(action: {
                    self.isChecked.toggle()
                }) {
                    HStack {
                        if isCheckBoxRight {
                            Text(content).foregroundColor(Color.black)
                            Spacer()
                            Image(isChecked ? "fitness-selected-icon": "dating-empty-circle-icon")
                            .scaledToFit()
                        } else {
                            Image(isChecked ? "fitness-selected-icon": "dating-empty-circle-icon")
                            .scaledToFit()
                            Text(content).foregroundColor(Color.black)
                        }
                    }
                }.buttonStyle(PlainButtonStyle())
                Spacer()
            }
            Spacer()
        }
    }
}
