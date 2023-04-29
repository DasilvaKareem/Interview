//
//  ATCPageControlView.swift
//  App Onboarding
//
//  Created by Duy Bui on 12/15/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

struct ATCPageControlView: UIViewRepresentable {
    var numberOfPages: Int
    let currentPageTintColor: UIColor
    @Binding var currentPageIndex: Int
    
    func makeUIView(context: Context) -> UIPageControl {
        let control = UIPageControl()
        control.numberOfPages = numberOfPages
        control.currentPageIndicatorTintColor = currentPageTintColor
        control.pageIndicatorTintColor = UIColor.gray
        return control
    }
    
    func updateUIView(_ uiView: UIPageControl, context: Context) {
        uiView.currentPage = currentPageIndex
    }
    
}
