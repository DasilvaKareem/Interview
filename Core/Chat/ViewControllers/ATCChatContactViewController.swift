//
//  ATCChatContactViewController.swift
//  ChatApp
//
//  Created by Osama Naeem on 28/05/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCChatContactViewController: QuickTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableContents = [
            Section(title: "Contact".localizedCore, rows: [
                NavigationRow(text: "Our address".localizedCore, detailText: .subtitle("1412 Steiner Street, San Fracisco, CA, 94115"), icon: .named("globe")),
                NavigationRow(text: "E-mail us".localizedCore, detailText: .value1("office@iosapptemplates.com"), icon: .named("time"), action: { (row) in
                    guard let email = URL(string: "mailto:office@iosapptemplates.com") else { return }
                    UIApplication.shared.open(email)
                })
                ], footer: "Our business hours are Mon - Fri, 10am - 5pm, PST."),
            Section(title: "", rows: [
                TapActionRow(text: "Call Us".localizedCore, action: { (row) in
                    guard let number = URL(string: "tel://6504859694") else { return }
                    UIApplication.shared.open(number)
                })
                ]),
        ]
        
        self.title = "Contact Us".localizedCore
    }
    
    // MARK: - Actions
    private func showAlert(_ sender: Row) {
        // ...
    }
    
    private func didToggleSelection() -> (Row) -> Void {
        return { row in
            // ...
        }
    }
}
