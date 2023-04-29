//
//  ATCPageView.swift
//  App Onboarding
//
//  Created by Duy Bui on 12/15/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import SwiftUI

struct ATCPageView: View {
    
    var image: String
    
    var body: some View {
        Image(image)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .background(Color.clear)
    }
}
