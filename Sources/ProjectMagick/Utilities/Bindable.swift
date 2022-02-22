//
//  File.swift
//  
//
//  Created by Kishan on 29/12/21.
//

import Foundation

public class Bindable<T> {

    public var value: T {
        didSet {
            listener?(value)
        }
    }

    private var listener: ((T) -> Void)?

    public init(_ value: T) {
        self.value = value
    }

}

public extension Bindable {
    
    func bind(_ closure: @escaping (T) -> Void) {
        closure(value)
        listener = closure
    }
    
}
