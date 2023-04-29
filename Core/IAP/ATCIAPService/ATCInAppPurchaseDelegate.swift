//
//  ATCInAppPurchaseDelegate.swift
//  DatingApp
//
//  Created by Duy Bui on 5/24/20.
//  Copyright © 2020 Instamobile. All rights reserved.
//

import UIKit

protocol ATCInAppPurchaseDelegate {
    func purchaseProduct(with selectedSubscription: ATCSubscription?,
                         completionHandler: @escaping (Error?) -> Void)
}

extension ATCInAppPurchaseDelegate {
    func purchaseProduct(with selectedSubscription: ATCSubscription?,
                         completionHandler: @escaping (Error?) -> Void) {
        guard let selectedSubscription = selectedSubscription, ATCIAPService.shared.canMakePayments() else {
            completionHandler(ATCIAPService.ATCInAppPurchaseError.productIDNotFound)
            return
        }
        
        ATCIAPService.shared.purchase(product: selectedSubscription.type) { result in
            switch result {
            case .success(_):
                completionHandler(nil)
            case .failure(let error):
                completionHandler(error)
            }
        }
    }
}
