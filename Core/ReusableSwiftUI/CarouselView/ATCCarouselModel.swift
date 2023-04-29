//
//  ATCCarouselModel.swift
//  DatingApp
//
//  Created by Duy Bui on 12/19/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import Foundation
protocol ATCCarouselModelProtocol {
    var id: Int { get }
    var image: String { get }
    var title: String { get }
    var description: String { get }
}

struct ATCCarouselModel: ATCCarouselModelProtocol {
    var id: Int
    var image: String
    var title: String
    var description: String
}
