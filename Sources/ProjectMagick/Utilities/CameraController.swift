

import UIKit
import Photos
import AVFoundation


// To add live preview of camera in any view controller
/*
 Usage :-
 let cameraController = CameraController()
 
 //in viewdidload
 cameraController.prepare { (error) in
     if let error = error {
         print(error)
     }
     try? self.cameraController.displayPreview(on: self.view)
 }
 */


public extension CameraController {
    
    enum CameraPosition {
        case front
        case rear
    }
    
    enum CameraType {
        case photo
        case Video
    }
    
    enum CameraControllerError: Swift.Error {
        case captureSessionAlreadyRunning
        case captureSessionIsMissing
        case inputsAreInvalid
        case invalidOperation
        case noCamerasAvailable
        case unknown
    }
    
}


public class CameraController : NSObject {
    
    // MARK:- Variables
    public var captureSession: AVCaptureSession?
    public var frontCamera: AVCaptureDevice?
    public var rearCamera: AVCaptureDevice?
    public var currentCameraPosition: CameraPosition?
    public var cameraType : CameraType?
    public var frontCameraInput: AVCaptureDeviceInput?
    public var rearCameraInput: AVCaptureDeviceInput?
    public var liveVideoPreviewLayer: AVCaptureVideoPreviewLayer?
    public var photoCaptureCompletionBlock: ((UIImage?, Error?) -> Void)?
    public var flashMode = AVCaptureDevice.FlashMode.off
    public var photoOutput: AVCapturePhotoOutput?
    public var videoOutput : AVCaptureMovieFileOutput?
    public var videoCompletion : ((URL) -> Void)?
    public var isRecording = false
}

public extension CameraController {
    
    var tempURL : URL? {
        let directory = NSTemporaryDirectory() as NSString
        
        if directory != "" {
            let path = directory.appendingPathComponent(UUID().uuidString + ".mp4")
            return URL(fileURLWithPath: path)
        }
        return nil
    }
    
    func focus(_ device : AVCaptureDevice, _ point : CGPoint) {
        try? device.lockForConfiguration()
        if device.isFocusPointOfInterestSupported {
            device.focusPointOfInterest = point
            device.focusMode = .autoFocus
        }
        if device.isExposurePointOfInterestSupported {
            device.exposurePointOfInterest = point
            device.exposureMode = .autoExpose
        }
        device.unlockForConfiguration()
    }
    
    func startRecording() throws {
        
        guard let videoOutputInstance = videoOutput else {
            throw CameraControllerError.invalidOperation
        }
        if !videoOutputInstance.isRecording {
            
            videoOutput?.connections.first?.preferredVideoStabilizationMode = .auto
            try rearCameraInput?.device.lockForConfiguration()
            rearCameraInput?.device.isSmoothAutoFocusEnabled = false
            rearCameraInput?.device.unlockForConfiguration()
            videoOutput?.startRecording(to: tempURL!, recordingDelegate: self)
        } else {
            stopRecording()
        }
        
    }
    
    func stopRecording() {
        videoOutput?.stopRecording()
    }
}


public extension CameraController {
    
    
    // MARK:- Private Functions
    func prepare(completionHandler: @escaping (Error?) -> Void) {
        
        func createCaptureSession() {
            captureSession = AVCaptureSession()
        }
        
        func configureCaptureDevices() throws {
            
            //1
            
            var session : AVCaptureDevice.DiscoverySession
            if #available(iOS 11.1, *) {
                session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTelephotoCamera,.builtInDualCamera,.builtInWideAngleCamera,.builtInTrueDepthCamera], mediaType: AVMediaType.video, position: .unspecified)
            } else {
                session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
            }
        
            let cameras = session.devices.compactMap { $0 }
            
            if cameras.isEmpty  {
                throw CameraControllerError.noCamerasAvailable
            }
            
            //2
            try cameras.forEach {
                if $0.position == .front {
                    frontCamera = $0
                }
                if $0.position == .back {
                    rearCamera = $0
                    try $0.lockForConfiguration()
                    $0.focusMode = .continuousAutoFocus
                    $0.exposureMode = .continuousAutoExposure
                    $0.unlockForConfiguration()
                }
            }
        }
        
        func configureDeviceInputs() throws {
            //3
            guard let captureSessionInstance = captureSession else {
                throw CameraControllerError.captureSessionIsMissing
            }
            
            //4
            if let rearCameraInstance = rearCamera {
                
                rearCameraInput = try AVCaptureDeviceInput(device: rearCameraInstance)
                if captureSessionInstance.canAddInput(rearCameraInput!) {
                    captureSessionInstance.addInput(rearCameraInput!)
                }
                currentCameraPosition = .rear
            }
                
            else if let frontCameraInstance = frontCamera {
                
                frontCameraInput = try AVCaptureDeviceInput(device: frontCameraInstance)
                
                if captureSessionInstance.canAddInput(frontCameraInput!) {
                    captureSessionInstance.addInput(frontCameraInput!)
                } else {
                    throw CameraControllerError.inputsAreInvalid
                }
                currentCameraPosition = .front
                
            } else {
                throw CameraControllerError.noCamerasAvailable
            }
        }
        
        func configurePhotoOutput() throws {
            guard let captureSessionInstance = captureSession else {
                throw CameraControllerError.captureSessionIsMissing
            }
            
            photoOutput = AVCapturePhotoOutput()
            photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            
            if captureSessionInstance.canAddOutput(photoOutput!) {
                captureSessionInstance.addOutput(photoOutput!)
            }
            
            captureSessionInstance.startRunning()
        }
        
        func configureVideoInputs() throws {
            let microPhone = AVCaptureDevice.default(for: AVMediaType.audio)!
            
            guard let captureSessionInstance = captureSession, captureSessionInstance.isRunning else {
                throw CameraControllerError.captureSessionIsMissing
            }
            
            do {
                let micInput = try AVCaptureDeviceInput(device: microPhone)
                if captureSessionInstance.canAddInput(micInput) {
                    captureSessionInstance.addInput(micInput)
                } else {
                    throw CameraControllerError.invalidOperation
                }
            } catch {
                throw CameraControllerError.captureSessionIsMissing
            }
            
        }
        
        
        func configureVideoOutput() throws {
            
            guard let captureSessionInstance = captureSession else {
                throw CameraControllerError.captureSessionIsMissing
            }
            
            videoOutput = AVCaptureMovieFileOutput()
            
            if captureSessionInstance.canAddOutput(videoOutput!) {
                captureSessionInstance.addOutput(videoOutput!)
            } else {
                throw CameraControllerError.invalidOperation
            }
            
            captureSessionInstance.startRunning()
        }
        
        
        
        DispatchQueue(label: "prepare").async {
            do {
                createCaptureSession()
                try configureCaptureDevices()
                try configureDeviceInputs()
                try configurePhotoOutput()
                try configureVideoInputs()
                try configureVideoOutput()
            }
                
            catch {
                DispatchQueue.main.async {
                    completionHandler(error)
                }
                return
            }
            
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }
    
    
    func switchCameras() throws {
        
        //5
        guard let currentCameraPositionInstance = currentCameraPosition, let captureSessionInstance = captureSession, captureSessionInstance.isRunning else {
            throw CameraControllerError.captureSessionIsMissing
        }
        
        //6
        captureSessionInstance.beginConfiguration()
        
        func switchToFrontCamera() throws {
            let inputs = captureSessionInstance.inputs
            if let rearCameraInputs = rearCameraInput, inputs.contains(rearCameraInputs), let frontCameraInstance = frontCamera {
                
                frontCameraInput = try AVCaptureDeviceInput(device: frontCameraInstance)
                captureSessionInstance.removeInput(rearCameraInputs)
                if captureSessionInstance.canAddInput(frontCameraInput!) {
                    captureSessionInstance.addInput(frontCameraInput!)
                    currentCameraPosition = .front
                } else {
                    throw CameraControllerError.invalidOperation
                }
                
            } else {
                throw CameraControllerError.invalidOperation
            }
            
        }
        
        func switchToRearCamera() throws {
            let inputs = captureSessionInstance.inputs
            if let frontCameraInputInstance = frontCameraInput, inputs.contains(frontCameraInputInstance),
                let rearCameraInstance = rearCamera {
                
                rearCameraInput = try AVCaptureDeviceInput(device: rearCameraInstance)
                captureSessionInstance.removeInput(frontCameraInputInstance)
                if captureSessionInstance.canAddInput(rearCameraInput!) {
                    captureSessionInstance.addInput(rearCameraInput!)
                    currentCameraPosition = .rear
                } else {
                    throw CameraControllerError.invalidOperation
                }
                
            } else {
                throw CameraControllerError.invalidOperation
            }
        }
        
        //7
        switch currentCameraPositionInstance {
        case .front:
            try switchToRearCamera()
            
        case .rear:
            try switchToFrontCamera()
        }
        
        //8
        captureSessionInstance.commitConfiguration()
        
    }
    
    
    func displayPreview(on view: UIView) throws {
        guard let captureSessionInstance = captureSession, captureSessionInstance.isRunning else {
            throw CameraControllerError.captureSessionIsMissing
        }
        liveVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSessionInstance)
        liveVideoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        liveVideoPreviewLayer?.connection?.videoOrientation = .portrait
        view.layer.insertSublayer(liveVideoPreviewLayer!, at: 0)
        liveVideoPreviewLayer?.frame = view.frame
    }
    
    func captureImage(completion: @escaping (UIImage?, Error?) -> Void) {
        
        guard let captureSession = captureSession, captureSession.isRunning else {
            completion(nil, CameraControllerError.captureSessionIsMissing)
            return
        }
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = flashMode
        
        photoOutput?.capturePhoto(with: settings, delegate: self)
        photoCaptureCompletionBlock = completion
        
    }
    
    
}


extension CameraController : AVCapturePhotoCaptureDelegate {
    
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        if let error = error {
            photoCaptureCompletionBlock?(nil, error)
        } else if let imageData = photo.fileDataRepresentation() {
            let image = UIImage(data: imageData)
            photoCaptureCompletionBlock?(image,nil)
        } else {
            photoCaptureCompletionBlock?(nil, CameraControllerError.unknown)
        }
        
    }
    
}

extension CameraController : AVCaptureFileOutputRecordingDelegate {
    
    public func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        isRecording = true
    }
    
    public func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
//        UISaveVideoAtPathToSavedPhotosAlbum(outputFileURL.path, nil, nil, nil)
        isRecording = false
        videoCompletion?(outputFileURL)
    }
    
}
