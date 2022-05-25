//
//  StringConstants.swift
//  ProjectMagick
//
//  Created by Kishan on 31/05/20.
//  Copyright © 2020 Kishan. All rights reserved.
//

import Foundation


public enum AlertTitles {
    
}

public extension AlertTitles {
    
    
}

public enum AlertMessages {
    
}

public extension AlertMessages {
    
    static let sessionTimeOut = "It seems like your session is expired. Please login again to continue."
    static let noInternet = "Please check your internet connectivity"
    static let cameraPermission = "It seems like we do not have permission to use Camera. Go to the Settings to change now."
    static let photoLibrary = "It seems like we do not have permission to use Photo library. Go to the Settings to change now."
    static let biometryNotAvailableReason = "Biometric authentication is not available for this device."
    static let touchIdAuthenticationReason = "Confirm your fingerprint to authenticate."
    static let touchIdPasscodeAuthenticationReason = "Touch ID is locked now, because of too many failed attempts. Enter passcode to unlock Touch ID."
    static let setPasscodeToUseTouchID = "Please set device passcode to use Touch ID for authentication."
    static let noFingerprintEnrolled = "There are no fingerprints enrolled in the device. Please go to Device Settings -> Touch ID & Passcode and enroll your fingerprints."
    static let defaultTouchIDAuthenticationFailedReason = "Touch ID does not recognize your fingerprint. Please try again with your enrolled fingerprint."
    static let faceIdAuthenticationReason = "Confirm your face to authenticate."
    static let faceIdPasscodeAuthenticationReason = "Face ID is locked now, because of too many failed attempts. Enter passcode to unlock Face ID."
    static let setPasscodeToUseFaceID = "Please set device passcode to use Face ID for authentication."
    static let noFaceIdentityEnrolled = "There is no face enrolled in the device. Please go to Device Settings -> Face ID & Passcode and enroll your face."
    static let defaultFaceIDAuthenticationFailedReason = "Face ID does not recognize your face. Please try again with your enrolled face."
    static let noDataAvailable = "No data available!"
    static let noEmailSetup = "Please configure your email account first."
    static let carriesServiceNotAvailable = "Carrier service is not available."
}

public enum SmallTitles {
    
}

public extension SmallTitles {
    
    static let cancel = "Cancel"
    static let settings = "Settings"
    static let gallery = "Gallery"
    static let camera = "Camera"
    static let ok = "OK"
    static let done = "Done"
    
}

public enum UserDefaultStrings {
    
}

public extension UserDefaultStrings {
    
    static let token = "Token"
    
}

public enum NotificationStrings {
    
}

public extension NotificationStrings {
    
    static let example = "Token"
    
}

public enum RegexPatterns {
    
}

public extension RegexPatterns {
    
    static let positiveNumbers = "\\d+"
    static let positiveAndNegativeNumbers = "-?\\d+"
    static let mentionedNames = "(@[a-zA-Z0-9_\\p{Arabic}\\p{N}]*)"
    /**
     find numbers within 10-14 digit length
     */
    static let numbersWithRange = "(?<!\\d)\\d{10,14}(?!\\d)"
    
    /**
     Matching Examples - user@domain.com, firstname.lastname-work@domain.com
     */
    static let simpleEmail = #"^\S+@\S+\.\S+$"#
    /**
     Matching Examples - 111-222 3333, 111 222 3333, (111) 222-3333, 1112223333
     */
    static let phonePattern = #"^\(?\d{3}\)?[ -]?\d{3}[ -]?\d{4}$"#
    /**
     Matching Examples - Steve Jobs, Tim Cook, Greg Joz Joswiak
     */
    static let usernamePattern = #"^[a-zA-Z-]+ ?.* [a-zA-Z-]+$"#
    /**
     At least 8 characters, At least one capital letter, At least one lowercase letter, At least one digit, At least one special character
     */
    static let passwordPattern = #"(?=.{8,})"# + #"(?=.*[A-Z])"# + #"(?=.*[a-z])"# + #"(?=.*\d)"# + #"(?=.*[ !$%&?._-])"#
    
    static let validURL = "[(http(s)?)://(www\\.)?a-zA-Z0-9@:%._\\+~#=]{2,256}\\.[a-z]{2,6}\\b([-a-zA-Z0-9@:%_\\+.~#?&//=]*)"
    /**
     At least one capital letter, At least one digit, At least one special character.
     */
    static let oneCapLetterNumberSpecialCharacter = "^(?=.*?[A-Z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-])$"
    
    /**It Will find mentionedText from String like @John, @Robert, @Bhavin etc **/
    static let mentionedText = "(@[a-zA-Z0-9_\\p{Arabic}\\p{N}]*)"
}



