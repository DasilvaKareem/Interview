//
//  ATCLineChartView.swift
//  FitnessApp
//
//  Copyright © 2020 iOSAppTemplates. All rights reserved.
//

import SwiftUI

public struct ATCLineChartView: View, AppConfigProtocol {
    @ObservedObject var data: ATCLineChartDataSource
    public var title: String?
    public var chartBoard: String?
    public var style: ChartStyle
    public var valueSpecifier:String
    
    @State private var showchartBoard = false
    @State private var dragLocation:CGPoint = .zero
    @State private var indicatorLocation:CGPoint = .zero
    @State private var closestPoint: CGPoint = .zero
    @State private var opacity:Double = 0
    @State private var currentDataNumber: Double = 0
    @State private var hideHorizontalLines: Bool = false
    
    public init(data: [Double],
                title: String? = nil,
                chartBoard: String? = nil,
                style: ChartStyle,
                valueSpecifier: String? = "%.1f") {
        
        self.data = ATCLineChartDataSource(points: data)
        self.title = title
        self.chartBoard = chartBoard
        self.style = style
        self.valueSpecifier = valueSpecifier!
    }
    
    public var body: some View {
        GeometryReader{ geometry in
            VStack(alignment: .leading, spacing: 8) {
                Group{
                    if (self.title != nil) {
                        Text(self.title!)
                            .font(.title)
                            .bold()
                            .foregroundColor(self.style.textColor)
                    }
                    if (self.chartBoard != nil){
                        Text(self.chartBoard!)
                            .font(.callout)
                            .foregroundColor(self.style.chartBoardTextColor)
                    }
                }.offset(x: 0, y: 20)
                ZStack{
                    GeometryReader{ reader in
                        Rectangle()
                            .foregroundColor(self.style.backgroundColor)
                        if(self.showchartBoard){
                            ATCChartBoardView(data: self.data,
                                           frame: .constant(reader.frame(in: .local)), hideHorizontalLines: self.$hideHorizontalLines)
                                .transition(.opacity)
                                .animation(Animation.easeOut(duration: 1).delay(1))
                        }
                        ATCLineChartLineProgress(data: self.data,
                             frame: .constant(CGRect(x: 0, y: 0, width: reader.frame(in: .local).width - 30, height: reader.frame(in: .local).height)),
                             touchLocation: self.$indicatorLocation,
                             showIndicator: self.$hideHorizontalLines,
                             minDataValue: .constant(nil),
                             maxDataValue: .constant(nil),
                             showBackground: false
                        )
                            .offset(x: 30, y: 0)
                            .onAppear() {
                                self.showchartBoard = true
                        }
                        .onDisappear(){
                            self.showchartBoard = false
                        }
                    }
                    .frame(width: geometry.frame(in: .local).size.width, height: 240)
                    .offset(x: 0, y: 40)
                    ATCMagnifierRectView(currentNumber: self.$currentDataNumber, valueSpecifier: self.valueSpecifier)
                        .opacity(self.opacity)
                        .offset(x: self.dragLocation.x - geometry.frame(in: .local).size.width/2, y: 36)
                }
                .frame(width: geometry.frame(in: .local).size.width, height: 240)
                .gesture(DragGesture()
                .onChanged({ value in
                    self.dragLocation = value.location
                    self.indicatorLocation = CGPoint(x: max(value.location.x-30,0), y: 32)
                    self.opacity = 1
                    self.closestPoint = self.getClosestDataPoint(toPoint: value.location, width: geometry.frame(in: .local).size.width-30, height: 240)
                    self.hideHorizontalLines = true
                })
                    .onEnded({ value in
                        self.opacity = 0
                        self.hideHorizontalLines = false
                    })
                )
            }
        }
    }
    
    func getClosestDataPoint(toPoint: CGPoint, width:CGFloat, height: CGFloat) -> CGPoint {
        let points = self.data.onlyPoints()
        let stepWidth: CGFloat = width / CGFloat(points.count-1)
        let stepHeight: CGFloat = height / CGFloat(points.max()! + points.min()!)
        
        let index:Int = Int(floor((toPoint.x-15)/stepWidth))
        if (index >= 0 && index < points.count){
            self.currentDataNumber = points[index]
            return CGPoint(x: CGFloat(index)*stepWidth, y: CGFloat(points[index])*stepHeight)
        }
        return .zero
    }
}

struct LineView_Previews: PreviewProvider {
    static var previews: some View {
        ATCLineChartView(data: [18,23,54,32,12,37,17,23,43],
                 title: "Full chart",
                 style: ChartStyle(backgroundColor: Color.white,
                                   textColor: Color.black,
                                   chartBoardTextColor: Color.gray,
                                   dropShadowColor: Color.gray))
    }
}

