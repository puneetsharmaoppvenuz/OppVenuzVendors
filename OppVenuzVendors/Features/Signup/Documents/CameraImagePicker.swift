//
//  CameraImagePicker.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 21/11/25.
//

import SwiftUI
import UIKit

struct CameraImagePicker {
    
    private static var retainDelegate: CameraDelegate?
    
    static func show(onPicked: @escaping (UIImage?) -> Void) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            onPicked(nil)
            return
        }
        
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = false
        
        let delegate = CameraDelegate(onPicked: onPicked)
        retainDelegate = delegate              // keep strong ref
        picker.delegate = delegate
        picker.modalPresentationStyle = .fullScreen
        
        UIApplication.shared.topMostViewController?.present(picker, animated: true)
    }
    
    final class CameraDelegate: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        let onPicked: (UIImage?) -> Void
        init(onPicked: @escaping (UIImage?) -> Void) { self.onPicked = onPicked }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
            onPicked(nil)
            CameraImagePicker.retainDelegate = nil
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let img = info[.originalImage] as? UIImage
            picker.dismiss(animated: true)
            onPicked(img)
            CameraImagePicker.retainDelegate = nil
        }
    }
}
