//
//  ATCChatUserSelectionViewModel.swift
//  ChatApp
//
//  Created by Florian Marcu on 9/20/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit

class ATCChatUserSelectionViewModel: ATCGenericBaseModel {
    var description: String {
        return user.uid ?? ""
    }

    var isSelected: Bool
    var user: ATCUser

    init (user: ATCUser, selected: Bool) {
        self.user = user
        self.isSelected = selected
    }

    required init(jsonDict: [String: Any]) {
        fatalError()
    }

}
