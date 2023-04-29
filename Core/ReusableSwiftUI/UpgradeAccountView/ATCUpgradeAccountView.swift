//
//  ATCUpgradeAccountViewController.swift
//  DatingApp
//
//  Created by Duy Bui on 12/15/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import SwiftUI
import UIKit

protocol ATCUpgradeAccountDelegate: class {
    func didFinishSubscription(with selectedSubscription: ATCSubscription?, completionHandler: @escaping (Error?) -> Void)
}

class ATCUpgradeAccountViewController: UIViewController {
    let appConfig: ATCUpgradeAccountConfigurationUIProtocol
    let uiConfig: ATCUIGenericConfigurationProtocol
    weak var delegate: ATCUpgradeAccountDelegate?
    let frame = CGRect(x: 0,
                       y: 0,
                       width: Int(UIScreen.main.bounds.width),
                       height: Int(UIScreen.main.bounds.height))
    init(appConfig: ATCUpgradeAccountConfigurationUIProtocol,
         uiConfig: ATCUIGenericConfigurationProtocol) {
        self.appConfig = appConfig
        self.uiConfig = uiConfig
        super.init(nibName: nil, bundle:nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let view = UIView()
        view.frame = frame
        self.view = view
        
        let controller = UIHostingController(rootView: ATCUpgradeAccountView(appConfig: appConfig,
                                                                             uiConfig: uiConfig,
                                                                             subscriptionAction: subscriptionAction))
        controller.view.frame = frame
        
        self.view.addSubview(controller.view)
        ATCIAPService.shared.getProducts()
    }
    
    func subscriptionAction(selectedSubscription: ATCSubscription?) {
        delegate?.didFinishSubscription(with: selectedSubscription) { [weak self] error in
            if error == nil {
                self?.dismiss(animated: true, completion: nil)
            } else {
                var message: String = ""
                if let error = error as? ATCIAPService.ATCInAppPurchaseError {
                    message = error.errorIAPDescription
                } else {
                    message = "There was an issue while updating the profile. Please try again."
                }
                let alert = UIAlertController(title: "Error",
                                              message: message,
                                              preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(alert, animated: true)
            }
        }
    }
}

struct ATCUpgradeAccountView: View {
    let appConfig: ATCUpgradeAccountConfigurationUIProtocol
    let uiConfig: ATCUIGenericConfigurationProtocol
    let subscriptionAction: (ATCSubscription?) -> Void
    @State var selectedSubscription: ATCSubscription?
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 60.0) {
                ATCCarouselView(data: appConfig.carouselData,
                                currentPageTintColor: uiConfig.mainThemeForegroundColor)
                ATCUpgradeAccountConsumerTypesView(selectedSubscription: $selectedSubscription,
                                                   appConfig: appConfig,
                                                   uiConfig: uiConfig) {
                                                    self.subscriptionAction(self.appConfig.freeTrialSubscription)
                }
                ATCUpgradeAccountBottomView(selectedSubscription: $selectedSubscription,
                                            uiConfig: uiConfig) {
                                                self.subscriptionAction(self.selectedSubscription)
                }
            }.padding(.bottom, 20)
        }
    }
}
