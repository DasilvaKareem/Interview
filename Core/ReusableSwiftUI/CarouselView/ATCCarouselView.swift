//
//  ATCCarouselView.swift
//  App Onboarding
//
//  Created by Duy Bui on 12/15/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import SwiftUI

struct ATCCarouselView: View {
    var pages: [UIViewController]
    var titles: [String]
    var descriptions: [String]
    var currentPageTintColor: UIColor
    
    init(data: [ATCCarouselModelProtocol], currentPageTintColor: UIColor) {
        self.pages = data.map { UIHostingController(rootView: ATCPageView(image: $0.image)) }
        self.titles = data.map { $0.title }
        self.descriptions = data.map { $0.description }
        self.currentPageTintColor = currentPageTintColor
    }
    
    @State var currentPageIndex = 0
    
    var body: some View {
        VStack {
            VStack(alignment: .center) {
                ATCPageViewController(currentPageIndex: $currentPageIndex, viewControllers: pages)
                    .frame(height: 200)
                ATCPageControlView(numberOfPages: pages.count,
                                         currentPageTintColor: currentPageTintColor,
                                         currentPageIndex: $currentPageIndex)
                VStack(alignment: .center, spacing: 5) {
                    Text(titles[currentPageIndex])
                        .font(.title)
                    Text(descriptions[currentPageIndex])
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                }
                .padding(.top, -10)
                .padding(.horizontal)
            }
        }
    }
}

struct ButtonContent: View {
    var body: some View {
        Image(systemName: "arrow.right")
            .resizable()
            .foregroundColor(.white)
            .frame(width: 30, height: 30)
            .padding()
            .background(Color.orange)
            .cornerRadius(30)
    }
}
