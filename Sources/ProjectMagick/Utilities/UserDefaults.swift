//
//  File.swift
//  
//
//  Created by Kishan on 17/12/21.
//

import UIKit
import Combine

public typealias Preferences = UserDefaults


// MARK: - Methods
public extension UserDefaults {

    /// ProjectMagick: get object from UserDefaults by using subscript
    ///
    /// - Parameter key: key in the current user's defaults database.
    subscript(key: String) -> Any? {
        get {
            return object(forKey: key)
        }
        set {
            set(newValue, forKey: key)
        }
    }

    /// ProjectMagick: Float from UserDefaults.
    ///
    /// - Parameter forKey: key to find float for.
    /// - Returns: Float object for key (if exists).
    func float(forKey key: String) -> Float? {
        return object(forKey: key) as? Float
    }

    /// ProjectMagick: Date from UserDefaults.
    ///
    /// - Parameter forKey: key to find date for.
    /// - Returns: Date object for key (if exists).
    func date(forKey key: String) -> Date? {
        return object(forKey: key) as? Date
    }

    /// ProjectMagick: Retrieves a Codable object from UserDefaults.
    ///
    /// - Parameters:
    ///   - type: Class that conforms to the Codable protocol.
    ///   - key: Identifier of the object.
    ///   - decoder: Custom JSONDecoder instance. Defaults to `JSONDecoder()`.
    /// - Returns: Codable object for key (if exists).
    func object<T: Codable>(_ type: T.Type, with key: String, usingDecoder decoder: JSONDecoder = JSONDecoder()) -> T? {
        guard let data = value(forKey: key) as? Data else { return nil }
        return try? decoder.decode(type.self, from: data)
    }

    /// ProjectMagick: Allows storing of Codable objects to UserDefaults.
    ///
    /// - Parameters:
    ///   - object: Codable object to store.
    ///   - key: Identifier of the object.
    ///   - encoder: Custom JSONEncoder instance. Defaults to `JSONEncoder()`.
    func set<T: Codable>(object: T, forKey key: String, usingEncoder encoder: JSONEncoder = JSONEncoder()) {
        let data = try? encoder.encode(object)
        set(data, forKey: key)
    }

}



/** If you are using standard Data type i.e. Int, Float, String don't forget to mention key name. **/
@propertyWrapper
public struct UserDefault<Value : Codable> {
    
    public let key: String
    public let defaultValue : Value
    
//    private let publisher = PassthroughSubject<Value, Never>()
    
    public var wrappedValue : Value {
        get {
            return UserDefaults.standard.object(Value.self, with: key) ?? defaultValue
        } set {
            UserDefaults.standard.set(object: newValue, forKey: key)
//            publisher.send(newValue)
        }
    }
}

public extension UserDefault where Value : ExpressibleByNilLiteral {
    
    
    init(key : String) {
        self.init(key: key, defaultValue : nil)
    }
    
    /// Use this initializer when you store object, it will consider class name as key.
    /// - Parameter isObject: It must be true if you are using this initalizer.
    init(isObject : Bool) {
        if !isObject {
            fatalError("It can not be false, use another initalize method instead.")
        }
        self.init(key: "\(Value.self)", defaultValue : nil)
    }
    
}

/*
public extension UserDefault {
    
    var projectedValue: AnyPublisher<Value, Never> {
        return publisher.eraseToAnyPublisher()
    }
    
}
*/
