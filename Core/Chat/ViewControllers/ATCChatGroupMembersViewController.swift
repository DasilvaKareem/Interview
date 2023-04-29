//
//  ATCChatGroupMembersViewController.swift
//  ChatApp
//
//  Created by Mac  on 05/02/20.
//  Copyright © 2020 Instamobile. All rights reserved.
//

import UIKit

class ATCChatGroupMembersViewController: UIViewController {

    @IBOutlet weak var groupMembersTableView: UITableView!

    var user: ATCUser
    var recipients: [ATCUser]
    var channel: ATCChatChannel
    let uiConfig: ATCUIGenericConfigurationProtocol
    let reportingManager: ATCUserReportingProtocol?
    let chatServiceConfig: ATCChatServiceConfigProtocol
    var groupMemberViewer: [ATCUser]
    
    var isAdmin: Bool = false

    private let groupMembersCellClass = ATCChatGroupMembersTableViewCell.self

    init(user: ATCUser, recipients: [ATCUser], channel: ATCChatChannel, uiConfig: ATCUIGenericConfigurationProtocol, reportingManager: ATCUserReportingProtocol?, chatServiceConfig: ATCChatServiceConfigProtocol) {
        self.user = user
        isAdmin = recipients.filter { $0.uid == user.uid }.first?.isAdmin ?? false
        self.recipients = recipients.filter{ $0.uid != user.uid }
        self.groupMemberViewer = recipients.filter{ $0.uid == user.uid }
        self.channel = channel
        self.uiConfig = uiConfig
        self.reportingManager = reportingManager
        self.chatServiceConfig = chatServiceConfig
        super.init(nibName: "ATCChatGroupMembersViewController", bundle: nil)
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        groupMembersTableView.delegate = self
        groupMembersTableView.dataSource = self
        
        self.title = "View Group Members"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))

        let cellNib = UINib(nibName: String(describing: groupMembersCellClass), bundle: nil)
        groupMembersTableView.register(cellNib,
                                           forCellReuseIdentifier: String(describing: groupMembersCellClass))
        NotificationCenter.default.addObserver(self, selector: #selector(observerAddedGroupMember(_:)),name: kATCAddedGroupMemberNotification, object: nil)
        
        groupMembersTableView.tableFooterView = UIView(frame: .zero)
    }
    
    @objc func observerAddedGroupMember(_ notification: Notification) {
        let responseData = notification.userInfo
        if let recipients = responseData?["recipients"] as? [ATCUser] {
            self.recipients = recipients
            self.recipients = recipients.filter{ $0.uid != user.uid }
            self.groupMembersTableView.reloadData()
        }
    }

    @objc fileprivate func didTapAdd() {
        self.recipients.append(contentsOf: self.groupMemberViewer)
        let vc = ATCChatGroupUpdateViewController(uiConfig: uiConfig,
                                                    selectionBlock: nil,
                                                    viewer: user,
                                                    chatServiceConfig: chatServiceConfig,
                                                    reportingManager: reportingManager,
                                                    channel: channel,
                                                    recipients: recipients)
        vc.title = "Choose People"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension ATCChatGroupMembersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: groupMembersCellClass), for: indexPath) as? ATCChatGroupMembersTableViewCell else {
            return tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        }
        cell.configureCell(user: recipients[indexPath.row], isAdmin: self.isAdmin)
        cell.delegate = self
        return cell
    }
}

extension ATCChatGroupMembersViewController: ChatGroupMembersCellDelegate {

    func moreActionPressed(cell: ATCChatGroupMembersTableViewCell, otherUser: ATCUser) {
        let alert = UIAlertController(title: "Member Settings".localizedChat, message: "", preferredStyle: UIAlertController.Style.actionSheet)
        if otherUser.isAdmin {
            alert.addAction(UIAlertAction(title: "Remove Admin".localizedChat, style: .default, handler: {[weak self] (action) in
                guard let strongSelf = self else { return }
                ATCChatFirebaseManager.updateGroupMemberRole(isAdmin: false, channel: strongSelf.channel, user: otherUser)
                strongSelf.recipients.filter{ $0.uid == otherUser.uid }.first?.isAdmin = false
                strongSelf.groupMembersTableView.reloadData()
            }))
        } else {
            alert.addAction(UIAlertAction(title: "Make Admin".localizedChat, style: .default, handler: {[weak self] (action) in
                guard let strongSelf = self else { return }
                ATCChatFirebaseManager.updateGroupMemberRole(isAdmin: true, channel: strongSelf.channel, user: otherUser)
                strongSelf.recipients.filter{ $0.uid == otherUser.uid }.first?.isAdmin = true
                strongSelf.groupMembersTableView.reloadData()
            }))
        }
        alert.addAction(UIAlertAction(title: "Remove Member".localizedChat, style: .destructive, handler: {[weak self] (action) in
            guard let strongSelf = self else { return }
            ATCChatFirebaseManager.removeGroupMember(channel: strongSelf.channel, user: otherUser)
            strongSelf.recipients = strongSelf.recipients.filter{ $0.uid != otherUser.uid }
            strongSelf.recipients.append(contentsOf: strongSelf.groupMemberViewer)
            NotificationCenter.default.post(name: kATCAddedGroupMemberNotification, object: nil, userInfo: ["recipients": strongSelf.recipients])
            strongSelf.groupMembersTableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localizedCore, style: .cancel, handler: nil))
        if let popoverPresentationController = alert.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = self.view.bounds
        }
        self.present(alert, animated: true)
    }
}
