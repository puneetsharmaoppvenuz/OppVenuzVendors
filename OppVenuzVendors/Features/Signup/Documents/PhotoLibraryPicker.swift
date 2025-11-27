//
//  PhotoLibraryPicker.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 21/11/25.
//

import SwiftUI
import UIKit

struct PhotoLibraryPicker {
    
    private static var retainDelegate: PhotoDelegate?
    
    static func show(onPicked: @escaping (UIImage?) -> Void) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        
        let delegate = PhotoDelegate(onPicked: onPicked)
        retainDelegate = delegate
        picker.delegate = delegate
        
        UIApplication.shared.topMostViewController?.present(picker, animated: true)
    }
    
    final class PhotoDelegate: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        let onPicked: (UIImage?) -> Void
        init(onPicked: @escaping (UIImage?) -> Void) { self.onPicked = onPicked }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
            onPicked(nil)
            PhotoLibraryPicker.retainDelegate = nil
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let img = info[.originalImage] as? UIImage
            picker.dismiss(animated: true)
            onPicked(img)
            PhotoLibraryPicker.retainDelegate = nil
        }
    }
}

