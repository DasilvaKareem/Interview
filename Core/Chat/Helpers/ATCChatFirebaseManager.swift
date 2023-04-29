//
//  ATCChatFirebaseManager.swift
//  ChatApp
//
//  Created by Florian Marcu on 9/15/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import FirebaseFirestore

class ATCChatFirebaseManager {
    static func fetchChannels(user: ATCUser, completion: @escaping (_ channels: [ATCChatChannel]) -> Void) {
        guard let uid = user.uid else { return }
        ATCFirebaseUserReporter().userIDsBlockedOrReported(by: user) { (illegalUserIDsSet) in
            let ref = Firestore.firestore().collection("channel_participation").whereField("user", isEqualTo: uid)
            let channelsRef = Firestore.firestore().collection("channels")
            let usersRef = Firestore.firestore().collection("users")
            ref.getDocuments { (querySnapshot, error) in
                if error != nil {
                    completion([])
                    return
                }
                guard let querySnapshot = querySnapshot else { return }
                var channels: [ATCChatChannel] = []
                let documents = querySnapshot.documents
                if (documents.count == 0) {
                    completion([])
                    return
                }
                for document in documents {
                    let data = document.data()
                    if let channelID = data["channel"] as? String {
                        channelsRef
                            .document(channelID)
                            .getDocument(completion: { (document, error) in
                                if let document = document, var channel = ATCChatChannel(document: document) {
                                    let otherUsers = Firestore.firestore().collection("channel_participation").whereField("channel", isEqualTo: channel.id)
                                    otherUsers.getDocuments(completion: { (snapshot, error) in
                                        guard let snapshot = snapshot else { return }
                                        let docs = snapshot.documents
                                        var participants: [ATCUser] = []
                                        if docs.count == 0 {
                                            completion([])
                                            return
                                        }
                                        for doc in docs {
                                            let data = doc.data()
                                            if let userID = data["user"] as? String {
                                                usersRef
                                                    .document(userID)
                                                    .getDocument(completion: { (document, error) in
                                                        if let document = document,
                                                            let rep = document.data() {
                                                            let participant = ATCUser(representation: rep)
                                                            if channel.groupCreatorID == user.uid {
                                                                participant.isAdmin = true
                                                            }
                                                            if let isAdmin = data["isAdmin"] as? Bool {
                                                                participant.isAdmin = isAdmin
                                                            }
                                                            participants.append(participant)
                                                            if participants.count == docs.count {
                                                                channel.participants = participants
                                                                
                                                                channels.append(channel)
                                                                if channels.count == documents.count {
                                                                    completion(self.sort(channels: self.filter(channels: channels, illegalUserIDsSet: illegalUserIDsSet)))
                                                                }
                                                            }
                                                        }
                                                    })
                                            }
                                        }
                                    })
                                } else {
                                    completion([])
                                    return
                                }
                            })
                    } else {
                        completion([])
                        return
                    }
                }
            }
        }
    }

    static func createChannel(creator: ATCUser, friends: Set<ATCUser>, completion: @escaping (_ channel: ATCChatChannel?) -> Void) {
        guard let uid = creator.uid else { return }
        let channelParticipationRef = Firestore.firestore().collection("channel_participation")
        let channelsRef = Firestore.firestore().collection("channels")

        let newChannelRef = channelsRef.document()
        let channelDict: [String: Any] = [
            "lastMessage": "No message",
            "name": "New Group",
            "creatorID": uid,
            "channelID": newChannelRef.documentID,
            "id": newChannelRef.documentID
        ]
        newChannelRef.setData(channelDict)

        let allFriends = [creator] + Array(friends)
        var count = 0
        allFriends.forEach { (friend) in
            let doc: [String: Any] = [
                "channel": newChannelRef.documentID,
                "user": friend.uid ?? "",
                "isAdmin": friend.uid == creator.uid
            ]
            channelParticipationRef.addDocument(data: doc, completion: { (error) in
                count += 1
                if count == allFriends.count {
                    newChannelRef.getDocument(completion: { (snapshot, error) in
                        guard let snapshot = snapshot else { return }
                        completion(ATCChatChannel(document: snapshot))
                    })
                }
            })
        }
    }
    
    static func addNewMembersToChannel(creator: ATCUser, channel: ATCChatChannel, friends: Set<ATCUser>, completion: @escaping (_ friends: [ATCUser]) -> Void) {
        let channelParticipationRef = Firestore.firestore().collection("channel_participation")
        let allFriends = Array(friends)
        var count = 0
        allFriends.forEach { (friend) in
            let doc: [String: Any] = [
                "channel": channel.id,
                "user": friend.uid ?? "",
                "isAdmin": friend.uid == creator.uid
            ]
            channelParticipationRef.addDocument(data: doc, completion: { (error) in
                count += 1
                if count == allFriends.count {
                    completion(allFriends)
                }
            })
        }
    }

    static func renameGroup(channel: ATCChatChannel, name: String) {
        let data: [String : Any] = [
            "name": name
        ]
        Firestore.firestore().collection("channels").document(channel.id).setData(data, merge: true)
    }

    static func leaveGroup(channel: ATCChatChannel, user: ATCUser) {
        guard let uid = user.uid else {
            return
        }
        let ref = Firestore.firestore().collection("channel_participation").whereField("user", isEqualTo: uid).whereField("channel", isEqualTo: channel.id)
        ref.getDocuments { (snapshot, error) in
            if let snapshot = snapshot {
                snapshot.documents.forEach({ (document) in
                    Firestore.firestore().collection("channel_participation").document(document.documentID).delete()
                })
            }
        }
    }

    static func updateGroupMemberRole(isAdmin: Bool, channel: ATCChatChannel, user: ATCUser) {
        guard let uid = user.uid else {
            return
        }
        let ref = Firestore.firestore().collection("channel_participation").whereField("user", isEqualTo: uid).whereField("channel", isEqualTo: channel.id)
        ref.getDocuments { (snapshot, error) in
            if let snapshot = snapshot {
                snapshot.documents.forEach({ (document) in
                   
                    let data: [String : Any] = [
                        "isAdmin": isAdmin
                    ]
                    Firestore
                        .firestore()
                        .collection("channel_participation")
                        .document(document.documentID)
                        .setData(data, merge: true)
                })
            }
        }
    }
    
    static func removeGroupMember(channel: ATCChatChannel, user: ATCUser) {
        guard let uid = user.uid else {
            return
        }
        let ref = Firestore.firestore().collection("channel_participation").whereField("user", isEqualTo: uid).whereField("channel", isEqualTo: channel.id)
        ref.getDocuments { (snapshot, error) in
            if let snapshot = snapshot {
                snapshot.documents.forEach({ (document) in
                    Firestore
                        .firestore()
                        .collection("channel_participation")
                        .document(document.documentID)
                        .delete()
                })
            }
        }
    }

    static func updateChannelParticipationIfNeeded(channel: ATCChatChannel) {
        if channel.participants.count != 2 {
            return
        }
        guard let uid1 = channel.participants.first?.uid, let uid2 = channel.participants[1].uid else { return }
        self.updateChannelParticipationIfNeeded(channel: channel, uID: uid1)
        self.updateChannelParticipationIfNeeded(channel: channel, uID: uid2)
    }

    private static func updateChannelParticipationIfNeeded(channel: ATCChatChannel, uID: String) {
        let ref1 = Firestore.firestore().collection("channel_participation").whereField("user", isEqualTo: uID).whereField("channel", isEqualTo: channel.id)
        ref1.getDocuments { (querySnapshot, error) in
            if (querySnapshot?.documents.count == 0) {
                let data: [String: Any] = [
                    "user": uID,
                    "channel": channel.id
                ]
                Firestore.firestore().collection("channel_participation").addDocument(data: data, completion: nil)
            }
        }
    }
    static func sort(channels: [ATCChatChannel]) -> [ATCChatChannel] {
        let sortedChannels = channels.sorted(by: {$0.lastMessageDate > $1.lastMessageDate})
        var channels: [ATCChatChannel] = []
        for var channel in sortedChannels {
            channel.participants = removeParticipantDuplicates(channel.participants)
            channels.append(channel)
        }
        return channels
    }

    static func removeParticipantDuplicates(_ participants: [ATCUser]) -> [ATCUser] {
        var noDuplicates = [ATCUser]()
        var usedIDs = [String]()
        for participant in participants {
            if let id = participant.uid, !usedIDs.contains(id) {
                noDuplicates.append(participant)
                usedIDs.append(id)
            }
        }
        return noDuplicates
    }
    
    static func filter(channels: [ATCChatChannel], illegalUserIDsSet: Set<String>) -> [ATCChatChannel] {
        var validChannels: [ATCChatChannel] = []
        channels.forEach { (channel) in
            if !channel.participants.contains(where: { (user) -> Bool in
                return illegalUserIDsSet.contains(user.uid ?? "")
            }) {
                validChannels.append(channel)
            }
        }
        return validChannels
    }
}
