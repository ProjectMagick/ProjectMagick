//
//  File.swift
//
//
//  Created by Kishan on 29/12/21.
//

import UIKit

public enum CustomFont : String {
    case regular = "regular"
}

// Add paramters based on your requirement
public struct ThemeStyle {
    var textColor : UIColor?
    var backGroundColor: UIColor?
    var fontName : CustomFont?
    var fontSize : CGFloat?
}

public struct TextFieldTheme {
    var textColor : UIColor
    var tintColor : UIColor
    var lineColor : UIColor
    var backGroundColor : UIColor = .clear
    var titleColor : UIColor
    var selectedTitleColor : UIColor
    var disabledColor : UIColor
    var selectedLineColor : UIColor
    var textFont : UIFont
    var titleFont : UIFont
    var borderColor : UIColor = .clear
    var lineVerticalSpacing : CGFloat = 5
    var lineWidth : CGFloat = 1
}

// Make your own theme
// Create theme only if your application has global theme

public enum Theme {
    
    case themeLighWhiteButton


    var theme : ThemeStyle {
        switch self {
            case .themeLighWhiteButton:
                return ThemeStyle(textColor: .black, backGroundColor: .white, fontName: .regular, fontSize: 15)
        }
    }
}



