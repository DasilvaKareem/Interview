//
//  ATCSeparatorLineView.swift
//  FitnessApp
//
//  Copyright © 2020 iOSAppTemplates. All rights reserved.
//

import SwiftUI

struct ATCSeparatorHorizontalLineView: View {
    var body: some View {
        Rectangle()
            .fill(Color.gray).opacity(0.3)
            .frame(height: 0.5)
    }
}

struct ATCSeparatorVerticalLineView: View {
    var body: some View {
        Rectangle()
            .fill(Color.gray).opacity(0.3)
            .frame(width: 0.5)
    }
}
