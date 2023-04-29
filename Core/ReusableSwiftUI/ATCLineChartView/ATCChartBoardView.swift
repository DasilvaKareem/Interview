//
//  ATCChartBoardView.swift
//  FitnessApp
//
//  Copyright © 2020 iOSAppTemplates. All rights reserved.
//

import SwiftUI

struct ATCChartBoardView: View, AppConfigProtocol {
    @ObservedObject var data: ATCLineChartDataSource
    @Binding var frame: CGRect
    @Binding var hideHorizontalLines: Bool
    let padding:CGFloat = 3

    var stepWidth: CGFloat {
        if data.points.count < 2 {
            return 0
        }
        return frame.size.width / CGFloat(data.points.count - 1)
    }
    var stepHeight: CGFloat {
        let points = self.data.onlyPoints()
        if let min = points.min(), let max = points.max(), min != max {
            if (min < 0){
                return (frame.size.height-padding) / CGFloat(max - min)
            }else{
                return (frame.size.height-padding) / CGFloat(max + min)
            }
        }
        return 0
    }
    
    var min: CGFloat {
        let points = self.data.onlyPoints()
        return CGFloat(points.min() ?? 0)
    }
    
    var body: some View {
        ZStack(alignment: .topLeading){
            ForEach((0...4), id: \.self) { height in
                HStack(alignment: .center) {
                    Text("\(self.getYchartBoardSafe(height: height), specifier: "%.2f")")
                        .offset(x: 0, y: self.getYposition(height: height))
                        .foregroundColor(Color(self.appConfig.mainTextColor))
                        .font(.caption)
                    self.line(atHeight: self.getYchartBoardSafe(height: height), width: self.frame.width)
                        .stroke(Color.gray, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [5,height == 0 ? 0 : 10]))
                        .opacity((self.hideHorizontalLines && height != 0) ? 0 : 1)
                        .rotationEffect(.degrees(180), anchor: .center)
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                        .animation(.easeOut(duration: 0.2))
                        .clipped()
                }
            }
        }
    }
    
    func getYchartBoardSafe(height:Int)->CGFloat{
        if let chartBoard = getYchartBoard() {
            return CGFloat(chartBoard[height])
        }
        return 0
    }
    
    func getYposition(height: Int)-> CGFloat {
        if let chartBoard = getYchartBoard() {
            return (self.frame.height-((CGFloat(chartBoard[height]) - min)*self.stepHeight))-(self.frame.height/2)
        }
        return 0
       
    }
    
    func line(atHeight: CGFloat, width: CGFloat) -> Path {
        var hLine = Path()
        hLine.move(to: CGPoint(x:5, y: (atHeight-min)*stepHeight))
        hLine.addLine(to: CGPoint(x: width, y: (atHeight-min)*stepHeight))
        return hLine
    }
    
    func getYchartBoard() -> [Double]? {
        let points = self.data.onlyPoints()
        guard let max = points.max() else { return nil }
        guard let min = points.min() else { return nil }
        let step = Double(max - min)/4
        return [min+step * 0, min+step * 1, min+step * 2, min+step * 3, min+step * 4]
    }
}

struct chartBoard_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader{ geometry in
            ATCChartBoardView(data: ATCLineChartDataSource(points: [0.2,0.4,1.4,4.5]), frame: .constant(geometry.frame(in: .local)), hideHorizontalLines: .constant(false))
        }.frame(width: 320, height: 200)
    }
}
