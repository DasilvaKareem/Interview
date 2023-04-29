//
//  ATCGridView.swift
//  FitnessApp
//
//  Created by Duy Bui on 1/20/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import SwiftUI

struct ATCGridView<Content: View>: View {
    private let rows: Int
    private let horizontalAlignment: HorizontalAlignment
    private let rowSpacing: CGFloat?
    private let columns: Int
    private let verticalAlignment: VerticalAlignment
    private let columnSpacing: CGFloat?
    private let content: (Int, Int) -> Content
    
    init(rows: Int,
         columns: Int,
         horizontalAlignment: HorizontalAlignment = .center,
         verticalAlignment: VerticalAlignment = .center,
         rowSpacing: CGFloat?,
         columnSpacing: CGFloat?,
         @ViewBuilder content: @escaping (Int, Int) -> Content) {
        self.rows = rows
        self.columns = columns
        self.content = content
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment
        self.columnSpacing = columnSpacing
        self.rowSpacing = rowSpacing
    }
    
    var body: some View {
        VStack(alignment: horizontalAlignment, spacing: rowSpacing) {
            ForEach(0 ..< rows) { row in
                HStack(alignment: self.verticalAlignment, spacing: self.columnSpacing) {
                    ForEach(0 ..< self.columns) { column in
                        self.content(row, column)
                    }
                }
            }
        }
    }
}
