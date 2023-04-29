//
//  ATCImageView.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 15/06/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCImageView : UIImageView {
    
    // Reactions Identifier
    var imageIdentifier: String = ""
    
    func fetchIdentifier() -> String {
        return self.imageIdentifier
    }
}
