//
//  BioMetricManager.swift
//  ProjectMagick
//
//  Created by Kishan on 20/07/21.
//

import LocalAuthentication

public class BioMetricAuthenticator: NSObject {
    
    // MARK: - Singleton
    public static let shared = BioMetricAuthenticator()
    
    // MARK: - Private
    private override init() {}
    
    // MARK: - Public
    public var allowableReuseDuration: TimeInterval = 0
}

// MARK:- Public

public extension BioMetricAuthenticator {
    
    /// checks if biometric authentication can be performed currently on the device.
    class func canAuthenticate() -> Bool {
        
        var isBiometricAuthenticationAvailable = false
        var error: NSError? = nil
        
        if LAContext().canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            isBiometricAuthenticationAvailable = (error == nil)
        }
        return isBiometricAuthenticationAvailable
    }
    
    /// Check for biometric authentication
    class func authenticateWithBioMetrics(reason: String, fallbackTitle: String? = "", cancelTitle: String? = "", completion: @escaping (Result<Bool, AuthenticationError>) -> Void) {
        
        // reason
        let reasonString = reason.isEmpty ? BioMetricAuthenticator.shared.defaultBiometricAuthenticationReason() : reason
        
        // context
        let context = LAContext()
        context.touchIDAuthenticationAllowableReuseDuration = BioMetricAuthenticator.shared.allowableReuseDuration
        context.localizedFallbackTitle = fallbackTitle
        context.localizedCancelTitle = cancelTitle
        
        // authenticate
        BioMetricAuthenticator.shared.evaluate(policy: .deviceOwnerAuthenticationWithBiometrics, with: context, reason: reasonString, completion: completion)
    }
    
    /// Check for device passcode authentication
    class func authenticateWithPasscode(reason: String, cancelTitle: String? = "", completion: @escaping (Result<Bool, AuthenticationError>) -> ()) {
        
        // reason
        let reasonString = reason.isEmpty ? BioMetricAuthenticator.shared.defaultPasscodeAuthenticationReason() : reason
        
        let context = LAContext()
        context.localizedCancelTitle = cancelTitle
        
        // authenticate
        BioMetricAuthenticator.shared.evaluate(policy: .deviceOwnerAuthentication, with: context, reason: reasonString, completion: completion)
    }
    
    /// checks if device supports face id and authentication can be done
    func faceIDAvailable() -> Bool {
        let context = LAContext()
        var error: NSError?
        
        let canEvaluate = context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error)
        return canEvaluate && context.biometryType == .faceID
    }
    
    /// checks if device supports touch id and authentication can be done
    func touchIDAvailable() -> Bool {
        let context = LAContext()
        var error: NSError?
        
        let canEvaluate = context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error)
        return canEvaluate && context.biometryType == .touchID
    }
    
    /// checks if device has faceId
    /// this is added to identify if device has faceId or touchId
    /// note: this will not check if devices can perform biometric authentication
    func isFaceIdDevice() -> Bool {
        let context = LAContext()
        _ = context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: nil)
        return context.biometryType == .faceID
    }
}

// MARK:- Private
extension BioMetricAuthenticator {
    
    /// get authentication reason to show while authentication
    private func defaultBiometricAuthenticationReason() -> String {
        return faceIDAvailable() ? AlertMessages.faceIdAuthenticationReason : AlertMessages.touchIdAuthenticationReason
    }
    
    /// get passcode authentication reason to show while entering device passcode after multiple failed attempts.
    private func defaultPasscodeAuthenticationReason() -> String {
        return faceIDAvailable() ? AlertMessages.faceIdPasscodeAuthenticationReason : AlertMessages.touchIdPasscodeAuthenticationReason
    }
    
    /// evaluate policy
    private func evaluate(policy: LAPolicy, with context: LAContext, reason: String, completion: @escaping (Result<Bool, AuthenticationError>) -> ()) {
        
        context.evaluatePolicy(policy, localizedReason: reason) { (success, err) in
            DispatchQueue.main.async {
                if success {
                    completion(.success(true))
                } else {
                    let errorType = AuthenticationError.initWithError(err as! LAError)
                    completion(.failure(errorType))
                }
            }
        }
    }
}

/// Authentication Errors
public enum AuthenticationError: Error {
    
    case failed,
         canceledByUser,
         fallback,
         canceledBySystem,
         passcodeNotSet,
         biometryNotAvailable,
         biometryNotEnrolled,
         biometryLockedout,
         other
    
    public static func initWithError(_ error: LAError) -> AuthenticationError {
        switch Int32(error.errorCode) {
        
        case kLAErrorAuthenticationFailed:
            return failed
        case kLAErrorUserCancel:
            return canceledByUser
        case kLAErrorUserFallback:
            return fallback
        case kLAErrorSystemCancel:
            return canceledBySystem
        case kLAErrorPasscodeNotSet:
            return passcodeNotSet
        case kLAErrorBiometryNotAvailable:
            return biometryNotAvailable
        case kLAErrorBiometryNotEnrolled:
            return biometryNotEnrolled
        case kLAErrorBiometryLockout:
            return biometryLockedout
        default:
            return other
        }
    }
    
    // get error message based on type
    public func message() -> String {
        let isFaceIdDevice = BioMetricAuthenticator.shared.isFaceIdDevice()
        
        switch self {
        case .canceledByUser, .fallback, .canceledBySystem:
            return ""
            
        case .passcodeNotSet:
            return isFaceIdDevice ? AlertMessages.setPasscodeToUseFaceID : AlertMessages.setPasscodeToUseTouchID
            
        case .biometryNotAvailable:
            return AlertMessages.biometryNotAvailableReason
            
        case .biometryNotEnrolled:
            return isFaceIdDevice ? AlertMessages.noFaceIdentityEnrolled : AlertMessages.noFingerprintEnrolled
            
        case .biometryLockedout:
            return isFaceIdDevice ? AlertMessages.faceIdPasscodeAuthenticationReason : AlertMessages.touchIdPasscodeAuthenticationReason
            
        default:
            return isFaceIdDevice ? AlertMessages.defaultFaceIDAuthenticationFailedReason : AlertMessages.defaultTouchIDAuthenticationFailedReason
        }
    }
}

