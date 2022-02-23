//
//  KeyChainServices.swift
//  ProjectMagick
//
//  Created by Kishan on 06/03/21.
//  Copyright © 2021 Kishan. All rights reserved.
//

import Foundation

public enum SecureStorageAccess {
    
    /**
     
     The data in the keychain item can be accessed only while the device is unlocked by the user.
     
     This is recommended for items that need to be accessible only while the application is in the foreground. Items with this attribute migrate to a new device when using encrypted backups.
     
     This is the default value for keychain items added without explicitly setting an accessibility constant.
     
     */
    case accessibleWhenUnlocked
    
    /**
     
     The data in the keychain item can be accessed only while the device is unlocked by the user.
     
     This is recommended for items that need to be accessible only while the application is in the foreground. Items with this attribute do not migrate to a new device. Thus, after restoring from a backup of a different device, these items will not be present.
     
     */
    case accessibleWhenUnlockedThisDeviceOnly
    
    /**
     
     The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user.
     
     After the first unlock, the data remains accessible until the next restart. This is recommended for items that need to be accessed by background applications. Items with this attribute migrate to a new device when using encrypted backups.
     
     */
    case accessibleAfterFirstUnlock
    
    /**
     
     The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user.
     
     After the first unlock, the data remains accessible until the next restart. This is recommended for items that need to be accessed by background applications. Items with this attribute do not migrate to a new device. Thus, after restoring from a backup of a different device, these items will not be present.
     
     */
    case accessibleAfterFirstUnlockThisDeviceOnly
    
    
    /**
     
     The data in the keychain can only be accessed when the device is unlocked. Only available if a passcode is set on the device.
     
     This is recommended for items that only need to be accessible while the application is in the foreground. Items with this attribute never migrate to a new device. After a backup is restored to a new device, these items are missing. No items can be stored in this class on devices without a passcode. Disabling the device passcode causes all items in this class to be deleted.
     
     */
    case accessibleWhenPasscodeSetThisDeviceOnly
    
    /**
     
     The data in the keychain item can always be accessed regardless of whether the device is locked.
     
     This is not recommended for application use. Items with this attribute do not migrate to a new device. Thus, after restoring from a backup of a different device, these items will not be present.
     
     */
    case accessibleAlwaysThisDeviceOnly
    
    var value: String {
        switch self {
        case .accessibleWhenUnlocked:
            return kSecAttrAccessibleWhenUnlocked as String
        case .accessibleAfterFirstUnlock:
            return kSecAttrAccessibleAfterFirstUnlock as String
        case .accessibleAlwaysThisDeviceOnly:
            return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly as String
        case .accessibleWhenUnlockedThisDeviceOnly:
            return kSecAttrAccessibleWhenUnlockedThisDeviceOnly as String
        case .accessibleWhenPasscodeSetThisDeviceOnly:
            return kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly as String
        case .accessibleAfterFirstUnlockThisDeviceOnly:
            return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly as String
        }
    }
    
}

public class KeyChainManager {
    
    public var isSynchronizationOn = false
    public static let shared = KeyChainManager()
    
}

public extension KeyChainManager {
    
    @discardableResult
    func store<T>(value: T, key: String, access: SecureStorageAccess = .accessibleWhenUnlockedThisDeviceOnly) -> Bool where T: Codable {
        if let data = value.toData() {
            return self.set(data, key: key, access: access)
        }
        return false
    }
    
    func fetch<T>(_ key: String) -> T? where T: Codable {
        let data = getData(key)
        if let data = data, let object = data.toObject(type: T.self) {
            return object
        }
        return nil
    }
    
    /** It will clear all keychain items. */
    @discardableResult
    func clearAll() -> Bool {
        let query: [String: Any] = [
            SecureStorageOptions.SecureClass : kSecClassGenericPassword,
        ]
        
        let result = SecItemDelete(query as CFDictionary)
        return result == noErr
    }
    
    //MARK: - Private
    private func set(_ value: Data, key: String, access: SecureStorageAccess = .accessibleWhenUnlockedThisDeviceOnly) -> Bool {
        delete(key)
        var query: [String: Any] = [
            SecureStorageOptions.SecureClass : kSecClassGenericPassword,
            SecureStorageOptions.ValueKey    : key,
            SecureStorageOptions.ValueData   : value,
            SecureStorageOptions.Accessible   : access.value,
        ]
        if isSynchronizationOn {
            query[SecureStorageOptions.synchronized] = true
        }
        
        let result = SecItemAdd(query as CFDictionary, nil)
        
        return result == noErr
    }
    
    private func getData(_ key: String) -> Data? {
        
        var query: [String: Any] = [
            SecureStorageOptions.SecureClass : kSecClassGenericPassword,
            SecureStorageOptions.ValueKey    : key,
            SecureStorageOptions.ReturnData  : kCFBooleanTrue ?? false,
            SecureStorageOptions.MatchLimit  : kSecMatchLimitOne,
        ]
        if isSynchronizationOn {
            query[SecureStorageOptions.synchronized] = true
        }
        var result: AnyObject?
        let resultCode = withUnsafePointer(to: &result) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer(mutating: $0))
        }
        
        if resultCode == noErr {
            return result as? Data
        }
        return nil
    }
    
    @discardableResult
    func delete(_ key: String) -> Bool {
        var query: [String: Any] = [
            SecureStorageOptions.SecureClass : kSecClassGenericPassword,
            SecureStorageOptions.ValueKey    : key,
        ]
        if isSynchronizationOn {
            query[SecureStorageOptions.synchronized] = true
        }
        
        let result = SecItemDelete(query as CFDictionary)
        
        return result == noErr
    }
    
    //MARK: - Constants
    private struct SecureStorageOptions {
        static let SecureClass = kSecClass as String
        static let ValueData   = kSecValueData as String
        static let ValueKey    = kSecAttrAccount as String
        static let Accessible   = kSecAttrAccessible as String
        static let ReturnData  = kSecReturnData as String
        static let MatchLimit  = kSecMatchLimit as String
        static let synchronized = kSecAttrSynchronizable as String
    }
    
}
