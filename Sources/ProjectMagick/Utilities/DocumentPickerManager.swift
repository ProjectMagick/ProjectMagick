//
//  File.swift
//  
//
//  Created by Kishan on 06/02/22.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

public protocol DocumentPickerDelegate : AnyObject {
    func didFinishPicking(data : Data, url : URL)
    func didFinishMultipleFiles(data : [Data], urls : [URL])
}

public extension DocumentPickerDelegate {
    func didFinishMultipleFiles(data : [Data], urls : [URL]) { }
}


/** Note :- You need to declare this variable at class level. */
@available(iOS 14.0, *)
public class DocumentPickerManager : NSObject {
    
    weak public var delegate : DocumentPickerDelegate?
    public var allowMultiple = false
    public var allowedTypes = [UTType]()
    
    public override init() {
        super.init()
    }
    
}

@available(iOS 14.0, *)
public extension DocumentPickerManager {
    
    func openDocumentPicker() {
        var documentPicker : UIDocumentPickerViewController?
        documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: allowedTypes)
        documentPicker?.allowsMultipleSelection = allowMultiple
        documentPicker?.delegate = self
        UIApplication.topViewController()?.present(documentPicker!, animated: true)
    }
    
}

@available(iOS 14.0, *)
extension DocumentPickerManager : UIDocumentPickerDelegate {
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if allowMultiple {
            var datas = [Data]()
            urls.forEach {
                if let data = try? Data(contentsOf: $0) {
                    datas.append(data)
                }
            }
            delegate?.didFinishMultipleFiles(data: datas, urls: urls)
        } else {
            if let first = urls.first, let data = try? Data(contentsOf: first) {
                delegate?.didFinishPicking(data: data, url: first)
            }
        }
    }
    
}
