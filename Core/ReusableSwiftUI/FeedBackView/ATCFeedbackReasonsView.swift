//
//  ATCFeedbackReasonsView.swift
//  FitnessApp
//
//  Copyright © 2020 iOSAppTemplates. All rights reserved.
//
import SwiftUI

struct ATCFeedbackReasonsView: View, AppConfigProtocol {

    private let reasons = ["Slow loading", "Customer service", "App crash", "Navigation", "Not responsive", "Not functional"]
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Rectangle()
                .fill(Color.gray.opacity(0.5))
                .frame(height: 1)
            Text("What is wrong?")
                .modifier(ATCTextModifier(font: appConfig.mediumBoldFont,
                                          color: .black))
            ATCGridView(rows: 3, columns: 2, horizontalAlignment: .leading, rowSpacing: 12, columnSpacing: 12) { row, col in
                ATCFeedbackReasonView(title: self.reasons[row * 2 + col])
            }
        }
    }
}
