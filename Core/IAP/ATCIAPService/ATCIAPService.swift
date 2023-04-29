//
//  ATCIAPService.swift
//  DatingApp
//
//  Copyright © 2020 Instamobile. All rights reserved.
//

import Foundation
import StoreKit

class ATCIAPService: NSObject {
    private override init() {}
    static let shared = ATCIAPService()
    
    enum ATCInAppPurchaseError: Error {
        case cancelled
        case requestFailed
        case productIDNotFound
        case emptyProductLists
    }
    
    var loadProductsCompletion: ((Result<[SKProduct], ATCInAppPurchaseError>) -> Void)?
    var purchaseProductCompletion: ((Result<Bool, Error>) -> Void)?
    
    var skProducts = [SKProduct]()
    let paymentQueue = SKPaymentQueue.default()
    
    func getProducts(_ completion: @escaping (Result<[SKProduct], ATCInAppPurchaseError>) -> Void = { _ in }) {
        loadProductsCompletion = completion
        
        let requestedProducts: [ATCIAPProduct] = [.autoRenewableSubscription,
                                                                          .autoRenewableSubscriptionByYear,
                                                                          .freeTrialAutoRenewableSubscription,
                                                                          .freeTrialAutoRenewableSubscriptionByYear]
        
        guard !requestedProducts.isEmpty else {
            completion(.failure(.emptyProductLists))
            return
        }
        
        
        let request = SKProductsRequest(productIdentifiers: Set(requestedProducts.compactMap { $0.content }))
        request.delegate = self
        request.start()
    }
    
    func purchase(product: ATCIAPProduct, _ completion : @escaping ((_ result: Result<Bool, Error>) -> Void)) {
        purchaseProductCompletion = completion
        guard let productToPurchase = skProducts.filter({ $0.productIdentifier == product.content }).first else { return }
        let payment = SKPayment(product: productToPurchase)
        paymentQueue.add(payment)
    }
    
    func startObserving() {
        paymentQueue.add(self)
    }
    
    func stopObserving() {
        paymentQueue.remove(self)
    }
    
    func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
}

extension ATCIAPService: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        skProducts = response.products
        if skProducts.count > 0 {
            loadProductsCompletion?(.success(skProducts))
        } else {
            loadProductsCompletion?(.failure(.emptyProductLists))
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        loadProductsCompletion?(.failure(.requestFailed))
    }
}

extension ATCIAPService: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach { (transaction) in
            switch transaction.transactionState {
                case .purchased:
                    purchaseProductCompletion?(.success(true))
                    SKPaymentQueue.default().finishTransaction(transaction)
                case .restored:
                    break
                case .failed:
                    if let error = transaction.error as? SKError {
                        if error.code != .paymentCancelled {
                            purchaseProductCompletion?(.failure(error))
                        } else {
                            purchaseProductCompletion?(.failure(ATCInAppPurchaseError.cancelled))
                        }
                        print("IAP Error:", error.localizedDescription)
                    }
                    SKPaymentQueue.default().finishTransaction(transaction)
                case .deferred, .purchasing: break
            @unknown default: break
            }
        }
    }
}


extension ATCIAPService.ATCInAppPurchaseError: LocalizedError {
    var errorIAPDescription: String {
        switch self {
            case .productIDNotFound: return "No In-App Purchase product identifiers were found."
            case .emptyProductLists: return "There is no In-App Purchases currently."
            case .requestFailed: return "Unable to fetch available In-App Purchase products at the moment."
            case .cancelled: return "In-App Purchase process was cancelled."
        }
    }
}
