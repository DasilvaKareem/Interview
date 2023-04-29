//
//  ATCSelectionView.swift
//  FitnessApp
//
//  Created by Duy Bui on 2/13/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import SwiftUI

struct ATCSelectionView: View {
    @Binding var isChecked: Bool
    let content: String
    
    var body: some View {
        VStack {
            ATCCheckboxView(isChecked: $isChecked,
                            content: content,
                            isCheckBoxRight: false)
        }
        .frame(height: 60, alignment: .center)
        .padding()
        .background(Color.white)
        .cornerRadius(20.0)
        .shadow(color: Color(UIColor(hexString: "#DCE6E6")), radius: 5.0, x: 3, y: 3)
    }
}
