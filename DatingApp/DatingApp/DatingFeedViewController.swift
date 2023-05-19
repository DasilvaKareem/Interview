//
//  DatingFeedViewController.swift
//  DatingApp
//
//  Created by Florian Marcu on 1/23/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import Koloda
import UIKit

class DatingFeedViewController: UIViewController {

    var viewer: ATCDatingProfile? = nil {
        didSet {
            kolodaView.reloadData()
        }
    }
    @IBOutlet var containerView: UIView!
    @IBOutlet var kolodaView: KolodaView!
    @IBOutlet var actionsContainerView: UIView!
    @IBOutlet var dislikeButton: InstaRoundImageButton!
    @IBOutlet var superLikeButton: InstaRoundImageButton!
    @IBOutlet var likeButton: InstaRoundImageButton!
    
    let dataSource: ATCDatingFeedDataSource
    let uiConfig: ATCUIGenericConfigurationProtocol
    let swipeManager: ATCDatingSwipeManager?
    let reportingManager: ATCUserReportingProtocol?
    let chatServiceConfig: ATCChatServiceConfigProtocol
    let editProfileManager: ATCDatingProfileEditManager?
    let appConfig: DatingInAppConfigurationProtocol
    
    fileprivate var viewControllers: [Int: DatingFeedItemViewController] = [:]
    
    init(dataSource: ATCDatingFeedDataSource,
         uiConfig: ATCUIGenericConfigurationProtocol,
         reportingManager: ATCUserReportingProtocol? = nil,
         swipeManager: ATCDatingSwipeManager? = nil,
         chatServiceConfig: ATCChatServiceConfigProtocol,
         editProfileManager: ATCDatingProfileEditManager?,
         appConfig: DatingInAppConfigurationProtocol) {
        self.chatServiceConfig = chatServiceConfig
        self.dataSource = dataSource
        self.uiConfig = uiConfig
        self.swipeManager = swipeManager
        self.reportingManager = reportingManager
        self.editProfileManager = editProfileManager
        self.appConfig = appConfig
        super.init(nibName: "DatingFeedViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource.delegate = self
        self.view.backgroundColor = UIColor(hexString: "f6f7fa")
        let dislikeImg = UIImage(systemName: "hand.thumbsdown.fill")
        dislikeButton.configure(image: dislikeImg!.image(resizedTo: CGSize(width: 30, height: 30))!,
                                tintColor: UIColor(hexString: "#fd1b61"),
                                bgColor: .white)
        dislikeButton.addTarget(self, action: #selector(didTapDislikeButton), for: .touchUpInside)

       /* superLikeButton.configure(image: UIImage.localImage("star-filled-icon-1", template: true).image(resizedTo: CGSize(width: 25, height: 25))!,
                                  tintColor: UIColor(hexString: "#0495e3"),
                                  bgColor: .white)
       superLikeButton.addTarget(self, action: #selector(didTapSuperLikeButton), for: .touchUpInside)*/

        let img = UIImage(systemName: "hand.thumbsup.fill")
        likeButton.configure(image: img!.image(resizedTo: CGSize(width: 30, height: 30))!,
                             tintColor: UIColor(hexString: "#11e19d"),
                             bgColor: .white)
        likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)

        actionsContainerView.backgroundColor = .clear
        containerView.backgroundColor = uiConfig.mainThemeBackgroundColor
        kolodaView.backgroundColor = .clear
        actionsContainerView.backgroundColor = .clear
        view.backgroundColor = uiConfig.mainThemeBackgroundColor
        self.dataSource.loadTop()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        editProfileManager?.updateNumberOfSwipes(profile: viewer) { error in
            if error != nil {
                self.handleErrorAlert()
            }
        }
    }
    
    func update(user: ATCDatingProfile) {
        viewer = user
        self.dataSource.viewer = user
        self.dataSource.loadTop()
    }

    @objc func didTapDislikeButton() {
        kolodaView.swipe(.left)
    }

    @objc func didTapLikeButton() {
        ATCHapticsFeedbackGenerator.generateHapticFeedback(.mediumImpact)
        kolodaView.swipe(.right)
    }

    @objc func didTapSuperLikeButton() {
        ATCHapticsFeedbackGenerator.generateHapticFeedback(.heavyImpact)
        kolodaView.swipe(.up)
    }

    func showMatchScreenIfNeeded(author: ATCUser, profile: ATCDatingProfile,
                                 chatServiceConfig: ATCChatServiceConfigProtocol) {
        // Check of the liked profile has swiped right on the current user before.
        swipeManager?.checkIfPositiveSwipeExists(author: profile.uid ?? "", profile: author.uid ?? "", completion: {[weak self] (result) in
            guard let `self` = self else { return }
            if result == true {
                // If it did, it means we have a match.
                let itAMatchVC = DatingMatchViewController(user: author, profile: profile, uiConfig: self.uiConfig, hostViewController: self, chatServiceConfig: chatServiceConfig)
                self.present(itAMatchVC, animated: true, completion: nil)
            }
        })
    }

//    private func recordSwipeForCurrentProfile(type: String) {
//        let index = kolodaView.currentCardIndex
//        if let profile = dataSource.object(at: index) as? ATCDatingProfile, let viewer = viewer {
//            swipeManager?.recordSwipe(author: viewer.uid ?? "",
//                                      swipedProfile: profile.uid ?? "",
//                                      type: type)
//        }
//    }
}

extension DatingFeedViewController : ATCGenericCollectionViewControllerDataSourceDelegate {
    func genericCollectionViewControllerDataSource(_ dataSource: ATCGenericCollectionViewControllerDataSource, didLoadFirst objects: [ATCGenericBaseModel]) {
    }
    
    func genericCollectionViewControllerDataSource(_ dataSource: ATCGenericCollectionViewControllerDataSource, didLoadBottom objects: [ATCGenericBaseModel]) {
    }
    
    func genericCollectionViewControllerDataSource(_ dataSource: ATCGenericCollectionViewControllerDataSource, didLoadTop objects: [ATCGenericBaseModel]) {
        kolodaView.delegate = self
        kolodaView.dataSource = self
    }
}

extension DatingFeedViewController: DatingProfileDetailsCollectionViewControllerDelegate {
    func datingProfileDetailsViewControllerDidTapLike() -> Void {
        ATCHapticsFeedbackGenerator.generateHapticFeedback(.mediumImpact)
        kolodaView.swipe(.right)
    }

    func datingProfileDetailsViewControllerDidTapDislike() -> Void {
        kolodaView.swipe(.left)
    }

    func datingProfileDetailsViewControllerDidTapSuperlike() -> Void {
        ATCHapticsFeedbackGenerator.generateHapticFeedback(.heavyImpact)
        kolodaView.swipe(.up)
    }
}

extension DatingFeedViewController: KolodaViewDelegate {
    private func didSwipeCardAt(index: Int, in direction: SwipeResultDirection, with viewer: ATCDatingProfile) {
        if let profile = dataSource.object(at: index) as? ATCDatingProfile, let uid = viewer.uid {
            var type = "like"
            if direction == .up {
                type = "superlike"
            } else if direction == .left {
                type = "dislike"
            }
            swipeManager?.recordSwipe(author: uid,
                                      swipedProfile: profile.uid ?? "",
                                      type: type)
            if (direction == .right || direction == .up) {
                self.showMatchScreenIfNeeded(author: viewer, profile: profile, chatServiceConfig: chatServiceConfig)
            }
            viewControllers[index] = nil
        }
    }
    
    func koloda(_ koloda: KolodaView, shouldSwipeCardAt index: Int, in direction: SwipeResultDirection) -> Bool {
        guard let viewer = viewer else { return false }
        if viewer.checkVipStatus {
            ATCHapticsFeedbackGenerator.generateHapticFeedback(.mediumImpact)
            return true
        } else {
            if viewer.numberOfSwipes < appConfig.numberOfSwipes {
                ATCHapticsFeedbackGenerator.generateHapticFeedback(.mediumImpact)
                return true
            } else if viewer.numberOfSwipes == appConfig.numberOfSwipes {
                self.viewer?.limitedTime = Calendar.current.date(byAdding: .day, value: 1, to: Date())?.convertToString
                self.viewer?.increaseNumberOfSwipes()
                handleAlertAction(message: "You’ve swiped 25 cards today. There’s a lot more waiting for you. Ready to see them? Let's upgrade account now. Otherwise, come back here tomorrow.")
                return false
            } else {
                if Date() > (self.viewer?.limitedTime?.convertToDate ?? Date()) {
                    ATCHapticsFeedbackGenerator.generateHapticFeedback(.mediumImpact)
                    return true
                } else {
                    handleAlertAction(message: "You’ve swiped 25 cards today. There’s a lot more waiting for you. Ready to see them? Let's upgrade account now. Otherwise, come back here tomorrow.")
                    return false
                }
            }
        }
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        guard let viewer = viewer else { return }
        if viewer.checkVipStatus {
            didSwipeCardAt(index: index, in: direction, with: viewer)
        } else {
            if viewer.numberOfSwipes < appConfig.numberOfSwipes {
                didSwipeCardAt(index: index, in: direction, with: viewer)
                self.viewer?.increaseNumberOfSwipes()
            } else {
                if Date() > (self.viewer?.limitedTime?.convertToDate ?? Date()) {
                    didSwipeCardAt(index: index, in: direction, with: viewer)
                    // This time is also counted as 1 swipe
                    self.viewer?.numberOfSwipes = 1
                }
            }
        }
    }
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {}

    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            self.editProfileManager?.updateNumberOfSwipes(profile: self.viewer) { _ in
                self.handleErrorAlert()
            }
        }
        
        if let viewer = viewer, let profile = dataSource.object(at: index) as? ATCDatingProfile {
            let vc = DatingProfileDetailsCollectionViewController(profile: profile,
                                                                  viewer: viewer,
                                                                  uiConfig: uiConfig,
                                                                  hostViewController: self)
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        }
    }

    func koloda(_ koloda: KolodaView, didShowCardAt index: Int) {

    }

    func koloda(_ koloda: KolodaView, allowedDirectionsForIndex index: Int) -> [SwipeResultDirection] {
        return [.up, .left, .right]
    }
}

extension DatingFeedViewController: KolodaViewDataSource {
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return dataSource.numberOfObjects()
    }

    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .fast
    }

    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        if let profile = dataSource.object(at: index) as? ATCDatingProfile, let viewer = viewer {
            if let previousVC = viewControllers[index] {
                return previousVC.view
            }
            let feedItemVC = DatingFeedItemViewController(profile: profile,
                                                          viewer: viewer,
                                                          uiConfig: uiConfig,
                                                          reportingManager: reportingManager)
            feedItemVC.delegate = self
            self.addChildViewControllerWithView(feedItemVC)
            viewControllers[index] = feedItemVC
            return feedItemVC.view
        }
        return UIView()
    }

    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return nil
    }
}
extension DatingFeedViewController: ATCDatingProfileEditManagerDelegate {
    func profileEditManager(_ manager: ATCDatingProfileEditManager, didFetch datingProfile: ATCDatingProfile) {
        self.viewer = datingProfile
    }
    
    func profileEditManager(_ manager: ATCDatingProfileEditManager, didUpdateProfile success: Bool) {}
}

extension DatingFeedViewController: ATCUpgradeAccountDelegate, ATCInAppPurchaseDelegate {
    
    // This method is called when finishing subscriptions from DatingFeedViewController
    func didFinishSubscription(with selectedSubscription: ATCSubscription?, completionHandler: @escaping (Error?) -> Void) {
        
        purchaseProduct(with: selectedSubscription) { (error) in
            if error != nil {
                completionHandler(error)
            } else {
                self.editProfileManager?.updateVipAccount(profile: self.viewer,
                                                          isVipAccount: true,
                                                          startVipAccountDate: selectedSubscription?.startDate,
                                                          endVipAccountDate: selectedSubscription?.endDate) { [weak self] (error) in
                                                            guard let self = self else { return }
                                                            if error == nil {
                                                                self.editProfileManager?.fetchDatingProfile(for: self.viewer)
                                                            }
                                                            completionHandler(error)
                }
            }
        }
    }
}
// MARK: - Handle alert action
extension DatingFeedViewController {
    private func handleAlertAction(message: String) {
        alertWithTwoOptions(title: "Pardon the interruption.",
                            message: message,
                            nextStepTitle: "Upgrade Now") { [weak self] _ in
                                guard let self = self else { return }
                                let upgradeAccountViewController = ATCUpgradeAccountViewController(appConfig: self.appConfig,
                                                                                                   uiConfig: self.uiConfig)
                                upgradeAccountViewController.delegate = self
                                self.navigationController?.present(upgradeAccountViewController, animated: true)
        }
    }
    
    private func handleErrorAlert() {
        alert(title: "Error", message: "Oops, something went wrong when saving your data. Please try again.")
    }
}

extension DatingFeedViewController: DatingFeedItemDelegate {
    func didTapUndoButton() {
        if let viewer = self.viewer, viewer.checkVipStatus {
            kolodaView.revertAction()
        } else {
            handleAlertAction(message: "Don't lose this amazing friend just because you accidentally swiped left. Upgrade your account now to see them again.")
        }
    }
}
