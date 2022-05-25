//
//  String.swift
//  ProjectMagick
//
//  Created by Kishan on 31/05/20.
//  Copyright © 2020 Kishan. All rights reserved.
//

import UIKit
import Photos
import PhotosUI


@objc public protocol ImageDidReceivedDelegate {
    func imagePickUpFinish(image: UIImage, imageView : ImagePickerManager)
    @objc optional func pickerDidCancel()
    
    @available(iOS 14, *)
    func imagePickupDidFinish(images : [UIImage], imageView : ImagePickerManager)
    
}

open class ImagePickerManager: UIView {
    
    lazy var imagePicker : UIImagePickerController = {
        return UIImagePickerController()
    }()
    public weak var delegate : ImageDidReceivedDelegate?
    public var isEditMode : Bool = true
    public var selectionLimit = 1
    public var autoApplyImage = true
    public var projectName = AppInfo.appName
    public var cameraPermissionTitle = ""
    public var galleryPermissionTitle = ""
    public var imageContentMode : UIView.ContentMode = .scaleAspectFill {
        didSet {
            imageView.contentMode = imageContentMode
        }
    }
    private lazy var imageView : UIImageView = {
        let image = UIImageView()
        image.tag = 100
       return image
    }()
    

    public override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }
    
    //MARK:- Private functions
    private func setImage(image : UIImage?) {
        imageView.contentMode = imageContentMode
        imageView.image = image
        if !subviews.contains(where: { $0.tag == 100 }) {
            addSubview(imageView)
        }
    }
    
    @available(iOS 14, *)
    private func pickerViewController() -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = selectionLimit
        config.preferredAssetRepresentationMode = .current
        let vc = PHPickerViewController(configuration: config)
        vc.delegate = self
        return vc
    }
    
    private func checkPermissionForCamera(vc : UIViewController) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            DispatchQueue.main.async {
                self.imagePicker.sourceType = .camera
                vc.present(self.imagePicker, animated: true)
            }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { (response) in
                if response == (AVCaptureDevice.authorizationStatus(for: .video) == .authorized) {
                    DispatchQueue.main.async {
                        self.imagePicker.sourceType = .camera
                        vc.present(self.imagePicker, animated: true)
                    }
                }
            }
        case .restricted :
            return
        case .denied:
            
            ShowAlert(title: projectName, message: cameraPermissionTitle.isEmpty ? AlertMessages.cameraPermission : cameraPermissionTitle, buttonTitles: [SmallTitles.cancel,SmallTitles.settings], highlightedButtonIndex: 1) { (buttonNumber) in
                if buttonNumber == 1 {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:])
                }
            }
             
            break
        default:
            break
        }
        
    }
    
    private func checkPermissionForGallery(vc : UIViewController) {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized, .limited:
            DispatchQueue.main.async {
                self.imagePicker.sourceType = .photoLibrary
                if #available(iOS 14, *) {
                    vc.present(self.pickerViewController(), animated: true)
                } else {
                    vc.present(self.imagePicker, animated: true)
                }
            }
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (status) in
                if status == PHAuthorizationStatus.authorized {
                    DispatchQueue.main.async {
                        if #available(iOS 14, *) {
                            vc.present(self.pickerViewController(), animated: true)
                        } else {
                            self.imagePicker.sourceType = .photoLibrary
                            vc.present(self.imagePicker, animated: true)
                        }
                    }
                }
            }
        case .restricted:
            return
        case .denied:
            
            ShowAlert(title: projectName, message: galleryPermissionTitle.isEmpty ? AlertMessages.photoLibrary : galleryPermissionTitle, buttonTitles: [SmallTitles.cancel,SmallTitles.settings], highlightedButtonIndex: 1) { (buttonNumber) in
                if buttonNumber == 1 {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:])
                }
            }
        default:
            break
        }
    }
    
}


//MARK:- ImagePickerController Delegate Method
extension ImagePickerManager : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: {
            self.delegate?.pickerDidCancel?()
        })
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.editedImage] as? UIImage {
            if delegate != nil {
                if autoApplyImage {
                    setImage(image: image)
                }
                delegate?.imagePickUpFinish(image: image, imageView: self)
            }
        } else if let image = info[.originalImage] as? UIImage {
            if delegate != nil {
                if autoApplyImage {
                    setImage(image: image)
                }
                delegate?.imagePickUpFinish(image: image, imageView: self)
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
}


public extension ImagePickerManager {
    
    
    //MARK:- ImageView Configure Method
    func initialize() {
        isUserInteractionEnabled = true
        clipsToBounds = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(openWithTap(_:)))
        addGestureRecognizer(gesture)
        imagePicker.delegate = self
    }
    
    //MARK:- ImageView TapGesture Handle Method
    @objc func openWithTap(_ sender: UITapGestureRecognizer) {
        if let vc = parentViewController {
            imgPickerOpen(this: vc, imagePicker: imagePicker, sourceControl: self)
        }
    }
    
    @IBAction func touchUpInside(_ sender: Any) {
        if let vc = parentViewController {
            imgPickerOpen(this: vc, imagePicker: imagePicker, sourceControl: self)
        }
    }

    
    //MARK:- ActionSheet Method
    private func imgPickerOpen(this: UIViewController, imagePicker: UIImagePickerController, sourceControl: UIView) {
        
        this.view.endEditing(true)
        
        imagePicker.allowsEditing = isEditMode
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: SmallTitles.camera, style: .default, handler: { (UIAlertAction) in
            
            if DeviceDetail.isSimulator {
                return
            }
            self.checkPermissionForCamera(vc: this)
        }))
        
        actionSheet.addAction(UIAlertAction(title: SmallTitles.gallery, style: .default, handler: { (UIAlertAction) in
            self.checkPermissionForGallery(vc: this)
        }))
        
        actionSheet.addAction(UIAlertAction(title: SmallTitles.cancel, style: .cancel))
        
        
        if !DeviceDetail.isIPhone {
            actionSheet.popoverPresentationController?.sourceView = sourceControl
            actionSheet.popoverPresentationController?.sourceRect = sourceControl.bounds
        }
        
        this.present(actionSheet, animated: true)
        
    }
    
}

@available(iOS 14, *)
extension ImagePickerManager : PHPickerViewControllerDelegate {
    
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            if results.isEmpty {
                self.delegate?.pickerDidCancel?()
            } else {
                let dispatchGroup = DispatchGroup()
                var images = [UIImage]()
                for result in results {
                    dispatchGroup.enter()
                    result.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (object, error) in
                        if let image = object as? UIImage {
                            DispatchQueue.main.async {
                                images.append(image)
                                dispatchGroup.leave()
                            }
                        }
                    })
                }
                dispatchGroup.notify(queue: DispatchQueue.main) {
                    if self.autoApplyImage {
                        self.setImage(image: images.first)
                    }
                    self.delegate?.imagePickupDidFinish(images: images, imageView: self)
                }
            }
        }
    }
    
}


public extension ImagePickerManager {
    
    var image : UIImage? {
        return imageView.image
    }
    
}
