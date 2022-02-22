//
//  Alterts.swift
//  ProjectMagick
//
//  Created by Kishan on 31/05/20.
//  Copyright © 2020 Kishan. All rights reserved.
//

import UIKit
import FittedSheets

//MARK:- Utility Functions
public extension UIViewController {
    
    /** To check if current viewcontroller is presented Modally */
    var isPresented : Bool {
        
        let presentingIsModal = presentingViewController != nil
        let presentingIsNavigation = navigationController?.presentingViewController?.presentedViewController == navigationController
        let presentingIsTabBar = tabBarController?.presentingViewController is UITabBarController
        
        return presentingIsModal || presentingIsNavigation || presentingIsTabBar
    }
    
    
    @discardableResult
    func ShowAlert(title: String?, message: String?, buttonTitles: [String]? = nil, highlightedButtonIndex: Int? = nil, completion: ((Int) -> Void)? = nil) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        var allButtons = buttonTitles ?? [String]()
        if allButtons.count == 0 {
            allButtons.append(SmallTitles.ok)
        }
        
        for index in 0..<allButtons.count {
            let buttonTitle = allButtons[index]
            let action = UIAlertAction(title: buttonTitle, style: .default, handler: { (_) in
                completion?(index)
            })
            alertController.addAction(action)
            // Check which button to highlight
            if let highlightedButtonIndex = highlightedButtonIndex, index == highlightedButtonIndex {
                alertController.preferredAction = action
            }
        }
        present(alertController, animated: true, completion: nil)
        return alertController
    }
    
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    /** This will effect on particular viewcontroller instance only. Won't affect base settings. */
    func navigationColored(with : UIColor) {
        let appearance = navigationController?.navigationBar.standardAppearance.copy()
        appearance?.backgroundColor = with
        navigationItem.standardAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
    }
    
    /** This will effect on particular viewcontroller instance only. Won't affect base settings. */
    func navigationTextColored(with : UIColor, backgroundColor : UIColor) {
        let appearance = navigationController?.navigationBar.standardAppearance.copy()
        var attrs = [NSAttributedString.Key: Any]()
        attrs[.foregroundColor] = with
        appearance?.titleTextAttributes = attrs
        appearance?.largeTitleTextAttributes = attrs
        appearance?.backgroundColor = backgroundColor
        navigationItem.standardAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
    }
    
    
    @discardableResult
    /// A ready method for presenting custom pop ups.
    /// - Parameters:
    ///   - insideViewController: In case you want to add in current viewcontroller or to present, pass the boolean accordingly. Default is false
    ///   - viewcontroller: Viewcontroller reference
    ///   - height: Use the percentage option for normal use.
    ///   - cornerRadius: apply corner radius. Default is 20.
    ///   - shrinkBackVC: To mirror default presentation transition. Default is true
    /// - Returns: Passed Viewcontroller for further use if any.
    func presentSheet(insideViewController : Bool = false, viewcontroller : UIViewController, height : [SheetSize] = [.percent(0.4)], cornerRadius : CGFloat = 20, shrinkBackVC : Bool = true) -> UIViewController {
        var options = SheetOptions()
        options.pullBarHeight = 0
        options.transitionDampening = 0.9
        options.shrinkPresentingViewController = shrinkBackVC
        if insideViewController {
            options.useInlineMode = true
        }
        let sheet = SheetViewController(controller: viewcontroller, sizes: height, options: options)
        sheet.overlayColor = .clear
        sheet.cornerRadius = cornerRadius
        sheet.allowPullingPastMaxHeight = false
        if insideViewController {
            options.useInlineMode = true
            sheet.animateIn(to: view, in: self)
        } else {
            present(sheet, animated: true)
        }
        return viewcontroller
    }
    
    func showSnackBar(_ message : String, backGroundColor : UIColor = .black, textColor : UIColor = .white, duration : TTGSnackbarDuration = .long) {
        
        let snackbar: TTGSnackbar = TTGSnackbar()
        snackbar.message = message.localized()
        snackbar.duration = duration
        // Change the content padding inset
        snackbar.contentInset = UIEdgeInsets.init(top: 15, left: 15, bottom: 15, right: 15)
        
        // Change margin
        snackbar.leftMargin = 20
        snackbar.rightMargin = 20
        snackbar.topMargin = 15
        snackbar.bottomMargin = 15
        
        // Change message text font and color
        snackbar.messageTextColor = textColor
//        snackbar.messageTextFont = UIFont.customFont(ofType: .GalanoGrotesqueLight, withSize: 13.0)
        
        // Change snackbar background color
        snackbar.backgroundColor = backGroundColor
        
        snackbar.onTapBlock = { snackbar in
            snackbar.dismiss()
        }
        
        snackbar.onSwipeBlock = { (snackbar, direction) in
            
            // Change the animation type to simulate being dismissed in that direction
            if direction == .right {
                snackbar.animationType = .slideFromLeftToRight
            } else if direction == .left {
                snackbar.animationType = .slideFromRightToLeft
            } else if direction == .up {
                snackbar.animationType = .slideFromTopBackToTop
            } else if direction == .down {
                snackbar.animationType = .slideFromTopBackToTop
            }
            
            snackbar.dismiss()
        }
        
        snackbar.cornerRadius = 10.0
        // Change animation duration
        snackbar.animationDuration = 0.5
        
        // Animation type
        snackbar.animationType = .slideFromTopBackToTop
        snackbar.show()
    }
}

@discardableResult
public func ShowAlert(title: String?, message: String?, buttonTitles: [String]? = nil, highlightedButtonIndex: Int? = nil, completion: ((Int) -> Void)? = nil) -> UIAlertController {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    var allButtons = buttonTitles ?? [String]()
    if allButtons.count == 0 {
        allButtons.append(SmallTitles.ok)
    }
    
    for index in 0..<allButtons.count {
        let buttonTitle = allButtons[index]
        let action = UIAlertAction(title: buttonTitle, style: .default, handler: { (_) in
            completion?(index)
        })
        alertController.addAction(action)
        if let highlightedButtonIndex = highlightedButtonIndex, index == highlightedButtonIndex {
            alertController.preferredAction = action
        }
    }
    UIApplication.topViewController()?.present(alertController, animated: true, completion: nil)
    return alertController
}


// MARK: - Methods
public extension UIStoryboard {

    /// ProjectMagick: Get main storyboard for application
    static var main: UIStoryboard? {
        let bundle = Bundle.main
        guard let name = bundle.object(forInfoDictionaryKey: "UIMainStoryboardFile") as? String else { return nil }
        return UIStoryboard(name: name, bundle: bundle)
    }

    /// ProjectMagick: Instantiate a UIViewController using its class name
    ///
    /// - Parameter name: UIViewController type
    /// - Returns: The view controller corresponding to specified class name
    func instantiateViewController<T: UIViewController>(withClass name: T.Type) -> T? {
        return instantiateViewController(withIdentifier: String(describing: name)) as? T
    }

}
