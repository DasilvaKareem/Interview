//
//  AppDelegate.swift
//  DatingApp
//
//  Created by Florian Marcu on 1/23/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import Firebase
import FirebaseMessaging
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure the UI
        let config = DatingUIConfiguration()
        config.configureUI()

        let appConfig = DatingAppConfiguration()

        if (appConfig.isFirebaseAuthEnabled || appConfig.isFirebaseDatabaseEnabled) {
            FirebaseApp.configure()
        }

        let datingDataSource: ATCDatingFeedDataSource = (appConfig.isFirebaseDatabaseEnabled ?
            ATCDatingFeedFirebaseDataSource() :
            ATCDatingFeedMockDataSource())

        let swipeManager: ATCDatingSwipeManager? = (appConfig.isFirebaseDatabaseEnabled ?
            ATCDatingFirebaseSwipeManager() :
            nil
        )

        let editProfileManager: ATCDatingProfileEditManager? = (appConfig.isFirebaseDatabaseEnabled ?
            ATCDatingFirebaseProfileEditManager() :
            nil
        )

        let profileUpdater: ATCProfileUpdaterProtocol? = (appConfig.isFirebaseDatabaseEnabled ?
            ATCProfileFirebaseUpdater(usersTable: "users") :
            nil)
        
        let userManager: ATCSocialFirebaseUserManager? = (appConfig.isFirebaseDatabaseEnabled ?
            ATCSocialFirebaseUserManager() :
            nil)
        
        let instagramConfig: ATCInstagramConfig? = (appConfig.isInstagramIntegrationEnabled ?
            ATCInstagramConfig(clientID: "bd6324b5644146debf482287f00e5be2",
                               redirectURL: "https://www.iosapptemplates.com/redirect") :
            nil)

        let reportingManager = ATCFirebaseUserReporter()
        let viewer: ATCDatingProfile? = (appConfig.isFirebaseDatabaseEnabled) ? nil : ATCDatingFeedMockDataSource.mockProfiles[0]

        ATCIAPService.shared.startObserving()
        // Window setup
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = DatingHostViewController(uiConfig: config,
                                                              appConfig: appConfig,
                                                              datingFeedDataSource: datingDataSource,
                                                              swipeManager: swipeManager,
                                                              editProfileManager: editProfileManager,
                                                              profileUpdater: profileUpdater,
                                                              instagramConfig: instagramConfig,
                                                              reportingManager: reportingManager,
                                                              userManager: userManager,
                                                              viewer: viewer,
                                                              chatServiceConfig: DatingChatServiceConfig())
        window?.makeKeyAndVisible()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        ATCIAPService.shared.stopObserving()
    }
    //
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
}

