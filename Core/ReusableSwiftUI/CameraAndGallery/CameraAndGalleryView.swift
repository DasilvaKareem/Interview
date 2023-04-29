//
//  CameraAndGalleryView.swift
//  FitnessApp
//
//  Copyright © 2020 iOSAppTemplates. All rights reserved.
//

import SwiftUI

struct CameraAndGalleryView {
  
  /// MARK: - Properties
  @Binding var isShown: Bool
  @Binding var image: Image?
  
  func makeCoordinator() -> Coordinator {
    return Coordinator(isShown: $isShown, image: $image)
  }
}

extension CameraAndGalleryView: UIViewControllerRepresentable {
  func makeUIViewController(context: UIViewControllerRepresentableContext<CameraAndGalleryView>) -> UIImagePickerController {
    let picker = UIImagePickerController()
    picker.delegate = context.coordinator
    /// Default is images gallery. Un-comment the next line of code if you would like to test camera
//    picker.sourceType = .camera
    return picker
  }
  
  func updateUIViewController(_ uiViewController: UIImagePickerController,
                              context: UIViewControllerRepresentableContext<CameraAndGalleryView>) {
    
  }
}
