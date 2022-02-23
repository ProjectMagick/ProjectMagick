//
//  File.swift
//  
//
//  Created by Kishan on 03/01/22.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

public extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
                                                     y: locationOfTouchInLabel.y - textContainerOffset.y);
        
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
    func gettappedOnText(label: UILabel, text targetRange: String) -> (isTapped : Bool , value : String) {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
                                                     y: locationOfTouchInLabel.y - textContainerOffset.y);
        
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        var rangeString = NSMakeRange(0, label.text!.count)
        
        var arrofRange : [NSRange] = []
        
        while (rangeString.length != NSNotFound && rangeString.location != NSNotFound) {
            
            //Get the range of search text
            let colorRange = (label.text! as NSString).range(of: targetRange, options: NSString.CompareOptions(rawValue: 0), range: rangeString)
            
            if (colorRange.location == NSNotFound) {
                //If location is not present in the string the loop will break
                break
            } else {
                //This line of code colour the searched text
                //                attribute.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red , range: colorRange)
                //                lblContent.attributedText = attribute
                arrofRange.append(colorRange)
                rangeString = NSMakeRange(colorRange.location + colorRange.length, rangeString.length - (colorRange.location + colorRange.length))
            }
        }
        
        for range in arrofRange {
            if NSLocationInRange(indexOfCharacter, range) {
                return (true, targetRange)
            }
        }
        return (false, targetRange)
    }
}



public enum PanVerticalDirection {
    case either
    case up
    case down
}

public enum PanHorizontalDirection {
    case either
    case left
    case right
}

public enum PanDirection {
    case vertical(PanVerticalDirection)
    case horizontal(PanHorizontalDirection)
}

/** Useful class when you need callbacks only for one particular direction. */
public class PanDirectionGestureRecognizer: UIPanGestureRecognizer {
    
    public let direction: PanDirection
    public var data : Codable?
    

    public init(direction: PanDirection, target: AnyObject, action: Selector) {
        self.direction = direction
        super.init(target: target, action: action)
    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)

        if state == .began {
            let vel = velocity(in: view)
            switch direction {
            // expecting horizontal but moving vertical, cancel
            case .horizontal(_) where abs(vel.y) > abs(vel.x):
                state = .cancelled

            // expecting vertical but moving horizontal, cancel
            case .vertical(_) where abs(vel.x) > abs(vel.y):
                state = .cancelled

            // expecting horizontal and moving horizontal
            case .horizontal(let hDirection):
                switch hDirection {
                // expecting left but moving right, cancel
                case .left where vel.x > 0: state = .cancelled

                // expecting right but moving left, cancel
                case .right where vel.x < 0: state = .cancelled
                default: break
                }

            // expecting vertical and moving vertical
            case .vertical(let vDirection):
                switch vDirection {
                // expecting up but moving down, cancel
                case .up where vel.y > 0: state = .cancelled

                // expecting down but moving up, cancel
                case .down where vel.y < 0: state = .cancelled
                default: break
                }
            }
        }
    }
}
