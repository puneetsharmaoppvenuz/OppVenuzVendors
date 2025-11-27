//
//  FilePicker.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 21/11/25.
//

import UIKit
import UniformTypeIdentifiers

struct FilePicker {
    
    private static var retainDelegate: FileDelegate?
    
    static func show(onPicked: @escaping (URL?) -> Void) {
        let types: [UTType] = [.pdf, .image, .png, .jpeg]
        
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
        picker.allowsMultipleSelection = false
        
        let delegate = FileDelegate(onPicked: onPicked)
        retainDelegate = delegate
        picker.delegate = delegate
        
        UIApplication.shared.topMostViewController?.present(picker, animated: true)
    }
    
    final class FileDelegate: NSObject, UIDocumentPickerDelegate {
        
        let onPicked: (URL?) -> Void
        init(onPicked: @escaping (URL?) -> Void) { self.onPicked = onPicked }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            controller.dismiss(animated: true)
            onPicked(nil)
            FilePicker.retainDelegate = nil
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController,
                            didPickDocumentsAt urls: [URL]) {
            controller.dismiss(animated: true)
            onPicked(urls.first)
            FilePicker.retainDelegate = nil
        }
    }
}
