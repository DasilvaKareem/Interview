//
//  ATCContactsViewController.swift
//  ChatApp
//
//  Created by Osama Naeem on 20/05/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCContactsViewController: ATCGenericCollectionViewController {
    
    let friendsDataSource: ATCGenericCollectionViewControllerDataSource
    var viewer: ATCUser? = nil
    let uiConfig: ATCUIGenericConfigurationProtocol

    init(configuration: ATCGenericCollectionViewControllerConfiguration,
         uiConfig: ATCUIGenericConfigurationProtocol,
          selectionBlock: ATCollectionViewSelectionBlock?,
         dataSource: ATCGenericCollectionViewControllerDataSource) {
        self.uiConfig = uiConfig
        self.friendsDataSource = dataSource

        super.init(configuration: configuration, selectionBlock: selectionBlock)
       // self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector())
       // self.title = "Contacts"
    }

    static func contactsVC(uiConfig: ATCUIGenericConfigurationProtocol,
                       friendsDataSource: ATCGenericCollectionViewControllerDataSource) -> ATCContactsViewController {
        let collectionVCConfiguration = ATCGenericCollectionViewControllerConfiguration(
            pullToRefreshEnabled: false,
            pullToRefreshTintColor: uiConfig.mainThemeBackgroundColor,
            collectionViewBackgroundColor: uiConfig.mainThemeBackgroundColor,
            collectionViewLayout: ATCLiquidCollectionViewLayout(),
            collectionPagingEnabled: false,
            hideScrollIndicators: false,
            hidesNavigationBar: false,
            headerNibName: nil,
            scrollEnabled: true,
            uiConfig: uiConfig,
            emptyViewModel: nil
        )

        let contactVC = ATCContactsViewController(configuration: collectionVCConfiguration, uiConfig: uiConfig, selectionBlock: { (navController, object, indexPath) in
        }, dataSource: friendsDataSource)
        
        return contactVC
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
