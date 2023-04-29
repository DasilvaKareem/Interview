//
//  ATCOnlinePresenceTracker.swift
//  ChatApp
//
//  Created by Mac  on 18/01/20.
//  Copyright © 2020 Instamobile. All rights reserved.
//

import UIKit

struct kUserOnlinePresenceConfig {
    static let kUserOnlinePresenceThresholdInSeconds: TimeInterval = 60.0
}

class ATCOnlinePresenceTracker {
    
    var viewer: ATCUser?
    var userOnlinePresenceUpdateTimer: Timer? = nil
    let profileManager: ATCProfileManager?

    init(viewer: ATCUser?, profileManager: ATCProfileManager?) {
        self.viewer = viewer
        self.profileManager = profileManager
        NotificationCenter.default.addObserver(self, selector: #selector(stopTracking), name: kLogoutNotificationName, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func startTracking() {
        self.userOnlinePresenceUpdate()
        self.startUserOnlinePresenceUpdateTimer()
    }
    
    @objc func stopTracking() {
        if let userOnlinePresenceUpdateTimer = userOnlinePresenceUpdateTimer {
            self.stopTimer(userOnlinePresenceUpdateTimer)
        }
        self.updateUserPresence(isOnline: false)
    }
    
    private func startUserOnlinePresenceUpdateTimer() {
        DispatchQueue.main.async {
            self.userOnlinePresenceUpdateTimer = Timer.scheduledTimer(timeInterval: kUserOnlinePresenceConfig.kUserOnlinePresenceThresholdInSeconds, target: self, selector: #selector(self.userOnlinePresenceUpdate), userInfo: nil, repeats: true)
        }
    }
    
    @objc private func userOnlinePresenceUpdate() {
        self.updateUserPresence(isOnline: true)
        NotificationCenter.default.post(name: kFriendsPresenceUpdateNotificationName, object: nil)
    }
    
    private func stopTimer(_ timer: Timer) {
        timer.invalidate()
    }
    
    private func updateUserPresence(isOnline: Bool) {
        if let user = viewer {
            self.profileManager?.updateUserPresence(profile: user, isOnline: isOnline)
        }
    }
}
