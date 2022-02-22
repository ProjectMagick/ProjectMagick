

import Foundation
import UIKit



public struct LocalFonts {
    
    public var regular = ""
    public var bold = ""
    public var italic = ""
    public var semiBold = ""
    public var medium = ""
    public var heavy = ""
    public var black = ""
    public var light = ""
    
    public init() {}
    
}

public var installedFonts = LocalFonts()


extension UIFont {

    class func customFont(ofType type: CustomFont, withSize size: CGFloat) -> UIFont {
        let fontSize = DeviceDetail.isIPhone ? size : size + 8
        let fontToSet = UIFont.init(name: type.rawValue, size: fontSize)!
        return fontToSet
    }
}



extension UIFontDescriptor.AttributeName {
    static let nsctFontUIUsage = UIFontDescriptor.AttributeName(rawValue: "NSCTFontUIUsageAttribute")
}

public extension UIFont {
    
    @objc class func mySystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: installedFonts.regular, size: size)!
    }
    
    @objc class func myBoldSystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: installedFonts.bold, size: size)!
    }
    
    @objc class func myItalicSystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: installedFonts.italic, size: size)!
    }
    
    @objc convenience init(myCoder aDecoder: NSCoder) {
        guard
            let fontDescriptor = aDecoder.decodeObject(forKey: "UIFontDescriptor") as? UIFontDescriptor,
            let fontAttribute = fontDescriptor.fontAttributes[.nsctFontUIUsage] as? String else {
                self.init(myCoder: aDecoder)
                return
        }
        var fontName = ""
        switch fontAttribute {
        case "CTFontObliqueUsage":
            fontName = installedFonts.italic
        case "CTFontRegularUsage":
            fontName = installedFonts.regular
        case "CTFontEmphasizedUsage", "CTFontBoldUsage":
            fontName = installedFonts.bold
        case "CTFontSemiboldUsage", "CTFontDemiUsage":
            fontName = installedFonts.semiBold
        case "CTFontLightUsage":
            fontName = installedFonts.light
        case "CTFontMediumUsage":
            fontName = installedFonts.medium
        case "CTFontHeavyUsage":
            fontName = installedFonts.heavy
        case "CTFontBlackUsage":
            fontName = installedFonts.black
        default:
            fontName = installedFonts.regular
        }
        self.init(name: fontName, size: fontDescriptor.pointSize)!
    }
    
   class func overrideInitialize() {
        guard self == UIFont.self else { return }
        
        if let systemFontMethod = class_getClassMethod(self, #selector(systemFont(ofSize:))),
            let mySystemFontMethod = class_getClassMethod(self, #selector(mySystemFont(ofSize:))) {
            method_exchangeImplementations(systemFontMethod, mySystemFontMethod)
        }
        
        if let boldSystemFontMethod = class_getClassMethod(self, #selector(boldSystemFont(ofSize:))),
            let myBoldSystemFontMethod = class_getClassMethod(self, #selector(myBoldSystemFont(ofSize:))) {
            method_exchangeImplementations(boldSystemFontMethod, myBoldSystemFontMethod)
        }
        
        if let italicSystemFontMethod = class_getClassMethod(self, #selector(italicSystemFont(ofSize:))),
            let myItalicSystemFontMethod = class_getClassMethod(self, #selector(myItalicSystemFont(ofSize:))) {
            method_exchangeImplementations(italicSystemFontMethod, myItalicSystemFontMethod)
        }
        
        if let initCoderMethod = class_getInstanceMethod(self, #selector(UIFontDescriptor.init(coder:))), // Trick to get over the lack of UIFont.init(coder:))
            let myInitCoderMethod = class_getInstanceMethod(self, #selector(UIFont.init(myCoder:))) {
            method_exchangeImplementations(initCoderMethod, myInitCoderMethod)
        }
    }
}


