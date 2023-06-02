//
//  ATCProfileFirebaseUpdated.swift
//  DatingApp
//
//  Created by Florian Marcu on 2/2/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import FirebaseFirestore
import FirebaseStorage
import UIKit
import AVFoundation

class ATCProfileFirebaseUpdater: ATCProfileUpdaterProtocol {
    var updateInProgress: Bool = false

    var usersTable: String
    init(usersTable: String) {
        self.usersTable = usersTable
    }

    func removePhoto(url: String, user: ATCUser, completion: @escaping () -> Void) {

        guard let uid = user.uid else { return }
        if let photos = user.photos {
            let remainingPhotos = photos.filter({$0 != url})
            Firestore
                .firestore()
                .collection(self.usersTable)
                .document(uid)
                .setData(["photos": remainingPhotos], merge: true, completion: { (error) in
                    user.photos = remainingPhotos
                    completion()
                })
        }
    }

    func uploadPhoto(image: UIImage, user: ATCUser, isProfilePhoto: Bool, completion: @escaping (_ success: Bool) -> Void) {
        self.uploadImage(image, completion: {[weak self] (url) in
            guard let `self` = self, let url = url?.absoluteString, let uid = user.uid else {
                completion(false)
                return
            }
            var photos: [String] = (user.photos ?? []) + [url]
            if photos.count == 0 && isProfilePhoto {
                photos = [url]
            }
            let data = ((isProfilePhoto) ?
                ["photos": photos, "profilePictureURL": url] :
                ["photos": photos])
            Firestore
                .firestore()
                .collection(self.usersTable)
                .document(uid)
                .setData(data, merge: true, completion: { (error) in
                    user.photos = photos
                    if (isProfilePhoto) {
                        user.profilePictureURL = url
                    }
                    completion(true)
                })
        })
    }
  
    func uploadVideo(videoURL: URL, user: ATCUser, isProfileVideo: Bool, completion: @escaping (_ success: Bool) -> Void) {
        
        var thumbnailURL:String?
        
        do {
            let asset = AVURLAsset(url: videoURL, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            self.uploadImage(thumbnail, completion: {[weak self] (url) in
                guard let `self` = self, let url = url?.absoluteString, let uid = user.uid else {
                    completion(false)
                    return
                }
                thumbnailURL = url
            })
        } catch {
            thumbnailURL = ""
        }
        
        self.uploadFile(fileURL: videoURL, completion: { [weak self] (url) in
            guard let self = self, let videoURL = url?.absoluteString, let uid = user.uid else {
                completion(false)
                return
            }
            
            var videos: [String] = (user.videos ?? []) + [videoURL]
            if videos.count == 0 && isProfileVideo {
                videos = [videoURL]
            }
      
            let data = ((isProfileVideo) ?
                ["videos": videos, "profileVideoURL": videoURL, "Thumbnail":thumbnailURL] :
                ["videos": videos])
            
            Firestore.firestore().collection(self.usersTable).document(uid).setData(data, merge: true) { error in
                user.videos = videos
                if isProfileVideo {
                   // user.profileVideoURL = videoURL
                }
                completion(error == nil)
            }
        })
    }

    private func uploadFile(fileURL: URL, completion: @escaping (_ url: URL?) -> Void) {
        let storageRef = Storage.storage().reference().child("videos").child(UUID().uuidString + ".mov")
        let metadata = StorageMetadata()
        metadata.contentType = "video/quicktime" // Change the content type according to your video format
        
        let uploadTask = storageRef.putFile(from: fileURL, metadata: metadata) { (metadata, error) in
            if let error = error {
                print("Error uploading video: \(error.localizedDescription)")
                completion(nil)
            } else {
                storageRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        print("Error getting download URL: \(error?.localizedDescription ?? "")")
                        completion(nil)
                        return
                    }
                    completion(downloadURL)
                }
            }
        }
        
        // Observe progress changes if needed
        uploadTask.observe(.progress) { snapshot in
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            print("Upload progress: \(percentComplete)%")
        }
    }

    func update(user: ATCUser, email: String, firstName: String, lastName: String, username: String, completion: @escaping (_ success: Bool) -> Void) {
        guard let uid = user.uid else { return }
        let usersRef = Firestore.firestore().collection(usersTable).document(uid)
        let data: [String: Any] = [
            "lastName": lastName,
            "firstName": firstName,
            "username": username,
            "email": email
        ]
        usersRef.setData(data, merge: true) { (error) in
            user.lastName = lastName
            user.firstName = firstName
            user.username = username
            user.email = email
            NotificationCenter.default.post(name: kATCLoggedInUserDataDidChangeNotification, object: nil)
            completion(error == nil)
        }
    }

    func updateLocation(for user: ATCUser, to location: ATCLocation, completion: @escaping (_ success: Bool) -> Void) {
        if updateInProgress {
            return
        }
        guard let uid = user.uid else { return }
        let usersRef = Firestore.firestore().collection(usersTable).document(uid)
        let data: [String: Any] = [
            "location": location.representation,
        ]
        updateInProgress = true
        usersRef.setData(data, merge: true) { (error) in
            self.updateInProgress = false
            completion(error == nil)
        }
    }

    private func uploadImage(_ image: UIImage, completion: @escaping (URL?) -> Void) {
        let storage = Storage.storage().reference()

        guard let scaledImage = image.scaledToSafeUploadSize, let data = scaledImage.jpegData(compressionQuality: 0.4) else {
            completion(nil)
            return
        }

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        let imageName = [UUID().uuidString, String(Date().timeIntervalSince1970)].joined()
        let ref = storage.child(usersTable).child(imageName)
        ref.putData(data, metadata: metadata) { meta, error in
            ref.downloadURL { (url, error) in
                completion(url)
            }
        }
    }
}
