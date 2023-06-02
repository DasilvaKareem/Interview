//
//  DatingMyVideosViewController.swift
//  Pods
//
//  Created by Kareem Dasilva on 5/30/23.
//

import Photos
import AVKit
import MobileCoreServices
import UIKit

class DatingMyVideosViewController: ATCGenericCollectionViewController {
    var profileUpdater: ATCProfileUpdaterProtocol
    var user: ATCUser

    init(user: ATCUser,
         uiConfig: ATCUIGenericConfigurationProtocol,
         profileUpdater: ATCProfileUpdaterProtocol) {

        self.profileUpdater = profileUpdater
        self.user = user

        let igLayout = ATCCollectionViewFlowLayout()
        igLayout.scrollDirection = .horizontal
        igLayout.minimumInteritemSpacing = 0
        igLayout.minimumLineSpacing = 10
        let emptyViewModel = CPKEmptyViewModel(image: nil,
                                               title: "No Photos".localizedInApp,
                                               description: "Add some photos to let people find you.".localizedInApp,
                                               callToAction: nil)
        let igPhotoVCConfig = ATCGenericCollectionViewControllerConfiguration (
            pullToRefreshEnabled: false,
            pullToRefreshTintColor: uiConfig.mainThemeBackgroundColor,
            collectionViewBackgroundColor: uiConfig.mainThemeBackgroundColor,
            collectionViewLayout: igLayout,
            collectionPagingEnabled: true,
            hideScrollIndicators: true,
            hidesNavigationBar: false,
            headerNibName: nil,
            scrollEnabled: true,
            uiConfig: uiConfig,
            emptyViewModel: emptyViewModel)
        var items: [ATCImage] = []
        if let igPhotos = user.photos {
            items = igPhotos.map({ATCImage($0)})
        }
        let actionImage = ATCImage(localImage: UIImage.localImage("camera-filled-icon-large", template: true))
        actionImage.isActionable = true
        items.append(actionImage)

        super.init(configuration: igPhotoVCConfig)

        let size: (CGRect) -> CGSize = { bounds in
            let dimension = (bounds.width - 3 * 10) / 3
            return CGSize(width: dimension, height: dimension)
        }
        self.use(adapter: ATCImageRowAdapter(cornerRadius: 10.0,
                                             size: size,
                                             tintColor: .white,
                                             bgColor: uiConfig.mainThemeForegroundColor),
                 for: "ATCImage")
        self.genericDataSource = ATCGenericLocalDataSource<ATCImage>(items: items)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectionBlock =  {[weak self] (navigationController, object, indexPath) in
            guard let `self` = self else { return }
            if let viewModel = object as? ATCImage {
                if !viewModel.isActionable {
                    let vc = self.removeImageAlertController(image: viewModel, index: indexPath.row)
                    self.parent?.present(vc, animated: true)
                } else {
                    let vc = self.addImageAlertController()
                    self.parent?.present(vc, animated: true)
                }
            }
        }
    }

    private func removeImageAlertController(image: ATCImage, index: Int) -> UIAlertController {
        let alert = UIAlertController(title: "Remove photo".localizedInApp, message: "", preferredStyle: UIAlertController.Style.actionSheet)
        alert.addAction(UIAlertAction(title: "Remove Photo".localizedInApp, style: .destructive, handler: {[weak self] (action) in
            guard let strongSelf = self else { return }
            strongSelf.didTapRemoveImageButton(image: image, index: index)
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localizedCore, style: .cancel, handler: nil))
        if let popoverPresentationController = alert.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = self.view.bounds
        }
        return alert
    }

    private func didTapRemoveImageButton(image: ATCImage, index: Int) {
        if let url = image.urlString {
            let hud = CPKProgressHUD.progressHUD(style: .loading(text: "Sending".localizedInApp))
            hud.show(in: view)
            profileUpdater.removePhoto(url: url, user: user) {
                hud.dismiss()
                if let ds = self.genericDataSource as? ATCGenericLocalDataSource<ATCImage> {
                    ds.items = ds.items.filter({$0.urlString != url})
                    self.collectionView?.reloadData()
                }
            }
        }
    }

    private func addImageAlertController() -> UIAlertController {
        let alert = UIAlertController(title: "Add Photo".localizedInApp, message: "", preferredStyle: UIAlertController.Style.actionSheet)
        alert.addAction(UIAlertAction(title: "Import from Library".localizedInApp, style: .default, handler: {[weak self] (action) in
            guard let strongSelf = self else { return }
            strongSelf.didTapAddImageButton(sourceType: .photoLibrary)
        }))
        alert.addAction(UIAlertAction(title: "Take Photo".localizedInApp, style: .default, handler: {[weak self] (action) in
            guard let strongSelf = self else { return }
            strongSelf.didTapAddImageButton(sourceType: .camera)
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localizedCore, style: .cancel, handler: nil))

        if let popoverPresentationController = alert.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = self.view.bounds
        }
        return alert
    }

    private func didTapAddImageButton(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
              picker.delegate = self
              picker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]

              if UIImagePickerController.isSourceTypeAvailable(sourceType) {
                  picker.sourceType = sourceType
              } else {
                  return
              }

              present(picker, animated: true, completion: nil)
    }

    fileprivate func didAddImage(_ image: UIImage) {
        let hud = CPKProgressHUD.progressHUD(style: .loading(text: "Sending".localizedInApp))
        hud.show(in: view)
        profileUpdater.uploadPhoto(image: image, user: user, isProfilePhoto: false) { (success) in
            hud.dismiss()
            if let ds = self.genericDataSource as? ATCGenericLocalDataSource<ATCImage> {
                ds.items.insert(ATCImage(localImage: image), at: ds.items.count - 1)
                self.collectionView?.reloadData()
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension DatingMyPhotosViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)

                if let mediaType = info[.mediaType] as? String {
                    if mediaType == kUTTypeMovie as String {
                        if let videoURL = info[.mediaURL] as? URL {
                           didAddVideo(videoURL)
                            
                        }
                    } else if mediaType == kUTTypeImage as String {
                        if let asset = info[.phAsset] as? PHAsset {
                            let size = CGSize(width: 500, height: 500)
                            PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: nil) { result, info in
                                guard let image = result else {
                                    return
                                }
                                self.didAddImage(image)
                            }
                        } else if let image = info[.originalImage] as? UIImage {
                            didAddImage(image)
                        }
                    }
                }
    
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
