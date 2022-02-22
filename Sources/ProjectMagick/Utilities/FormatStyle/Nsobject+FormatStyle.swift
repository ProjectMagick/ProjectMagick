//
//  File.swift
//
//
//  Created by Kishan on 29/12/21.
//

import UIKit

//MARK:- TextColor
public extension FormatStyle where Self: NSObject {
    
    @discardableResult func textColor(color: UIColor, state: UIControl.State? = nil) -> Self {
        
        switch self {
   
        case is UILabel:
            let lbl = self as! UILabel
            lbl.textColor = color

        case is UIButton:
            let btn = self as! UIButton
            var defaultState = UIControl.State()
            if let nwState = state {
                defaultState = nwState
            }
            btn.setTitleColor(color, for: defaultState)
            
        case is UIBarButtonItem:
            let barButton = self as! UIBarButtonItem
            
            var defaultState = UIControl.State()
            if let nwState = state {
                defaultState = nwState
            }
            var defaultAttributes : [NSAttributedString.Key : Any] = [:]
            if let attributes = barButton.titleTextAttributes(for: defaultState) {
                defaultAttributes = attributes
            }
            
            defaultAttributes[NSAttributedString.Key.foregroundColor] = color
            barButton.setTitleTextAttributes(defaultAttributes, for: defaultState)
            
        case is UITextField:
            let txtField = self as! UITextField
            txtField.textColor = color
            
        case is UITextView:
            let txtv = self as! UITextView
            txtv.textColor = color
            
        default:
            break
        }
        
        return self
    }
    
}


//MARK:- BackGroundColor
public extension FormatStyle where Self: NSObject {
    
    @discardableResult func backGroundColor(color: UIColor) -> Self {
        
        switch self {
        
        case is UILabel:
            let lbl = self as! UILabel
            lbl.backgroundColor = color
            
        case is UIButton:
            let btn = self as! UIButton
            btn.backgroundColor = color
            
        case is UIBarButtonItem:
            let barButton = self as! UIBarButtonItem
            let defaultState = UIControl.State()
            
            var defaultAttributes : [NSAttributedString.Key : Any] = [:]
            
            if let attributes = barButton.titleTextAttributes(for: defaultState) {
                defaultAttributes = attributes
            }
            defaultAttributes[NSAttributedString.Key.backgroundColor] = color
            barButton.setTitleTextAttributes(defaultAttributes, for: defaultState)
            
        case is UITextField:
            let txtField = self as! UITextField
            txtField.backgroundColor = color
            
        case is UITextView:
            let txtv = self as! UITextView
            txtv.backgroundColor = color
            
        case is UIView:
            let vw = self as! UIView
            vw.backgroundColor = color
            
        case is UIImageView:
            let imgVw = self as! UIImageView
            imgVw.backgroundColor = color
            
        default:
            break
        }
        
        return self
    }
    
}

//MARK:- BorderColor
public extension FormatStyle where Self: NSObject {
    
    @discardableResult func borderColor(color: UIColor, borderWidth: CGFloat = 1.0) -> Self {
        
        switch self {
            
        case is UILabel:
            let lbl = self as! UILabel
            lbl.layer.borderColor = color.cgColor
            lbl.layer.borderWidth = borderWidth
            
        case is UIButton:
            let btn = self as! UIButton
            btn.layer.borderColor = color.cgColor
            btn.layer.borderWidth = borderWidth
           
        case is UITextField:
            let txtField = self as! UITextField
            txtField.layer.borderColor = color.cgColor
            txtField.layer.borderWidth = borderWidth
            
        case is UITextView:
            let txtv = self as! UITextView
            txtv.layer.borderColor = color.cgColor
            txtv.layer.borderWidth = borderWidth
            
        case is UIView:
            let vw = self as! UIView
            vw.layer.borderColor = color.cgColor
            vw.layer.borderWidth = borderWidth
            
        case is UIImageView:
            let imgVw = self as! UIImageView
            imgVw.layer.borderColor = color.cgColor
            imgVw.layer.borderWidth = borderWidth
            
        default:
            break
        }
        
        return self
    }
}

//MARK:- Font & size
public extension FormatStyle where Self: NSObject {
    
    @discardableResult func font(name: CustomFont, size: CGFloat? = nil) -> Self {
        
        let defaultFontSize : CGFloat = 10
        
        switch self {
        
        case is UILabel:
            let lbl = self as! UILabel
            lbl.font = UIFont.customFont(ofType: name, withSize: size ?? lbl.font.pointSize) //UIFont(name: name, size: size ?? lbl.font.pointSize)
            
        case is UIButton:
            let btn = self as! UIButton
            let nwSize = size ?? btn.titleLabel?.font.pointSize ?? defaultFontSize
             btn.titleLabel?.font = UIFont.customFont(ofType: name, withSize: nwSize)
           // btn.titleLabel?.font = UIFont(name: name, size: nwSize)
            
        case is UIBarButtonItem:
            let barButton = self as! UIBarButtonItem
            let defaultState = UIControl.State()
            
            var defaultAttributes : [NSAttributedString.Key : Any] = [:]
            
            if let attributes = barButton.titleTextAttributes(for: defaultState) {
                defaultAttributes = attributes
            }
            defaultAttributes[NSAttributedString.Key.font] = UIFont.customFont(ofType: name, withSize: size ?? defaultFontSize)
           // defaultAttributes[NSAttributedString.Key.font] = UIFont(name: name, size: size ?? defaultFontSize)
            
            barButton.setTitleTextAttributes(defaultAttributes, for: defaultState)
            
        case is UITextField:
            let txtField = self as! UITextField
            txtField.font = UIFont.customFont(ofType: name, withSize: size ?? txtField.font?.pointSize ?? defaultFontSize)
         //   txtField.font = UIFont(name: name, size: size ?? txtField.font?.pointSize ?? defaultFontSize)
            
        case is UITextView:
            let txtv = self as! UITextView
            txtv.font = UIFont.customFont(ofType: name, withSize: size ?? txtv.font?.pointSize ?? defaultFontSize)
           // txtv.font = UIFont(name: name, size: size ?? txtv.font?.pointSize ?? defaultFontSize)
            
        default:
            break
        }
        
        return self
    }
    
}

//MARK:- FontsizeOnly
public extension FormatStyle where Self: NSObject {
    
    @discardableResult func fontSize(size: CGFloat) -> Self {
        
        switch self {
            
        case is UILabel:
            let lbl = self as! UILabel
            lbl.font.withSize(size)
            
        case is UIButton:
            let btn = self as! UIButton
            btn.titleLabel?.font.withSize(size)
            
        case is UITextField:
            let txtField = self as! UITextField
            txtField.font?.withSize(size)
            
        case is UITextView:
            let txtv = self as! UITextView
            txtv.font?.withSize(size)
            
        default:
            break
        }
        
        return self
    }
    
}

//MARK:- Apply Theme
public extension FormatStyle where Self: NSObject {
    
    @discardableResult func applyTheme(themeStyle: Theme) -> Self {
        
        let theme = themeStyle.theme
        
        if let color = theme.textColor {
            self.textColor(color: color)
        }

        if let backGroundColor = theme.backGroundColor {
            self.backGroundColor(color: backGroundColor)
        }
        
        if let fontName = theme.fontName {
            self.font(name: fontName, size: theme.fontSize)
        }
        
        return self
    }
}


