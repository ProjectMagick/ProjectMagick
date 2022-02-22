//
//  File.swift
//
//
//  Created by Kishan on 29/12/21.
//

import UIKit


//MARK:- Need Protocol to maintain typecast
public protocol FormatStyle { }

extension NSObject: FormatStyle { }

public extension FormatStyle where Self: UIView {

    @discardableResult func setRound() -> Self {
        self.layer.cornerRadius = self.frame.size.height / 2.0
        self.clipsToBounds = true
        return self
    }
    
    @discardableResult func cornerRadius(cornerRadius: CGFloat) -> NSObject {
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
        return self
    }
}
