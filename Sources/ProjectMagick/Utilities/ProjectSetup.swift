//
//  File.swift
//  
//
//  Created by Kishan on 17/12/21.
//

import UIKit
import IQKeyboardManagerSwift

public class ProjectSetup {
    
    public static let shared = ProjectSetup()
    public init() {}
    
}

public extension ProjectSetup {
    
    static func applyKeyboardSetup() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
    }
    
    static func applyFonts(fonts : LocalFonts) {
        installedFonts = fonts
        UIFont.overrideInitialize()
    }
    
}

/** It will return value from Info.plist in a String format for given key. */
public enum Configuration {
    
    enum Error: Swift.Error {
        case missingKey, invalidValue
    }
    
}

public extension Configuration {
    
    static func value<T>(for key: String) throws -> T where T: LosslessStringConvertible {
        
        guard let object = Bundle.main.object(forInfoDictionaryKey:key) else {
            throw Error.missingKey
        }
        
        switch object {
        case let value as T:
            return value
        case let string as String:
            guard let value = T(string) else { fallthrough }
            return value
        default:
            throw Error.invalidValue
        }
    }
}



/// This class will provide Basic app information like Appname, envrionment, version etc.
public class AppInfo {
    
    public init() {}
    
}

public extension AppInfo {
    
    /// ProjectMagick: Application running environment.
    ///
    /// - debug: Application is running in debug mode.
    /// - testFlight: Application is installed from Test Flight.
    /// - appStore: Application is installed from the App Store.
    enum Environment {
        /// Application is running in debug mode.
        case debug
        /// Application is installed from Test Flight.
        case testFlight
        /// Application is installed from the App Store.
        case appStore
    }

    /// ProjectMagick: Current inferred app environment.
    static var inferredEnvironment: Environment {
        #if DEBUG
        return .debug

        #elseif targetEnvironment(simulator)
        return .debug

        #else
        if Bundle.main.path(forResource: "embedded", ofType: "mobileprovision") != nil {
            return .testFlight
        }

        guard let appStoreReceiptUrl = Bundle.main.appStoreReceiptURL else {
            return .debug
        }

        if appStoreReceiptUrl.lastPathComponent.lowercased() == "sandboxreceipt" {
            return .testFlight
        }

        if appStoreReceiptUrl.path.lowercased().contains("simulator") {
            return .debug
        }

        return .appStore
        #endif
    }

    /// ProjectMagick: Application name (if applicable).
    static var appName: String? {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
    }

    /// ProjectMagick: App current build number (if applicable).
    static var buildNumber: String? {
        Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String
    }

    /// ProjectMagick: App's current version number (if applicable).
    static var version: String? {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    static func fetchCountries() -> [Countries] {
        Bundle.module.decode([Countries].self, from: "ListOfCountries.json")
    }
    
    static func fetchCurrentCountryCodeDial(withFlagEmoji : Bool = false) -> String {
        let countries = fetchCountries()
        if let object = countries.first(where: { $0.code == Locale.current.regionCode }) {
            let emoji = Locale.flagEmoji(forRegionCode: object.code) ?? ""
            return withFlagEmoji ? "\(emoji) \(object.dial)" : object.dial
        } else {
            print("Unable to find country dial.")
            return ""
        }
    }
    
}


// MARK: - Bundle properties.
public extension Foundation.Bundle {
    
    /// This will return bundle for ProjectMagick.
    static var ProjectMagick: Bundle {
      return Bundle.module
    }
    
}
