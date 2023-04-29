//
//  DatingAddProfilePhotoViewController.swift
//  DatingApp
//
//  Created by Florian Marcu on 3/6/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import Photos
import UIKit

protocol DatingAddProfilePhotoViewControllerDelegate: class {
    func addProfilePhotoDidCompleteIn(_ navigationController: UINavigationController?) -> Void
}

class DatingAddProfilePhotoViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var addButton: UIButton!
    @IBOutlet var containerView: UIView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var profileUpdater: ATCProfileUpdaterProtocol?
    var user: ATCUser
    var uiConfig: ATCUIGenericConfigurationProtocol
    weak var delegate: DatingAddProfilePhotoViewControllerDelegate?

    init(profileUpdater: ATCProfileUpdaterProtocol?, user: ATCUser, uiConfig: ATCUIGenericConfigurationProtocol) {
        self.profileUpdater = profileUpdater
        self.user = user
        self.uiConfig = uiConfig
        super.init(nibName: "DatingAddProfilePhotoViewController", bundle: nil)
        self.title = "Choose Profile Photo".localizedInApp
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
        addButton.setTitle("Add Profile Photo".localizedInApp, for: .normal)
        addButton.configure(color: UIColor.white,
                            font: uiConfig.boldFont(size: 14.0),
                            cornerRadius: 10,
                            borderColor: UIColor(hexString: "#ECEBED").darkModed,
                            backgroundColor: uiConfig.mainThemeForegroundColor,
                            borderWidth: 1.0)
        imageView.image = UIImage.localImage("camera-icon", template: true)
        imageView.tintColor = uiConfig.mainThemeForegroundColor
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        activityIndicator.isHidden = true
        containerView.backgroundColor = uiConfig.mainThemeBackgroundColor
    }

    @objc func didTapAddButton() {
        if self.addButton.title(for: .normal) == "Next".localizedInApp {
            self.delegate?.addProfilePhotoDidCompleteIn(self.navigationController)
        } else {
            let vc = addImageAlertController()
            self.present(vc, animated: true, completion: nil)
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

        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            picker.sourceType = sourceType
        } else {
            return
        }

        present(picker, animated: true, completion: nil)
    }

    fileprivate func didAddImage(_ image: UIImage) {
        activityIndicator.startAnimating()
        imageView.isHidden = true
        activityIndicator.isHidden = false
        profileUpdater?.uploadPhoto(image: image, user: user, isProfilePhoto: true) {[weak self] (success) in
            guard let `self` = self else { return }
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            self.imageView.isHidden = false
            
            if (success) {
                self.imageView.image = image
                self.addButton.setTitle("Next".localizedInApp, for: .normal)
            } else {
                self.showError(title: "Error uploading".localizedInApp, message: "The photo was not uploaded. Please check that your server accepts image uploads (e.g. is Firebase Storage enabled?).".localizedInApp)
            }
        }
    }

    fileprivate func showError(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK".localizedCore, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension DatingAddProfilePhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
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

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
