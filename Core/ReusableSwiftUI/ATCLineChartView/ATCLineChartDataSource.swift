//
//  ATCLineChartDataSource.swift
//  FitnessApp
//
//  Copyright © 2020 iOSAppTemplates. All rights reserved.
//

import Foundation
import SwiftUI

public class ATCLineChartDataSource: ObservableObject, Identifiable {
    @Published var points: [(String,Double)]
    var valuesGiven: Bool = false
    var ID = UUID()
    
    public init<N: BinaryFloatingPoint>(points:[N]) {
        self.points = points.map{("", Double($0))}
    }
    public init<N: BinaryInteger>(values:[(String,N)]){
        self.points = values.map{($0.0, Double($0.1))}
        self.valuesGiven = true
    }
    public init<N: BinaryFloatingPoint>(values:[(String,N)]){
        self.points = values.map{($0.0, Double($0.1))}
        self.valuesGiven = true
    }
    public init<N: BinaryInteger>(numberValues:[(N,N)]){
        self.points = numberValues.map{(String($0.0), Double($0.1))}
        self.valuesGiven = true
    }
    public init<N: BinaryFloatingPoint & LosslessStringConvertible>(numberValues:[(N,N)]){
        self.points = numberValues.map{(String($0.0), Double($0.1))}
        self.valuesGiven = true
    }
    
    public func onlyPoints() -> [Double] {
        return self.points.map{ $0.1 }
    }
}

public class ChartStyle {
    public var backgroundColor: Color
    public var textColor: Color
    public var chartBoardTextColor: Color
    public var dropShadowColor: Color
    
    public init(backgroundColor: Color,
                textColor: Color,
                chartBoardTextColor: Color,
                dropShadowColor: Color) {
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.chartBoardTextColor = chartBoardTextColor
        self.dropShadowColor = dropShadowColor
    }
}
