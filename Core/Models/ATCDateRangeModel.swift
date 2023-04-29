//
//  ATCDateRangeModel.swift
//  DashboardApp
//
//  Created by Florian Marcu on 7/28/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit

struct ATCDateRange {
    var title: String
    var startDate: Date
    var endDate: Date
    var isCustomRange: Bool
}

class ATCDateRangeModel: ATCGenericBaseModel {
    var title: String
    var currentDateRange: ATCDateRange

    required init(jsonDict: [String: Any]) {
        title = ""
        currentDateRange = ranges[1]
    }

    var description: String {
        return title
    }

    init(title: String, dateRangeText: String) {
        self.title = title
        currentDateRange = ranges[1]
    }

    var timePeriodText: String {
        if currentDateRange.isCustomRange {
            let format = "MMM dd"
            return TimeFormatHelper.string(for: currentDateRange.startDate, format: format)
                + " - "
                + TimeFormatHelper.string(for: currentDateRange.endDate, format: format)
        }
        return currentDateRange.title
    }

    var titleText: String {
        return title
    }

    var ranges: [ATCDateRange] = [
        ATCDateRange(title: "Custom Range".localizedModels, startDate: Date(), endDate: Date(), isCustomRange: true),
        ATCDateRange(title: "Today".localizedModels, startDate: Date(), endDate: Date(), isCustomRange: false),
        ATCDateRange(title: "Yesterday".localizedModels, startDate: Date(), endDate: Date(), isCustomRange: false),
        ATCDateRange(title: "Last Week".localizedModels, startDate: Date(), endDate: Date(), isCustomRange: false),
        ATCDateRange(title: "This month".localizedModels, startDate: Date(), endDate: Date(), isCustomRange: false),
        ATCDateRange(title: "Last Month".localizedModels, startDate: Date(), endDate: Date(), isCustomRange: false),
        ATCDateRange(title: "Year to Date".localizedModels, startDate: Date(), endDate: Date(), isCustomRange: false),
        ATCDateRange(title: "Lifetime".localizedModels, startDate: Date(), endDate: Date(), isCustomRange: false),
    ]
}
