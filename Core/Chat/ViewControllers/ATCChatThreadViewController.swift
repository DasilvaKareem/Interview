//
//  ATCChatThreadViewController.swift
//  ChatApp
//
//  Created by Florian Marcu on 8/26/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit
import Photos
import Firebase
import FirebaseFirestore
import FirebaseStorage
import AVKit
import AVFoundation

protocol ATCChatUIConfigurationProtocol {
    var primaryColor: UIColor {get}
    var backgroundColor: UIColor {get}
    var inputTextViewBgColor: UIColor {get}
    var inputTextViewTextColor: UIColor {get}
    var inputPlaceholderTextColor: UIColor {get}
    var fontAudioTimerLabel: UIFont {get}
    var audioTimerTextColor: UIColor {get}
    var defaultATCUIGenericConfigurationProtocol: ATCUIGenericConfigurationProtocol {get}
    init(uiConfig: ATCUIGenericConfigurationProtocol)
}

protocol ATCChatAudioRecordingProtocol {
    func startAudioRecord()
    func sendAudioRecord()
    func cancelAudioRecord()
}

protocol ATCChatServiceConfigProtocol {
    var isAudioMessagesEnabled: Bool {get}
    var emptyViewTitleButton: String {get}
    var emptyViewDescription: String {get}
    var isTypingIndicatorEnabled: Bool {get}
    var showOnlineStatus: Bool {get}
    var showLastSeen: Bool {get}
}

struct kAudioRecordingConfig {
    static let kAudioMessageTimeLimit: TimeInterval = 59.0
}

struct kTypingIndicatorConfig {
    static let kTypingIndicatorThresholdInSeconds: Int = 20
}

struct seenStatusConfig {
    static let seenStatusMessageID = "seenStatusMessageID"
}

class ATCChatUIConfiguration: ATCChatUIConfigurationProtocol {
    let primaryColor: UIColor
    let backgroundColor: UIColor
    let inputTextViewBgColor: UIColor = {
        if #available(iOS 13.0, *) {
            return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                switch traitCollection.userInterfaceStyle {
                    case
                    .unspecified,
                    .light: return UIColor(hexString: "#f4f4f6")
                    case .dark: return UIColor(hexString: "#0b0b09")
                    @unknown default:
                        return .white
                }
            }
        } else {
            return UIColor(hexString: "#f4f4f6")
        }
    }()

    let inputTextViewTextColor: UIColor
    let fontAudioTimerLabel: UIFont
    let audioTimerTextColor: UIColor
    
    let inputPlaceholderTextColor: UIColor = {
        if #available(iOS 13.0, *) {
            return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                switch traitCollection.userInterfaceStyle {
                    case
                    .unspecified,
                    .light: return UIColor(hexString: "#979797")
                    case .dark: return UIColor(hexString: "#686868")
                    @unknown default:
                        return .white
                }
            }
        } else {
            return UIColor(hexString: "#979797")
        }
    }()

    var defaultATCUIGenericConfigurationProtocol: ATCUIGenericConfigurationProtocol
    
    required init(uiConfig: ATCUIGenericConfigurationProtocol) {
        defaultATCUIGenericConfigurationProtocol = uiConfig
        backgroundColor = uiConfig.mainThemeBackgroundColor
        inputTextViewTextColor = uiConfig.colorGray0
        primaryColor = uiConfig.mainThemeForegroundColor
        fontAudioTimerLabel = uiConfig.boldLargeFont
        audioTimerTextColor = uiConfig.mainSubtextColor
    }
}

class ATCChatThreadViewController: MessagesViewController, MessagesDataSource, ATCChatAudioRecordingProtocol, AVAudioRecorderDelegate {
    
    var audioRecordingTimer: Timer? = nil
    var audioPlayingTimeUpdater : CADisplayLink? = nil
    var audioPlayer: AVAudioPlayer? = nil
    var audioRecordingTimeLeft: Double = 0.0

    var recordingSession: AVAudioSession? = nil
    var audioRecorder: AVAudioRecorder? = nil

    var currentAudioCell: AudioMessageCell? = nil
    var currentAudioMessageDuration: Float = 0.0
    
    var microPhoneButton: UIButton!
    var recordItem: InputBarRecordItem!
    
    var sortedRecipients : [ATCUser] = []
    var mentionUsersVC: ATCMentionsTypeaheadViewController?
    let mentionUsersContainerView = UIView()
    var allTagUsers: [String] = []
    var mentioningUsersArray:[String]?

    var allAudioDownloadTasks: [StorageDownloadTask] = []

    var user: ATCUser
    var recipients: [ATCUser]
    private var visibleMessages: [ATChatMessage] = []
    private var messages: [ATChatMessage] = [] // these are all the messages already fetched from backend
    private var messageListener: ListenerRegistration?
    private var messageTypingListener: ListenerRegistration?

    private let db = Firestore.firestore()
    private var reference: CollectionReference?
    private let storage = Storage.storage().reference()

    let reportingManager: ATCUserReportingProtocol?
    
    var typingIndicatorShowTimer: Timer? = nil
    var typingIndicatorUpdateTimer: Timer? = nil
    
    private var isSendingMedia = false {
        didSet {
            DispatchQueue.main.async {
                self.messageInputBar.leftStackViewItems.forEach { item in
                    item.inputBarAccessoryView?.sendButton.isEnabled = !self.isSendingMedia
                }
            }
        }
    }

    var channel: ATCChatChannel
    var uiConfig: ATCChatUIConfigurationProtocol
    var chatServiceConfig: ATCChatServiceConfigProtocol?
    
    private let groupMembersCellClass = ATCMentionsUserTableViewCell.self

    // Pagination
    fileprivate lazy var refreshControl = UIRefreshControl()
    private let paginationBatchSize = 50
    private var topMostMessageID: String? = nil

    func startAudioRecord() {
        recordingSession = AVAudioSession.sharedInstance()

        do {
            try recordingSession?.setCategory(.playAndRecord, mode: .default)
            try recordingSession?.setActive(true)
            recordingSession?.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.startRecording()
                        self.audioRecordingTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.onTimerFires), userInfo: nil, repeats: true)
                    } else {
                        // failed to record!
                    }
                }
            }
        } catch {
            // failed to record!
        }
    }
    
    @objc func onTimerFires()
    {
        audioRecordingTimeLeft += 1.0

        let currentTime = Int(audioRecordingTimeLeft)
        let minutes = currentTime/60
        let seconds = currentTime - minutes * 60
            
        recordItem?.timerLabel.text = String(format: "%2d:%02d", minutes,seconds)

        if audioRecordingTimeLeft >= kAudioRecordingConfig.kAudioMessageTimeLimit {
            if let audioRecordingTimer = audioRecordingTimer {
                self.stopTimer(audioRecordingTimer)
            }
        }
    }
    
    func startRecording() {
        audioRecordingTimeLeft = 0.0
        let audioFilename = documentDirectory().appendingPathComponent("recording.m4a")

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
        } catch {
            finishRecording(success: false)
        }
    }
    
    func sendAudioRecord() {
        recordItem?.timerLabel.text = "0:00"
        if let audioRecordingTimer = audioRecordingTimer {
            self.stopTimer(audioRecordingTimer)
        }
        finishRecording(success: true)
    }
    
    func finishRecording(success: Bool) {
        audioRecorder?.stop()
        audioRecorder = nil

        recordItem?.isHidden = true

        if success {
            let audioFileUrl = documentDirectory().appendingPathComponent("recording.m4a")
            isSendingMedia = true
            uploadMediaMessage(audioFileUrl, to: channel) { [weak self] url in
                
                guard let `self` = self else {
                    return
                }
                self.isSendingMedia = false

                guard let url = url else {
                    return
                }
                
                let asset = AVURLAsset(url: audioFileUrl, options: nil)
                let audioDuration = asset.duration
                let audioDurationSeconds = CMTimeGetSeconds(audioDuration)

                let message = ATChatMessage(user: self.user, audioURL: url, audioDuration: Float(audioDurationSeconds))
                message.audioDownloadURL = url

                self.save(message)
                self.messagesCollectionView.scrollToBottom()

            }
        }
    }
    
    func documentDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    func cancelAudioRecord() {
        recordItem?.timerLabel.text = "0:00"
        if let audioRecordingTimer = audioRecordingTimer {
            self.stopTimer(audioRecordingTimer)
        }
        recordItem?.isHidden = true
    }
    
    init(user: ATCUser,
         channel: ATCChatChannel,
         uiConfig: ATCChatUIConfigurationProtocol,
         reportingManager: ATCUserReportingProtocol?,
         chatServiceConfig: ATCChatServiceConfigProtocol,
         recipients: [ATCUser] = []) {
        self.user = user
        self.channel = channel
        self.uiConfig = uiConfig
        self.recipients = recipients
        self.reportingManager = reportingManager
        self.chatServiceConfig = chatServiceConfig
        super.init(nibName: nil, bundle: nil)
        self.title = channel.name
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        messageListener?.remove()
        messageTypingListener?.remove()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        messagesCollectionView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)

        view.addSubview(mentionUsersContainerView)
        self.view.bringSubviewToFront(mentionUsersContainerView)
        
        mentionUsersContainerView.snp.makeConstraints { (maker) in
            maker.leading.trailing.equalTo(self.view)
            maker.bottom.equalTo(self.view.snp.bottom)
        }

        mentionUsersVC = ATCMentionsTypeaheadViewController(uiConfig: self.uiConfig)
        if let mentionUsersVC = mentionUsersVC {
            addChild(mentionUsersVC)
            mentionUsersContainerView.addSubview(mentionUsersVC.view)
            mentionUsersVC.view.snp.makeConstraints { (maker) in
                maker.leading.trailing.top.bottom.equalTo(mentionUsersContainerView)
            }
            mentionUsersVC.delegate = self
        }
        
        reference = db.collection(["channels", channel.id, "thread"].joined(separator: "/"))
        
        navigationItem.largeTitleDisplayMode = .never

        maintainPositionOnKeyboardFrameChanged = true

        messageInputBar.inputTextView.delegate = self
        
        let inputTextView = messageInputBar.inputTextView
        inputTextView.tintColor = uiConfig.primaryColor
        inputTextView.textColor = uiConfig.inputTextViewTextColor
        inputTextView.backgroundColor = uiConfig.inputTextViewBgColor
        inputTextView.layer.cornerRadius = 14.0
        inputTextView.layer.borderWidth = 0.0
        inputTextView.font = UIFont.systemFont(ofSize: 16.0)
        
        inputTextView.placeholderLabel.textColor = uiConfig.inputPlaceholderTextColor
        inputTextView.placeholderLabel.text = "Start typing...".localizedCore
        inputTextView.textContainerInset = UIEdgeInsets(top: 6, left: 30, bottom: 6, right: 12)
        inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 6, left: 33, bottom: 6, right: 15)

        let sendButton = messageInputBar.sendButton
        sendButton.setTitleColor(uiConfig.primaryColor, for: .normal)
        sendButton.setImage(UIImage.localImage("share-icon", template: true), for: .normal)
        sendButton.title = ""
        sendButton.setSize(CGSize(width: 30, height: 30), animated: false)
        sendButton.tintColor = uiConfig.primaryColor

        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self

        let cameraItem = InputBarButtonItem(type: .system)
        cameraItem.tintColor = uiConfig.primaryColor
        cameraItem.image = UIImage.localImage("camera-filled-icon", template: true)
        cameraItem.addTarget(
            self,
            action: #selector(cameraButtonPressed),
            for: .primaryActionTriggered
        )
        cameraItem.setSize(CGSize(width: 30, height: 30), animated: false)

        messageInputBar.leftStackView.alignment = .center
        messageInputBar.setLeftStackViewWidthConstant(to: 50, animated: false)
        messageInputBar.setRightStackViewWidthConstant(to: 35, animated: false)
        messageInputBar.setStackViewItems([cameraItem], forStack: .left, animated: false)
        messageInputBar.backgroundColor = uiConfig.backgroundColor
        messageInputBar.backgroundView.backgroundColor = uiConfig.backgroundColor
        messageInputBar.separatorLine.isHidden = true

        self.updateNavigationBar()
        messagesCollectionView.backgroundColor = uiConfig.backgroundColor
        view.backgroundColor = uiConfig.backgroundColor
        
        if chatServiceConfig?.isAudioMessagesEnabled ?? false {
            
            inputTextView.textContainerInset.left = 30
            inputTextView.placeholderLabelInsets.left = 33

            microPhoneButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            microPhoneButton.setTitleColor(.red, for: .normal)
            microPhoneButton.setImage(UIImage.localImage("icons8-microphone-24", template: true), for: .normal)
            microPhoneButton.addTarget(
                self,
                action: #selector(microphoneButtonPressed),
                for: .touchUpInside)
            inputTextView.addSubview(microPhoneButton)

            let screen = UIScreen.main.bounds
            recordItem = InputBarRecordItem(frame: CGRect(0, 0, screen.width, 300))
            recordItem.uiConfig = uiConfig
            
            recordItem.setSize(CGSize(width: screen.width, height: 300), animated: false)
            recordItem.recodingDelegate = self

            messageInputBar.setStackViewItems([recordItem], forStack: .bottom, animated: true)

            recordItem?.isHidden = true

        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(observerAddedGroupMember(_:)),name: kATCAddedGroupMemberNotification, object: nil)
    }

    @objc func didPullToRefresh() {
        // we increase the visible messages by one more page (e.g. batch size)
        guard let currentTopMostMessageID = topMostMessageID else { return }
        let oldIndex = messages.firstIndex { (message) -> Bool in
            return message.messageId == currentTopMostMessageID
        }
        guard let index = oldIndex else { return }

        // calculate paginationBatchSize left of index
        let newIndex = index - paginationBatchSize
        if (newIndex < 0) {
            self.topMostMessageID = messages.first?.messageId
        } else {
            self.topMostMessageID = messages[newIndex].messageId
        }
        updateVisibleMessages()
        refreshControl.endRefreshing()
    }
    
    @objc func observerAddedGroupMember(_ notification: Notification) {
        let responseData = notification.userInfo
        if let recipients = responseData?["recipients"] as? [ATCUser] {
            self.recipients = recipients
        }
    }

    fileprivate func insertDeliveryStatusMessage(message: ATChatMessage) {
        var seenersProfilePictureURLs: [String] = []
        if message.lastMessageSeeners.count > 0 {
            for lastMessageSeener in message.lastMessageSeeners {
                if let profilePictureURL = lastMessageSeener.profilePictureURL {
                    seenersProfilePictureURLs.append(profilePictureURL)
                }
            }
        }
        self.insertNewMessage(ATChatMessage(messageId: seenStatusConfig.seenStatusMessageID,
                                            messageKind: .status(seenersProfilePictureURLs),
                                            createdAt: Date(),
                                            atcSender: self.user,
                                            recipient: self.user,
                                            lastMessageSeeners: message.lastMessageSeeners,
                                            seenByRecipient: false))
    }
    
    fileprivate func saveSeenStatusIfNeeded(message: ATChatMessage) {
        if (message.lastMessageSeeners.filter { $0.uid == self.user.uid }).isEmpty {
            self.reference?.document(message.messageId).getDocument(completion: { (snapshot, error) in
                guard let snapshot = snapshot else {
                    return
                }
                let document = snapshot.data()
                var lastMessageSeeners: [[String: String]] = document?["lastMessageSeeners"] as? [[String: String]] ?? []
                if let userid = self.user.uid {
                    lastMessageSeeners.append(
                        [
                            "uid": userid,
                            "firstName": self.user.firstName ?? "",
                            "lastName": self.user.lastName ?? "",
                            "profilePictureURL": self.user.profilePictureURL ?? ""
                        ]
                    )
                }
                self.reference?.document(message.messageId).setData(["lastMessageSeeners": lastMessageSeeners], merge: true)
            })
        }
    }
    
    func startTypingIndicatorShowTimer() {
        DispatchQueue.main.async {
            self.typingIndicatorShowTimer = Timer.scheduledTimer(timeInterval: 15.0, target: self, selector: #selector(self.typingIndicatorHide), userInfo: nil, repeats: false)
            
        }
    }
    
    @objc func typingIndicatorHide() {
        self.setTypingIndicatorViewHidden(true, animated: true)
        if let typingIndicatorShowTimer = typingIndicatorShowTimer {
            self.stopTimer(typingIndicatorShowTimer)
        }
    }
    
    func stopTimer(_ timer: Timer) {
        timer.invalidate()
    }

    func startTypingIndicatorUpdateTimer() {
        DispatchQueue.main.async {
            self.typingIndicatorUpdateTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.typingIndicatorUpdate), userInfo: nil, repeats: true)
            
        }
    }
    
    @objc func typingIndicatorUpdate() {
        self.updateTypingStatus(message: messageInputBar.inputTextView.text)
    }

    private func setupMessageListener() {
        messageListener = reference?.addSnapshotListener { [weak self] querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }

            guard let `self` = self else { return }

            snapshot.documentChanges.forEach { change in
                self.handleDocumentChange(change)
            }

            self.messages = self.messages.filter { $0.messageId != seenStatusConfig.seenStatusMessageID }
            self.messagesCollectionView.reloadData()
            if let lastMessage = self.messages.last {
                if self.isFromCurrentSender(message: lastMessage) {
                    self.insertDeliveryStatusMessage(message: lastMessage)
                } else {
                    self.saveSeenStatusIfNeeded(message: lastMessage)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reference?
            .order(by: "created", descending: true)
            .limit(to: paginationBatchSize)
            .getDocuments(completion: {[weak self] (snapshot, error) in
                guard let `self` = self else { return }
                guard let docs = snapshot?.documents else { return }
                var firstMessages: [ATChatMessage] = []
                for doc in docs {
                    guard let message = ATChatMessage(user: self.user, document: doc) else {
                        return
                    }
                    if let url = message.downloadURL {
                        message.image = UIImage()
                        firstMessages.append(message)
                        self.downloadImage(at: url) { [weak self] image in
                            guard let `self` = self else {
                                return
                            }
                            guard let image = image else {
                                return
                            }

                            message.image = image
                            self.insertNewMessage(message)
                        }
                    } else {
                        firstMessages.append(message)
                    }
                }
                self.insertMessages(firstMessages)
                self.setupMessageListener()
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let `self` = self else { return }
            if self.chatServiceConfig?.isTypingIndicatorEnabled ?? false {
                let messageTypingReference = self.db.collection("channels").document(self.channel.id)
                self.messageTypingListener = messageTypingReference.addSnapshotListener { [weak self] querySnapshot, error in
                    guard let snapshot = querySnapshot else {
                        print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                        return
                    }
                    guard let data = snapshot.data() else {
                        return
                    }
                    guard let `self` = self else { return }
                    self.handleTypingChange(data)
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if !messageInputBar.inputTextView.text.isEmpty && (chatServiceConfig?.isTypingIndicatorEnabled ?? false) {
            self.updateTypingStatus(message: "")
        }
        cancelAllAudioDownloadTasks()
        self.audioPlayer?.stop()
        self.stopUpdateAudioPlayingTime()
        currentAudioCell?.playButton.isSelected = false
        messageListener?.remove()
        messageTypingListener?.remove()
    }
    
    func cancelAllAudioDownloadTasks() {
        for task in allAudioDownloadTasks {
            task.cancel()
        }
    }

    // MARK: - Actions

    @objc private func cameraButtonPressed() {
        showMediaOptionsActionSheet()
    }

    fileprivate func showMediaOptionsActionSheet() {
        let actionSheet = UIAlertController(title: "Upload Media".localizedCore, message: "Choose Media".localizedCore, preferredStyle: UIDevice.current.userInterfaceIdiom == .pad ? .alert : .actionSheet)
        let cameraAction = UIAlertAction(title: "Take Photo".localizedCore, style: .default) { [weak self] (camera) in
            //Take photo from camera
            guard let strongSelf = self else { return }
            strongSelf.didTapAddImageButton(sourceType: .camera)
        }
        
        let libraryAction = UIAlertAction(title: "Import from Library".localizedCore, style: .default) { [weak self] (change) in
           //Import photo from library
            guard let strongSelf = self else { return }
            strongSelf.didTapAddImageButton(sourceType: .photoLibrary)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel".localizedCore, style: .cancel, handler: nil)
        
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(libraryAction)
        actionSheet.addAction(cancelAction)
        actionSheet.popoverPresentationController?.sourceView = view // works for both iPhone & iPad
        present(actionSheet, animated: true, completion: nil)
    }
    
    private func didTapAddImageButton(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self

        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            picker.sourceType = sourceType
        } else {
            return
        }
        
        picker.mediaTypes = ["public.image", "public.movie"]

        present(picker, animated: true, completion: nil)
    }

    @objc private func microphoneButtonPressed() {
        messageInputBar.inputTextView.resignFirstResponder()
        recordItem?.isHidden = false
    }

    // MARK: - Helpers

    private func save(_ message: ATChatMessage) {
        reference?.addDocument(data: message.representation) {[weak self] error in
            if let e = error {
                print("Error sending message: \(e.localizedDescription)")
                return
            }
            guard let `self` = self else { return }

            let channelRef = Firestore.firestore().collection("channels").document(self.channel.id)
            var lastMessage = ""
            switch message.kind {
            case let .text(text):
                lastMessage = text
            case let .attributedText(text):
                lastMessage = text.fetchAttributedText(allTagUsers: self.allTagUsers)
            case .audio(_):
                lastMessage = "Someone sent an audio message.".localizedChat
            case .photo(_):
                lastMessage = "Someone sent a photo.".localizedChat
            case .video(_):
                lastMessage = "Someone sent a video.".localizedChat
            default:
                break
            }
            let newData: [String: Any] = [
                "lastMessageDate": Date(),
                "lastMessage": lastMessage
            ]
            channelRef.setData(newData, merge: true)
            ATCChatFirebaseManager.updateChannelParticipationIfNeeded(channel: self.channel)
            self.sendOutPushNotificationsIfNeeded(message: message)

            self.messagesCollectionView.scrollToBottom()
        }
    }

    private func sendOutPushNotificationsIfNeeded(message: ATChatMessage) {
        var lastMessage = ""
        switch message.kind {
        case let .text(text):
//            if let firstName = user.firstName {
//                lastMessage = firstName + ": " + text
//            } else {
                lastMessage = text
//            }
        case let .attributedText(text):
            lastMessage = text.string
        case .photo(_):
            lastMessage = "Someone sent a photo."
        default:
            break
        }

        let notificationSender = ATCPushNotificationSender()
        recipients.forEach { (recipient) in
            if let token = recipient.pushToken, recipient.uid != user.uid {
                notificationSender.sendPushNotification(to: token, title: user.firstName ?? "Instachatty", body: lastMessage)
            }
        }
    }

    private func updateTypingStatus(message: String) {
        if let typingIndicatorUpdateTimer = typingIndicatorUpdateTimer {
            self.stopTimer(typingIndicatorUpdateTimer)
        }
        let newData: [String: Any] = [
            user.uid ?? "noId" : [
                "lastTypingUsername": user.firstName ?? "...",
                "lastTypingTimestamp": message.isEmpty ? nil : Date() as Any
            ]
        ]
        let channelRef = Firestore.firestore().collection("channels").document(self.channel.id)
        channelRef.setData(newData, merge: true)
        if !message.isEmpty {
            self.startTypingIndicatorUpdateTimer()
        }
    }

    private func insertMessages(_ newMessages: [ATChatMessage]) {
        messages.append(contentsOf: newMessages)
        messages.sort()
        updateVisibleMessages()
        DispatchQueue.main.async {
            self.messagesCollectionView.scrollToBottom(animated: true)
        }
    }

    private func insertNewMessage(_ message: ATChatMessage) {
        if messages.contains(message) {
            self.messages = self.messages.filter { $0 != message }
        }

        messages.append(message)
        messages.sort()
        let isLatestMessage = messages.firstIndex(of: message) == (messages.count - 1)
        
        let shouldScrollToBottom = messagesCollectionView.isAtBottom(navigationBarWithStatusBarHeight: navigationBarFrame.height + statusBarFrame.height) && isLatestMessage

        updateVisibleMessages()

        if shouldScrollToBottom {
            DispatchQueue.main.async {
                self.messagesCollectionView.scrollToBottom(animated: true)
            }
        }
    }

    private func handleTypingChange(_ typeStatus: [String: Any]) {
        DispatchQueue.main.async {
            for (index, key) in (typeStatus.keys).enumerated() {
                if key != self.user.uid, let typingUser = typeStatus[key] as? [String: Any] {
                    if let lastTypingTimestamp = typingUser["lastTypingTimestamp"] as? Timestamp {
                        let lastTypingTimestampInSeconds: Int = Int(Date().timeIntervalSince(lastTypingTimestamp.dateValue()))
                        if lastTypingTimestampInSeconds < kTypingIndicatorConfig.kTypingIndicatorThresholdInSeconds {
                            if self.isTypingIndicatorHidden {
                                let shouldScrollToBottom = self.messagesCollectionView.isAtBottom(navigationBarWithStatusBarHeight: self.navigationBarFrame.height + self.statusBarFrame.height)
                                self.setTypingIndicatorViewHidden(false, animated: true)
                                if shouldScrollToBottom {
                                    self.messagesCollectionView.scrollToBottom(animated: true)
                                }
                            }
                            if let typingIndicatorShowTimer = self.typingIndicatorShowTimer {
                                self.stopTimer(typingIndicatorShowTimer) // for old timer if inprogress
                            }
                            self.startTypingIndicatorShowTimer() // for new typing indicator
                            return
                        }
                    }
                }
                if index == (typeStatus.count - 1) {
                    self.setTypingIndicatorViewHidden(true, animated: true)
                }
            }
        }
    }
    
    private func handleDocumentChange(_ change: DocumentChange) {
        guard let message = ATChatMessage(user: self.user, document: change.document) else {
            return
        }
        switch change.type {
        case .added:
            if let url = message.downloadURL {
                message.image = UIImage()
                self.insertNewMessage(message)
                downloadImage(at: url) { [weak self] image in
                    guard let `self` = self else {
                        return
                    }
                    guard let image = image else {
                        return
                    }

                    message.image = image
                    self.insertNewMessage(message)
                }
            } else if message.audioDownloadURL != nil {
                self.insertNewMessage(message)
            } else {
                insertNewMessage(message)
            }
        case .modified:
            insertNewMessage(message)
        default:
            break
        }
    }

    private func uploadMediaMessage(_ url: URL, to channel: ATCChatChannel, completion: @escaping (URL?) -> Void) {
        
        let hud = CPKProgressHUD.progressHUD(style: .loading(text: "Sending".localizedChat))
        hud.show(in: view)

        let fileName = [UUID().uuidString, String(Date().timeIntervalSince1970)].joined()
        storage.child(channel.id).child(fileName).putFile(from: url, metadata: nil) { (meta, error) in
            hud.dismiss()
            if let name = meta?.path, let bucket = meta?.bucket {
                let path = "gs://" + bucket + "/" + name
                completion(URL(string: path))
            } else {
                completion(nil)
            }
        }
    }
    
    private func uploadImage(_ image: UIImage, to channel: ATCChatChannel, completion: @escaping (URL?) -> Void) {

        guard let scaledImage = image.scaledToSafeUploadSize, let data = scaledImage.jpegData(compressionQuality: 0.4) else {
            completion(nil)
            return
        }
        let hud = CPKProgressHUD.progressHUD(style: .loading(text: "Sending".localizedChat))
        hud.show(in: view)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let imageName = [UUID().uuidString, String(Date().timeIntervalSince1970)].joined()
        storage.child(channel.id).child(imageName).putData(data, metadata: metadata) { meta, error in
            hud.dismiss()
            if let name = meta?.path, let bucket = meta?.bucket {
                let path = "gs://" + bucket + "/" + name
                completion(URL(string: path))
            } else {
                completion(nil)
            }
        }
    }

    private func sendPhoto(_ image: UIImage) {
        isSendingMedia = true
        uploadImage(image, to: channel) { [weak self] url in
            guard let `self` = self else {
                return
            }
            self.isSendingMedia = false

            guard let url = url else {
                return
            }
            let message = ATChatMessage(user: self.user, image: image, url: url)
            message.downloadURL = url

            self.save(message)
            self.messagesCollectionView.scrollToBottom()
        }
    }

    private func downloadImage(at url: URL, completion: @escaping (UIImage?) -> Void) {
        let ref = Storage.storage().reference(forURL: url.absoluteString)
        let megaByte = Int64(1 * 1024 * 1024)

        ref.getData(maxSize: megaByte) { data, error in
            guard let imageData = data else {
                completion(nil)
                return
            }

            completion(UIImage(data: imageData))
        }
    }
    
    private func updateNavigationBar() {
        if self.channel.participants.count > 2 || !self.channel.groupCreatorID.isEmpty {
            var rightBarButtonItems: [UIBarButtonItem] = []
            let settingsBtn = UIButton(type: .custom)
            settingsBtn.setImage(UIImage.localImage("settings-icon", template: true), for: .normal)
            settingsBtn.addTarget(self, action: #selector(actionsButtonTapped), for: .touchUpInside)
            let settingsItem = UIBarButtonItem(customView: settingsBtn)
            settingsItem.customView?.translatesAutoresizingMaskIntoConstraints = false
            settingsItem.customView?.snp.makeConstraints { (maker) in
                maker.width.height.equalTo(30)
            }
            rightBarButtonItems.append(settingsItem)
            self.navigationItem.rightBarButtonItems = rightBarButtonItems
        } else {
            // 1-1 conversations
            var rightBarButtonItems: [UIBarButtonItem] = []
            if reportingManager != nil {
                let settingsBtn = UIButton(type: .custom)
                settingsBtn.setImage(UIImage.localImage("settings-icon", template: true), for: .normal)
                settingsBtn.addTarget(self, action: #selector(repotingButtonTapped), for: .touchUpInside)
                let settingsItem = UIBarButtonItem(customView: settingsBtn)
                settingsItem.customView?.translatesAutoresizingMaskIntoConstraints = false
                settingsItem.customView?.snp.makeConstraints { (maker) in
                    maker.width.height.equalTo(30)
                }
                rightBarButtonItems.append(settingsItem)
            }
            self.navigationItem.rightBarButtonItems = rightBarButtonItems
        }
    }

    fileprivate func otherUser() -> ATCUser? {
        for recipient in recipients {
            if recipient.uid != user.uid {
                return recipient
            }
        }
        return nil
    }

    @objc private func repotingButtonTapped() {
        self.showCaretMenu()
    }

    @objc private func actionsButtonTapped() {
        let alert = UIAlertController(title: "Group Settings".localizedChat, message: "", preferredStyle: UIAlertController.Style.actionSheet)
        alert.addAction(UIAlertAction(title: "Rename Group".localizedChat, style: .default, handler: {[weak self] (action) in
            guard let strongSelf = self else { return }
            strongSelf.didTapRenameButton()
        }))
        alert.addAction(UIAlertAction(title: "View Group Members".localizedChat, style: .default, handler: {[weak self] (action) in
            guard let strongSelf = self else { return }
            strongSelf.didTapViewGroupMembersButton()
        }))
        alert.addAction(UIAlertAction(title: "Leave Group".localizedChat, style: .destructive, handler: {[weak self] (action) in
            guard let strongSelf = self else { return }
            strongSelf.didTapLeaveGroupButton()
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localizedCore, style: .cancel, handler: nil))
        if let popoverPresentationController = alert.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = self.view.bounds
        }
        self.present(alert, animated: true)
    }

    private func didTapRenameButton() {
        let alert = UIAlertController(title: "Change Name".localizedChat, message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Enter Group Name".localizedChat
        })
        alert.addAction(UIAlertAction(title: "OK".localizedCore, style: .default, handler: {[weak self] (action) in
            guard let strongSelf = self else { return }
            guard let name = alert.textFields?.first?.text else {
                return
            }
            if name.count == 0 {
                strongSelf.didTapRenameButton()
                return
            }
            ATCChatFirebaseManager.renameGroup(channel: strongSelf.channel, name: name)
            strongSelf.title = name
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localizedCore, style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }

    private func didTapLeaveGroupButton() {
        let alert = UIAlertController(title: "Are you sure?".localizedChat, message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Yes".localizedCore, style: .default, handler: {[weak self] (action) in
            guard let strongSelf = self else { return }
            ATCChatFirebaseManager.leaveGroup(channel: strongSelf.channel, user: strongSelf.user)
            strongSelf.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localizedCore, style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }

    private func didTapViewGroupMembersButton() {
        if let chatServiceConfig = chatServiceConfig {
            let vc = ATCChatGroupMembersViewController(user: self.user, recipients: self.recipients, channel: channel, uiConfig: uiConfig.defaultATCUIGenericConfigurationProtocol, reportingManager: reportingManager, chatServiceConfig: chatServiceConfig)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: - MessagesDataSource

    func currentSender() -> SenderType {
        return Sender(senderId: user.uid ?? "noId", displayName: "You")
    }

    func numberOfMessages(in messagesCollectionView: MessagesCollectionView) -> Int {
        return visibleMessages.count
    }

    func messageForItem(at indexPath: IndexPath,
                        in messagesCollectionView: MessagesCollectionView) -> MessageType {
        if indexPath.section < visibleMessages.count {
            return visibleMessages[indexPath.section]
        }
        fatalError()
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return visibleMessages.count
    }

    func cellTopLabelAttributedText(for message: MessageType,
                                    at indexPath: IndexPath) -> NSAttributedString? {

        let name = message.sender.displayName
        return NSAttributedString(
            string: name,
            attributes: [
                .font: UIFont.preferredFont(forTextStyle: .caption1),
                .foregroundColor: UIColor(white: 0.3, alpha: 1)
            ]
        )
    }
}

// MARK: - Pagination

extension ATCChatThreadViewController {
    func updateVisibleMessages() {
        if let topMostMessageID = topMostMessageID {
            let index = messages.firstIndex { (message) -> Bool in
                return message.messageId == topMostMessageID
            }
            if let index = index {
                visibleMessages = Array(messages.suffix(from: index))
                // we need to make sure we display at least a batch size
                let batchSizeMessages = Array(messages.suffix(paginationBatchSize))
                if (batchSizeMessages.count > visibleMessages.count) {
                    visibleMessages = batchSizeMessages
                }
                messagesCollectionView.reloadData()
                return
            }
        }
        // we need a new topMostMessageID (the old one is nil or it doesn't exist anymore - e.g. message was removed)
        visibleMessages = Array(messages.suffix(paginationBatchSize))
        if let topElement = visibleMessages.first {
            topMostMessageID = topElement.messageId
        }
        messagesCollectionView.reloadData()
    }
}

// MARK: - MessagesLayoutDelegate

extension ATCChatThreadViewController: MessagesLayoutDelegate {

    func avatarSize(for message: MessageType, at indexPath: IndexPath,
                    in messagesCollectionView: MessagesCollectionView) -> CGSize {

        return .zero
    }

    func footerViewSize(for message: MessageType, at indexPath: IndexPath,
                        in messagesCollectionView: MessagesCollectionView) -> CGSize {

        return CGSize(width: 0, height: 8)
    }

    func heightForLocation(message: MessageType, at indexPath: IndexPath,
                           with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {

        return 0
    }
    
    private var navigationBarFrame: CGRect {
        guard let navigationController = navigationController, !navigationController.navigationBar.isHidden else {
            return .zero
        }
        return navigationController.navigationBar.frame
    }

    private var statusBarFrame: CGRect {
        guard let statusBarManager = view.window?.windowScene?.statusBarManager else {
            return .zero
        }
        return statusBarManager.statusBarFrame
    }
}

// MAR: - MessageInputBarDelegate

extension ATCChatThreadViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.impactOccurred()
        let attributedString = inputBar.inputTextView.attributedText ?? NSAttributedString()
        let message = ATChatMessage(messageId: UUID().uuidString,
                                    messageKind: MessageKind.attributedText(attributedString),
                                    createdAt: Date(),
                                    atcSender: user,
                                    recipient: user,
                                    lastMessageSeeners: [],
                                    seenByRecipient: false,
                                    allTagUsers: self.allTagUsers)
        save(message)
        inputBar.inputTextView.text = ""
    }

    func inputBar(_ inputBar: InputBarAccessoryView, didChangeIntrinsicContentTo size: CGSize) {}
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
    }
    func inputBar(_ inputBar: InputBarAccessoryView, didSwipeTextViewWith gesture: UISwipeGestureRecognizer) {}
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidBeginEditing text: String) {
        recordItem?.isHidden = true
    }
}

// MARK: - MessagesDisplayDelegate

extension ATCChatThreadViewController: MessagesDisplayDelegate {

    func backgroundColor(for message: MessageType, at indexPath: IndexPath,
                         in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? uiConfig.primaryColor : UIColor(hexString: "#f0f0f0")
    }

    func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath,
                             in messagesCollectionView: MessagesCollectionView) -> Bool {
        return false
    }

    func messageStyle(for message: MessageType, at indexPath: IndexPath,
                      in messagesCollectionView: MessagesCollectionView) -> MessageStyle {

        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }

    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if let message = message as? ATChatMessage {
            avatarView.initials = message.atcSender.initials
            if let urlString = message.atcSender.profilePictureURL {
                avatarView.kf.setImage(with: URL(string: urlString))
            }
        }
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url]
    }
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        if (detector == .url) {
            return [ NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue ]
        }
            return [NSAttributedString.Key.foregroundColor : UIColor.white]
    }
}

extension ATCChatThreadViewController : MessageCellDelegate, MessageLabelDelegate {
        
    func startUpdateAudioPlayingTime() {
        audioPlayingTimeUpdater = CADisplayLink(target: self, selector: #selector(self.trackAudio))
        audioPlayingTimeUpdater?.preferredFramesPerSecond = 1
        audioPlayingTimeUpdater?.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
    }
    
    @objc func trackAudio() {
        if audioPlayer?.isPlaying ?? false {
            let currentTime = Float(audioPlayer?.currentTime ?? 0.0)
            if let currentAudioCell = currentAudioCell {
                currentAudioCell.durationLabel.text = messagesCollectionView.messagesDisplayDelegate?.audioProgressTextFormat(currentTime, for: currentAudioCell, in: messagesCollectionView)
            }
        } else {
            if let currentAudioCell = currentAudioCell {
                currentAudioCell.durationLabel.text = messagesCollectionView.messagesDisplayDelegate?.audioProgressTextFormat(currentAudioMessageDuration, for: currentAudioCell, in: messagesCollectionView)
            }
            currentAudioCell?.playButton.isSelected = false
            stopUpdateAudioPlayingTime()
        }
    }
    
    func stopUpdateAudioPlayingTime() {
        audioPlayingTimeUpdater?.invalidate()
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        let indexPath = messagesCollectionView.indexPath(for: cell)
        guard let tappedCellIndexPath = indexPath else { return }
        let tappedMessage = messageForItem(at: tappedCellIndexPath, in: messagesCollectionView)
        if let message = tappedMessage as? ATChatMessage {
            if let downloadURL = message.downloadURL {
                let imageViewerVC = ATCChatImageViewer()
                imageViewerVC.downloadURL = downloadURL
                present(imageViewerVC, animated: true)
            } else if let downloadURL = message.audioDownloadURL {
                if case let audioCell as AudioMessageCell = cell {
                    if let currentAudioCell = currentAudioCell, currentAudioCell == audioCell{
                        if currentAudioCell.playButton.isSelected{
                            self.audioPlayer?.pause()
                            self.stopUpdateAudioPlayingTime()
                            currentAudioCell.playButton.isSelected = false
                        } else {
                            self.audioConfig()
                            self.audioPlayer?.play()
                            self.startUpdateAudioPlayingTime()
                            currentAudioCell.playButton.isSelected = true
                        }
                    }else {
                        if let currentAudioCell = currentAudioCell {
                            self.cancelAllAudioDownloadTasks()
                            self.stopUpdateAudioPlayingTime()
                            self.audioPlayer?.stop()
                            currentAudioCell.durationLabel.text = messagesCollectionView.messagesDisplayDelegate?.audioProgressTextFormat(currentAudioMessageDuration, for: currentAudioCell, in: messagesCollectionView)
                            currentAudioCell.playButton.isSelected = false
                        }
                        currentAudioMessageDuration = message.audioDuration ?? 0.0
                        currentAudioCell = audioCell
                        audioCell.playButton.isSelected = true
                        let storage =  Storage.storage()
                        storage.reference(forURL: downloadURL.absoluteString).downloadURL { (url, error) in
                            if let URL = url {
                                self.downloadAudioFileFromURL(url: URL)
                            }
                        }
                    }
                }
            } else if let downloadURL = message.videoDownloadURL {
                let storage =  Storage.storage()
                storage.reference(forURL: downloadURL.absoluteString).downloadURL { (url, error) in
                    if let URL = url {
                        let player = AVPlayer(url: URL)
                        let vc = AVPlayerViewController()
                        vc.player = player
                        self.present(vc, animated: true) { vc.player?.play() }
                    }
                }
            } else {
                print("Message does not contain image")
            }
        }
    }
    
    fileprivate func audioConfig() {
        // Play sound in Video when device is on RINGER mode and SLIENT mode
        do {
           try AVAudioSession.sharedInstance().setCategory(.playback)
        } catch(let error) {
            print(error.localizedDescription)
        }
    }
    
    fileprivate func downloadAudioFileFromURL(url: URL) {
        let storeRef =  Storage.storage().reference(forURL: url.absoluteString)
        let audioDownloadTask = storeRef.getData(maxSize: 10 * 1024 * 1024) { [unowned self] (data, error) in
            if let error = error {
                print(error)
            } else {
                if let d = data {
                    do {
                        self.audioPlayer = try AVAudioPlayer(data: d, fileTypeHint: AVFileType.mp3.rawValue)
                        if self.currentAudioCell?.playButton.isSelected ?? true {
                            self.audioConfig()
                            self.audioPlayer?.play()
                            self.startUpdateAudioPlayingTime()
                        }
                    } catch let error as NSError {
                        //self.player = nil
                        print(error.localizedDescription)
                    } catch {
                        print("AVAudioPlayer init failed")
                    }
                }
            }
        }
        allAudioDownloadTasks.append(audioDownloadTask)
    }
    
    func didSelectURL(_ url: URL) {
        var comps = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        comps.scheme = "https"
        let https = comps.url
        guard let httpsURL = https else { return }
        let webViewController = ATCWebViewController(url: httpsURL, title: "Web".localizedChat)
        navigationController?.pushViewController(webViewController, animated: true)
    }
}
// MARK: - UIImagePickerControllerDelegate

extension ATCChatThreadViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let asset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset {
            let size = CGSize(width: 500, height: 500)
            PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: nil) { result, info in
                guard let image = result else {
                    return
                }

                self.sendPhoto(image)
            }
        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            sendPhoto(image)
        } else if let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String, mediaType == "public.movie" {
            if let mediaURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL  {
                
                let videoData = NSData(contentsOf: mediaURL)
                let videoFileUrl = documentDirectory().appendingPathComponent("recordingVideo.mp4")
                
                do {
                    if FileManager.default.fileExists(atPath: videoFileUrl.path) {
                        try FileManager.default.removeItem(at: videoFileUrl)
                    }
                    videoData?.write(to: videoFileUrl, atomically: false)
                } catch (let error) {
                    print("Cannot copy: \(error)")
                }
                
                uploadMediaMessage(videoFileUrl, to: channel) { [weak self] url in
                    
                    guard let `self` = self else {
                        return
                    }
                    self.isSendingMedia = false

                    guard let url = url else {
                        return
                    }
                    
                    let asset = AVURLAsset(url: videoFileUrl, options: nil)
                    let imageGenerator = AVAssetImageGenerator(asset: asset)
                    var videoThumbnail = UIImage()
                    do {
                        let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60) , actualTime: nil)
                        videoThumbnail = UIImage(cgImage: thumbnailImage)
                    } catch let error {
                        print(error)
                    }
                    let videoDuration = asset.duration
                    let videoDurationSeconds = CMTimeGetSeconds(videoDuration)

                    self.uploadImage(videoThumbnail, to: self.channel) { [weak self] thumbnailUrl in
                        guard let `self` = self else {
                            return
                        }
                        self.isSendingMedia = false

                        guard let thumbnailUrl = thumbnailUrl else {
                            return
                        }
                        
                        let storage =  Storage.storage()
                        storage.reference(forURL: thumbnailUrl.absoluteString).downloadURL { (thumbnailOriginalUrl, error) in
                            if let videoThumbnailUrl = thumbnailOriginalUrl {
                                let message = ATChatMessage(user: self.user, videoThumbnailURL: videoThumbnailUrl, videoURL: url, videoDuration: Float(videoDurationSeconds))
                                message.videoDownloadURL = url
                                message.videoThumbnailURL = videoThumbnailUrl
                                
                                self.save(message)
                                self.messagesCollectionView.scrollToBottom()
                            }
                        }
                    }
                }
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

}

extension ATCChatThreadViewController {
    fileprivate func showCaretMenu() {
        guard let reportingManager = reportingManager, let profile = self.otherUser() else { return }
        let alert = UIAlertController(title: "Actions on ".localizedChat + (profile.firstName ?? ""),
                                      message: "",
                                      preferredStyle: UIAlertController.Style.actionSheet)
        alert.addAction(UIAlertAction(title: "Block user".localizedChat, style: .destructive, handler: {(action) in
            reportingManager.block(sourceUser: self.user, destUser: profile, completion: {[weak self]  (success) in
                guard let `self` = self else { return }
                self.showBlockMessage(success: success)
            })
        }))
        alert.addAction(UIAlertAction(title: "Report user".localizedChat, style: .default, handler: {(action) in
            self.showReportMenu()
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localizedCore, style: .cancel, handler: nil))
        if let popoverPresentationController = alert.popoverPresentationController {
            popoverPresentationController.sourceView = self.navigationController?.navigationBar
            if let frame = self.navigationController?.navigationBar.frame {
                popoverPresentationController.sourceRect = frame
            }
        }
        self.present(alert, animated: true, completion: nil)
    }

    fileprivate func showReportMenu() {
        let alert = UIAlertController(title: "Why are you reporting this account?".localizedChat, message: "", preferredStyle: UIAlertController.Style.actionSheet)
        alert.addAction(UIAlertAction(title: "Spam".localizedChat, style: .default, handler: {(action) in
            self.reportUser(reason: .spam)
        }))
        alert.addAction(UIAlertAction(title: "Sensitive photos".localizedChat, style: .default, handler: {(action) in
            self.reportUser(reason: .sensitiveImages)
        }))
        alert.addAction(UIAlertAction(title: "Abusive content".localizedChat, style: .default, handler: {(action) in
            self.reportUser(reason: .abusive)
        }))
        alert.addAction(UIAlertAction(title: "Harmful information".localizedChat, style: .default, handler: {(action) in
            self.reportUser(reason: .harmful)
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localizedCore, style: .cancel, handler: nil))
        if let popoverPresentationController = alert.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = self.view.bounds
        }
        self.present(alert, animated: true, completion: nil)
    }

    fileprivate func showBlockMessage(success: Bool) {
        let message = (success) ? "This user has been blocked successfully.".localizedChat : "An error has occured. Please try again.".localizedChat
        let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK".localizedCore, style: .default, handler: { (action) in
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }

    fileprivate func reportUser(reason: ATCReportingReason) {
        guard let reportingManager = reportingManager, let profile = self.otherUser() else { return }
        reportingManager.report(sourceUser: user,
                                destUser: profile,
                                reason: reason) {[weak self] (success) in
                                    guard let `self` = self else { return }
                                    self.showReportMessage(success: success)
        }
    }

    fileprivate func showReportMessage(success: Bool) {
        let message = (success) ? "This user has been reported successfully.".localizedChat : "An error has occured. Please try again.".localizedChat
        let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK".localizedCore, style: .default, handler: { (action) in
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

extension ATCChatThreadViewController: ATCMentionsTypeaheadProtocol {
    func didSelectMentionsUser(member: ATCUser) {
        if var firstName = member.firstName, var lastName = member.lastName {
            firstName = firstName.trimmingCharacters(in: .whitespaces)
            lastName = lastName.trimmingCharacters(in: .whitespaces)
            let attributedString = messageInputBar.inputTextView.attributedText.fetchAttributedText(allTagUsers: self.allTagUsers)
            var findText = attributedString.components(separatedBy: "@")
            findText.removeLast()
            findText.append("<font color='#007AFF'>\(firstName)</font>")
            if !lastName.isEmpty {
                findText.append(" <font color='#007AFF'>\(lastName)</font>")
            }
            var myAttributedText = (findText.joined(separator: "@"))
            myAttributedText = myAttributedText.replacingOccurrences(of: "@<font color='#007AFF'>\(firstName)</font>", with: "<font color='#007AFF'>\(firstName)</font>")
            if !lastName.isEmpty {
                myAttributedText = myAttributedText.replacingOccurrences(of: "@ <font color='#007AFF'>\(lastName)</font>", with: " <font color='#007AFF'>\(lastName)</font>")
            }
            messageInputBar.inputTextView.attributedText = (myAttributedText + " ")
                .htmlToAttributedString(textColor: uiConfig.inputTextViewTextColor)
            
            allTagUsers.append(firstName)
            allTagUsers.append(lastName)
        }
        
        sortedRecipients = []
        if mentioningUsersArray == nil {
            mentioningUsersArray = ["\(member.uid ?? "0")"]
        } else {
            mentioningUsersArray?.append("\(member.uid ?? "0")")
        }
        setUpUserMentionView()
    }
}

extension ATCChatThreadViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        setUpUserMentionView()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        setUpUserMentionView()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let textViewPreviousCursor = textView.selectedRange
        
        let attributedString = textView.attributedText.fetchAttributedText(allTagUsers: self.allTagUsers)
        textView.attributedText = attributedString.htmlToAttributedString(textColor: uiConfig.inputTextViewTextColor)
        
        textView.selectedRange = textViewPreviousCursor
        
        if textView.text == "@" {
            sortedRecipients = recipients
        } else {
            let findText1 = textView.text.components(separatedBy: "@")
            
            if findText1.count > 1 {
                let checkFindText1 = findText1.filter { $0 != findText1.last }
                let checkFindText2 = checkFindText1.last
                var checkFindText2Range = checkFindText2!.last?.isWhitespace ?? false
                if !checkFindText2Range {
                    let lastCharacter: String.Element = checkFindText2?.last ?? Character("@")
                    checkFindText2Range = "\(lastCharacter)".containsEmoji
                }
                
                if checkFindText2Range {
                    let findText = findText1.last
                    let range = findText!.rangeOfCharacter(from: .whitespaces)
                    
                    if !findText!.isEmpty && range == nil {
                        sortedRecipients = recipients.filter({ (member) -> Bool in
                            if let name = member.firstName {
                                if name.lowercased().contains(findText!.lowercased()) {
                                    return true
                                }
                            }
                            if let name = member.lastName {
                                if name.lowercased().contains(findText!.lowercased()) {
                                    return true
                                }
                            }
                            return false
                        }) as [ATCUser]
                    } else if findText!.isEmpty && range == nil {
                        sortedRecipients = recipients
                    }
                } else if checkFindText2!.isEmpty {
                    let findText = findText1.last
                    let range = findText!.rangeOfCharacter(from: .whitespaces)
                    
                    if !findText!.isEmpty && range == nil {
                        sortedRecipients = recipients.filter({ (member) -> Bool in
                            if let name = member.firstName {
                                if name.lowercased().contains(findText!.lowercased()) {
                                    return true
                                }
                            }
                            if let name = member.lastName {
                                if name.lowercased().contains(findText!.lowercased()) {
                                    return true
                                }
                            }
                            return false
                        }) as [ATCUser]
                    } else if findText!.isEmpty && range == nil {
                        sortedRecipients = recipients
                    }
                }
                else{
                    sortedRecipients = []
                }
            } else {
                sortedRecipients = []
            }
        }
                
        setUpUserMentionView()
        
        if chatServiceConfig?.isTypingIndicatorEnabled ?? false {
            updateTypingStatus(message: textView.text ?? "")
        }
    }
    
    private func setUpUserMentionView() {
        mentionUsersVC?.sortedRecipients = sortedRecipients
        if sortedRecipients.count > 0 {
            let calculateMentionTablePostion = messageCollectionViewBottomInset + (statusBarFrame.height == 20.0 ? 0 : statusBarFrame.height-10)
            mentionUsersContainerView.isHidden = false
            self.mentionUsersContainerView.snp.updateConstraints { (maker) in
                maker.bottom.equalTo(self.view.snp.bottom).inset(calculateMentionTablePostion)
            }
            mentionUsersContainerView.transform = CGAffineTransform(translationX: 0, y: 10)
            let animator: UIViewPropertyAnimator!
            animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) { [unowned self] in
                self.mentionUsersContainerView.transform = CGAffineTransform(translationX: 0, y: 0)
            }
            animator.startAnimation()
        } else {
            mentionUsersContainerView.isHidden = true
        }
    }
}
