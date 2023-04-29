//
//  DatingHostViewController.swift
//  DatingApp
//
//  Created by Florian Marcu on 1/23/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit
import SwiftUI

class DatingHostViewController: UIViewController, UITabBarControllerDelegate {
    
    let homeVC: DatingFeedViewController
    var profileVC: ATCProfileViewController?
    let uiConfig: ATCUIGenericConfigurationProtocol
    let appConfig: DatingInAppConfigurationProtocol
    let datingFeedDataSource: ATCDatingFeedDataSource
    let editProfileManager: ATCDatingProfileEditManager?
    let profileUpdater: ATCProfileUpdaterProtocol?
    let instagramConfig: ATCInstagramConfig?
    let userManager: ATCSocialFirebaseUserManager?
    let reportingManager: ATCUserReportingProtocol?
    let chatServiceConfig: ATCChatServiceConfigProtocol
    var viewer: ATCDatingProfile? = nil

    init(uiConfig: ATCUIGenericConfigurationProtocol,
         appConfig: DatingInAppConfigurationProtocol,
         datingFeedDataSource: ATCDatingFeedDataSource,
         swipeManager: ATCDatingSwipeManager? = nil,
         editProfileManager: ATCDatingProfileEditManager? = nil,
         profileUpdater: ATCProfileUpdaterProtocol? = nil,
         instagramConfig: ATCInstagramConfig? = nil,
         reportingManager: ATCUserReportingProtocol? = nil,
         userManager: ATCSocialFirebaseUserManager? = nil,
         viewer: ATCDatingProfile? = nil,
         chatServiceConfig: ATCChatServiceConfigProtocol) {
        self.uiConfig = uiConfig
        self.chatServiceConfig = chatServiceConfig
        self.appConfig = appConfig
        self.datingFeedDataSource = datingFeedDataSource
        self.editProfileManager = editProfileManager
        self.profileUpdater = profileUpdater
        self.instagramConfig = instagramConfig
        self.viewer = viewer
        self.reportingManager = reportingManager
        self.userManager = userManager
        self.homeVC = DatingFeedViewController(dataSource: datingFeedDataSource,
                                               uiConfig: uiConfig,
                                               reportingManager: reportingManager,
                                               swipeManager: swipeManager,
                                               chatServiceConfig: chatServiceConfig,
                                               editProfileManager: editProfileManager,
                                               appConfig: appConfig)
        
        if let viewer = viewer {
            self.homeVC.update(user: viewer)
        }
        super.init(nibName: nil, bundle: nil)
        self.profileVC = self.profileViewController()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var hostController: ATCHostViewController = { [unowned self] in
        let menuItems: [ATCNavigationItem] = [
            ATCNavigationItem(title: "Home".localizedCore,
                              viewController: homeVC,
                              image: UIImage.localImage("home-icon", template: true),
                              type: .viewController,
                              leftTopViews: nil,
                              rightTopViews: nil),
            ATCNavigationItem(title: "My Profile".localizedCore,
                              viewController: profileVC!,
                              image: UIImage.localImage("icn-instagram", template: true),
                              type: .viewController,
                              leftTopViews: nil,
                              rightTopViews: nil),
            ATCNavigationItem(title: "Logout".localizedCore,
                              viewController: UIViewController(),
                              image: UIImage.localImage("logout-menu-item", template: true),
                              type: .logout,
                              leftTopViews: nil,
                              rightTopViews: nil),
        ]
        let menuConfiguration = ATCMenuConfiguration(user: nil,
                                                     cellClass: ATCCircledIconMenuCollectionViewCell.self,
                                                     headerHeight: 0,
                                                     items: menuItems,
                                                     uiConfig: ATCMenuUIConfiguration(itemFont: uiConfig.regularMediumFont,
                                                                                      tintColor: uiConfig.mainTextColor,
                                                                                      itemHeight: 45.0,
                                                                                      backgroundColor: uiConfig.mainThemeBackgroundColor))
        
        let config = ATCHostConfiguration(menuConfiguration: menuConfiguration,
                                          style: .sideBar,
                                          topNavigationRightViews: [self.chatButton()],
                                          titleView: self.titleView(),
                                          topNavigationLeftImage: UIImage.localImage("person-filled-icon", template: true),
                                          topNavigationTintColor: UIColor(hexString: "#dadee5"),
                                          statusBarStyle: uiConfig.statusBarStyle,
                                          uiConfig: uiConfig,
                                          pushNotificationsEnabled: true,
                                          locationUpdatesEnabled: true)
        let onboardingCoordinator = self.onboardingCoordinator(uiConfig: uiConfig)
        let walkthroughVC = self.walkthroughVC(uiConfig: uiConfig)
        return ATCHostViewController(configuration: config,
                                     onboardingCoordinator: onboardingCoordinator,
                                     walkthroughVC: walkthroughVC,
                                     profilePresenter: nil,
                                     profileUpdater: profileUpdater)
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hostController.delegate = self
        self.addChildViewControllerWithView(hostController)
        hostController.view.backgroundColor = uiConfig.mainThemeBackgroundColor
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return uiConfig.statusBarStyle
    }
    
    fileprivate func onboardingCoordinator(uiConfig: ATCUIGenericConfigurationProtocol) -> ATCOnboardingCoordinatorProtocol {
        let landingViewModel = ATCLandingScreenViewModel(imageIcon: "fire-icon",
                                                         title: "Find your soul mate".localizedInApp,
                                                         subtitle: "Match and chat with people you like from your area.".localizedInApp,
                                                         loginString: "Log In".localizedInApp,
                                                         signUpString: "Sign Up".localizedInApp)
        let loginViewModel = ATCLoginScreenViewModel(contactPointField: "E-mail or phone number".localizedInApp,
                                                     passwordField: "Password".localizedInApp,
                                                     title: "Sign In".localizedInApp,
                                                     loginString: "Log In".localizedInApp,
                                                     facebookString: "Facebook Login".localizedInApp,
                                                     separatorString: "OR".localizedInApp,
                                                     forgotPasswordString: "Forgot Password".localizedInApp)
        
        let signUpViewModel = ATCSignUpScreenViewModel(nameField: "Full Name".localizedInApp,
                                                       phoneField: "Phone Number".localizedInApp,
                                                       emailField: "E-mail Address".localizedInApp,
                                                       passwordField: "Password".localizedInApp,
                                                       title: "Create new account".localizedInApp,
                                                       signUpString: "Sign Up".localizedInApp)
        
        let phoneLoginViewModel = ATCPhoneLoginScreenViewModel(contactPointField: "E-mail".localizedCore,
                                                               passwordField: "Password".localizedCore,
                                                               title: "Sign In".localizedCore,
                                                               loginString: "Log In".localizedCore,
                                                               sendCodeString: "Send Code".localizedCore,
                                                               submitCodeString: "Submit Code".localizedCore,
                                                               facebookString: "Facebook Login".localizedCore,
                                                               phoneNumberString: "Phone number".localizedCore,
                                                               phoneNumberLoginString: "Login with phone number".localizedCore,
                                                               emailLoginString: "Sign in with E-mail".localizedCore,
                                                               separatorString: "OR".localizedCore,
                                                               contactPoint: .email,
                                                               phoneCodeString: kPhoneVerificationConfig.phoneCode,
                                                               forgotPasswordString: "Forgot Password".localizedInApp)
        
        let phoneSignUpViewModel = ATCPhoneSignUpScreenViewModel(firstNameField: "First Name".localizedCore,
                                                                 lastNameField: "Last Name".localizedCore,
                                                                 phoneField: "Phone Number".localizedCore,
                                                                 emailField: "E-mail Address".localizedCore,
                                                                 passwordField: "Password".localizedCore,
                                                                 title: "Create new account".localizedCore,
                                                                 signUpString: "Sign Up".localizedCore,
                                                                 separatorString: "OR".localizedCore,
                                                                 contactPoint: .email,
                                                                 phoneNumberString: "Phone number".localizedCore,
                                                                 phoneNumberSignUpString: "Sign up with phone number".localizedCore,
                                                                 emailSignUpString: "Sign up with E-mail".localizedCore,
                                                                 sendCodeString: "Send Code".localizedCore,
                                                                 phoneCodeString: kPhoneVerificationConfig.phoneCode,
                                                                 submitCodeString: "Submit Code".localizedCore)
        
        let resetPasswordScreenViewModel = ATCResetPasswordScreenViewModel(title: "Reset Password".localizedCore,
                                                emailField: "E-mail Address".localizedCore,
                                                resetPasswordString: "Reset Password".localizedCore)
        
        return ATCClassicOnboardingCoordinator(landingViewModel: landingViewModel,
                                               loginViewModel: loginViewModel,
                                               phoneLoginViewModel: phoneLoginViewModel,
                                               signUpViewModel: signUpViewModel,
                                               phoneSignUpViewModel: phoneSignUpViewModel,
                                               resetPasswordViewModel: resetPasswordScreenViewModel,
                                               uiConfig: DatingOnboardingUIConfig(config: uiConfig),
                                               serverConfig: appConfig,
                                               userManager: userManager)
    }
    
    fileprivate func walkthroughVC(uiConfig: ATCUIGenericConfigurationProtocol) -> ATCWalkthroughViewController {
        let viewControllers = ATCWalkthroughStore.walkthroughs.map { ATCClassicWalkthroughViewController(model: $0, uiConfig: uiConfig, nibName: "ATCClassicWalkthroughViewController", bundle: nil) }
        return ATCWalkthroughViewController(nibName: "ATCWalkthroughViewController",
                                            bundle: nil,
                                            viewControllers: viewControllers,
                                            uiConfig: uiConfig)
    }
    
    fileprivate func profileViewController() -> ATCProfileViewController {
        
        return
            ATCProfileViewController(items: self.selfProfileItems(),
                                     uiConfig: uiConfig,
                                     selectionBlock: { (nav, model, index) in
                                        if let _ = model as? ATCProfileButtonItem {
                                            // Logout
                                            NotificationCenter.default.post(name: kLogoutNotificationName, object: nil)
                                        } else if let item = model as? ATCProfileItem {
                                            if item.title == "Settings".localizedInApp {
                                                let settingsVC = SettingsViewController(user: self.viewer)
                                                self.profileVC?.navigationController?.pushViewController(settingsVC, animated: true)
                                            } else if item.title == "Upgrade Account".localizedInApp {
                                                let upgradeAccountViewController = ATCUpgradeAccountViewController(appConfig: self.appConfig,
                                                                                                                   uiConfig: self.uiConfig)
                                                upgradeAccountViewController.delegate = self
                                                self.profileVC?.navigationController?.present(upgradeAccountViewController, animated: true)
                                            } else if item.title == "Cancel Subscription".localizedInApp {
                                                self.didTapCancelSubscriptionButton()
                                            } else if item.title == "Account Details".localizedInApp {
                                                if let viewer = self.viewer, let manager = self.editProfileManager {
                                                    let accountSettingsVC = ATCDatingAccountDetailsViewController(user: viewer,
                                                                                                                  manager: manager,
                                                                                                                  cancelEnabled: true)
                                                    let navController = UINavigationController(rootViewController: accountSettingsVC)
                                                    self.profileVC?.present(navController, animated: true, completion: nil)
                                                    //                                                    self.profileVC?.navigationController?.pushViewController(accountSettingsVC, animated: true)
                                                }
                                            } else if item.title == "Contact Us".localizedInApp {
                                                let contactVC = ATCSettingsContactUsViewController()
                                                self.profileVC?.navigationController?.pushViewController(contactVC, animated: true)
                                            } else if item.title == "Import Instagram Photos".localizedInApp {
                                                if let instagramConfig = self.instagramConfig {
                                                    let vc = ATCInstagramAuthenticatorViewController(config: instagramConfig)
                                                    self.profileVC?.navigationController?.pushViewController(vc, animated: true)
                                                }
                                            }
                                        }
            })
    }
    
    fileprivate func selfProfileItems() -> [ATCGenericBaseModel] {
        var items: [ATCGenericBaseModel] = []
        // If the user has logged in, add the photo carousel in self profile
        if let profile = self.viewer {
            let igPhotoVC = DatingMyPhotosViewController(user: profile, uiConfig: uiConfig, profileUpdater: ATCProfileFirebaseUpdater(usersTable: "users"))
            let cellHeight: CGFloat = ((profile.photos?.count ?? 0) > 2) ? 300.0 : 175.0
            let igPhotosPageViewModel = InstaMultiRowPageCarouselViewModel(title: "My Photos".localizedInApp, viewController: igPhotoVC, cellHeight: cellHeight)
            igPhotosPageViewModel.parentViewController = self.profileVC
            items.append(igPhotosPageViewModel)
        }
        
        // Add the remaining items, such as Account Details, Settings and Contact Us
        items.append(contentsOf: [ATCProfileItem(icon: UIImage.localImage("account-male-icon", template: true),
                                                 title: "Account Details".localizedInApp,
                                                 type: .arrow,
                                                 color: UIColor(hexString: "#6979F8")),
                                  //                ATCDivider(),
            //            ATCProfileItem(icon: UIImage.localImage("instagram-colored-icon", template: false),
            //                           title: "Import Instagram Photos",
            //                           type: .arrow,
            //                           color: UIColor(hexString: "#3F3356")),
            ATCProfileItem(icon: UIImage.localImage("dating-vip-icon", template: false),
                           title: ((self.viewer?.checkVipStatus ?? false) ? "Cancel Subscription" : "Upgrade Account").localizedInApp,
                           type: .arrow,
                           color: UIColor.clear),
            ATCProfileItem(icon: UIImage.localImage("settings-menu-item", template: true),
                           title: "Settings".localizedInApp,
                           type: .arrow,
                           color: UIColor(hexString: "#3F3356")),
            ATCProfileItem(icon: UIImage.localImage("contact-call-icon", template: true),
                           title: "Contact Us".localizedInApp,
                           type: .arrow,
                           color: UIColor(hexString: "#64E790"))
        ]);
        return items
    }
    
    fileprivate func chatButton() -> UIButton {
        let chatButton = UIButton()
        chatButton.configure(icon: UIImage.localImage("chat-filled-icon", template: true), color: UIColor(hexString: "#dadee5"))
        chatButton.snp.makeConstraints({ (maker) in
            maker.width.equalTo(60.0)
            maker.height.equalTo(60.0)
        })
        chatButton.layer.cornerRadius = 60.0 / 2
        chatButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: -20);
        chatButton.addTarget(self, action: #selector(didTapChatButton), for: .touchUpInside)
        return chatButton
    }
    
    fileprivate func titleView() -> UIView {
        let titleView = UIImageView(image: UIImage.localImage("fire-icon", template: true))
        titleView.snp.makeConstraints({ (maker) in
            maker.width.equalTo(30.0)
            maker.height.equalTo(30.0)
        })
        titleView.tintColor = uiConfig.mainThemeForegroundColor
        return titleView
    }
    
    @objc fileprivate func didTapChatButton() {
        guard let viewer = viewer else { return }
        let matchesDataSource: ATCDatingFeedDataSource = (appConfig.isFirebaseDatabaseEnabled ?
            ATCDatingFirebaseMatchesDataSource() :
            ATCDatingFeedMockDataSource())
        matchesDataSource.viewer = viewer
        matchesDataSource.loadFirst()
        let vc = ATCDatingChatHomeViewController.homeVC(uiConfig: uiConfig,
                                                        matchesDataSource: matchesDataSource,
                                                        threadsDataSource: ATCChatFirebaseChannelDataSource(),
                                                        reportingManager: reportingManager, chatServiceConfig: chatServiceConfig)
        vc.update(user: viewer)
        homeVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    fileprivate func didTapCancelSubscriptionButton() {
        let alert = UIAlertController(title: "Are you sure?".localizedChat, message: "If you cancel your subscription, you’ll lose access to Premium features".localizedChat, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel Subscription".localizedChat, style: .destructive, handler: {[weak self] (action) in
            guard let self = self, let profileOwner = self.viewer else { return }
            self.editProfileManager?.updateVipAccount(profile: profileOwner,
                                                      isVipAccount: false,
                                                      startVipAccountDate: nil,
                                                      endVipAccountDate: nil) { error in
                                                        if error == nil {
                                                            self.editProfileManager?.fetchDatingProfile(for: profileOwner)
                                                        } else {
                                                            self.alert(title: "Error", message: "Oop, something went wrong. Please try again.")
                                                        }
            }
        }))
        alert.addAction(UIAlertAction(title: "No, I'll cancel later".localizedChat, style: .default))
        self.present(alert, animated: true)
    }
}

extension DatingHostViewController: ATCHostViewControllerDelegate {
    func hostViewController(_ hostViewController: ATCHostViewController, didLogin user: ATCUser) {
        // Fetch the dating profile and then check if it's complete
        editProfileManager?.delegate = self
        editProfileManager?.fetchDatingProfile(for: user)
    }
    
    func hostViewController(_ hostViewController: ATCHostViewController, didSync user: ATCUser) {
        // Fetch the dating profile and then check if it's complete
        editProfileManager?.delegate = self
        editProfileManager?.fetchDatingProfile(for: user)
    }
}

class DatingOnboardingUIConfig: ATCOnboardingConfigurationProtocol {
    
    var otpTextFieldBackgroundColor: UIColor
    var otpTextFieldBorderColor: UIColor
    
    var backgroundColor: UIColor
    var titleColor: UIColor
    var titleFont: UIFont
    var logoTintColor: UIColor?
    
    var subtitleColor: UIColor
    var subtitleFont: UIFont
    
    var loginButtonFont: UIFont
    var loginButtonBackgroundColor: UIColor
    var loginButtonTextColor: UIColor
    
    var signUpButtonFont: UIFont
    var signUpButtonBackgroundColor: UIColor
    var signUpButtonTextColor: UIColor
    var signUpButtonBorderColor: UIColor
    
    var separatorFont: UIFont
    var separatorColor: UIColor
    
    var textFieldColor: UIColor
    var textFieldFont: UIFont
    var textFieldBorderColor: UIColor
    var textFieldBackgroundColor: UIColor
    
    var signUpTextFieldFont: UIFont
    var signUpScreenButtonFont: UIFont
    
    init(config: ATCUIGenericConfigurationProtocol) {
        backgroundColor = config.mainThemeBackgroundColor
        titleColor = config.mainThemeForegroundColor
        titleFont = config.boldSuperLargeFont
        logoTintColor = config.mainThemeForegroundColor
        subtitleFont = config.regularLargeFont
        subtitleColor = config.mainTextColor
        loginButtonFont = config.boldLargeFont
        loginButtonBackgroundColor = config.mainThemeForegroundColor
        loginButtonTextColor = config.mainThemeBackgroundColor
        signUpButtonFont = config.boldLargeFont
        signUpButtonBackgroundColor = config.mainThemeBackgroundColor
        signUpButtonTextColor = UIColor(hexString: "#eb5a6d")
        signUpButtonBorderColor = UIColor(hexString: "#B0B3C6")
        separatorColor = config.mainTextColor
        separatorFont = config.mediumBoldFont
        
        textFieldColor = UIColor(hexString: "#B0B3C6")
        textFieldFont = config.regularLargeFont
        textFieldBorderColor = UIColor(hexString: "#B0B3C6")
        textFieldBackgroundColor = config.mainThemeBackgroundColor
        
        signUpTextFieldFont = config.regularMediumFont
        signUpScreenButtonFont = config.mediumBoldFont
        
        otpTextFieldBackgroundColor = config.mainThemeBackgroundColor
        otpTextFieldBorderColor = UIColor(hexString: "#B0B3C6")
    }
}

extension DatingHostViewController: ATCDatingProfileEditManagerDelegate {
    func profileEditManager(_ manager: ATCDatingProfileEditManager, didFetch datingProfile: ATCDatingProfile) -> Void {
        self.viewer = datingProfile
        if datingProfile.gender == nil
            || datingProfile.genderPreference == nil
            || datingProfile.age == nil
            || datingProfile.school == nil
            || datingProfile.hasDefaultAvatar {
            let alertVC = UIAlertController(title: "Let's complete your dating profile".localizedInApp,
                                            message: "Welcome to Instaswipey. Let's complete your dating profile to allow other people to express interest in you.".localizedInApp,
                                            preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "Let's go".localizedInApp, style: .default, handler: { (action) in
                if datingProfile.hasDefaultAvatar {
                    // If there's no profile photo, show the Add Profile Photo step first
                    let addProfilePhotoVC = DatingAddProfilePhotoViewController(profileUpdater: self.profileUpdater,
                                                                                user: datingProfile,
                                                                                uiConfig: self.uiConfig)
                    addProfilePhotoVC.delegate = self
                    let navController = UINavigationController(rootViewController: addProfilePhotoVC)
                    self.present(navController, animated: true, completion: nil)
                } else {
                    // If there's already a profile photo, show the account details step first
                    if let viewer = self.viewer, let manager = self.editProfileManager {
                        let accountSettingsVC = ATCDatingAccountDetailsViewController(user: viewer,
                                                                                      manager: manager,
                                                                                      cancelEnabled: false)
                        accountSettingsVC.delegate = self
                        let navController = UINavigationController(rootViewController: accountSettingsVC)
                        self.present(navController, animated: true, completion: nil)
                    }
                }
            }))
            self.present(alertVC, animated: true, completion: nil)
        } else {
            if (self.homeVC.viewer == nil) {
                // only do this the first time, to not load recommendations multiple times
                self.homeVC.update(user: datingProfile)
            } else {
                self.homeVC.viewer = datingProfile
            }
            self.profileVC?.items = selfProfileItems()
            self.profileVC?.user = datingProfile
        }
    }
    
    func profileEditManager(_ manager: ATCDatingProfileEditManager, didUpdateProfile success: Bool) -> Void {}
}

extension DatingHostViewController: DatingAddProfilePhotoViewControllerDelegate {
    func addProfilePhotoDidCompleteIn(_ navigationController: UINavigationController?) {
        if let viewer = self.viewer, let manager = self.editProfileManager {
            let accountSettingsVC = ATCDatingAccountDetailsViewController(user: viewer,
                                                                          manager: manager,
                                                                          cancelEnabled: false)
            accountSettingsVC.delegate = self
            navigationController?.setViewControllers([accountSettingsVC], animated: true)
        }
    }
}

extension DatingHostViewController: ATCDatingAccountDetailsViewControllerDelegate {
    func accountDetailsVCDidUpdateProfile() -> Void {
        guard let user = self.viewer else { return }
        // We fetch the profile again, to make sure it's complete
        editProfileManager?.delegate = self
        editProfileManager?.fetchDatingProfile(for: user)
    }
}

extension DatingHostViewController: ATCUpgradeAccountDelegate, ATCInAppPurchaseDelegate {
    // This method is called when finishing subscriptions from MyProfile
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
                                                                self.editProfileManager?.delegate = self
                                                                self.editProfileManager?.fetchDatingProfile(for: self.viewer)
                                                            }
                                                            completionHandler(error)
                }
            }
        }
    }
}
