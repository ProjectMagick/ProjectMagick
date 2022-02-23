//
//  Data.swift
//  ProjectMagick
//
//  Created by Kishan on 31/05/20.
//  Copyright © 2020 Kishan. All rights reserved.
//

import Foundation

public extension Data {
    
    var bytes: [UInt8] {
        return [UInt8](self)
    }
    
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
    
    func toObject<T : Codable>(type : T.Type) -> T? {
        do {
            let object = try JSONDecoder().decode(type, from: self)
            return object
        } catch let error {
            print(error)
        }
        return nil
    }
    
    func toDictionary() -> [String:Any]? {
        do {
            let json = try JSONSerialization.jsonObject(with: self, options: []) as? [String : Any]
            return json
        } catch let err {
            print(err)
        }
        return nil
    }
    
    /// ProjectMagick: String by encoding Data using the given encoding (if applicable).
    ///
    /// - Parameter encoding: encoding.
    /// - Returns: String by encoding Data using the given encoding (if applicable).
    func string(encoding: String.Encoding) -> String? {
        return String(data: self, encoding: encoding)
    }

    /// ProjectMagick: Returns a Foundation object from given JSON data.
    ///
    /// - Parameter options: Options for reading the JSON data and creating the Foundation object.
    ///
    ///   For possible values, see `JSONSerialization.ReadingOptions`.
    /// - Returns: A Foundation object from the JSON data in the receiver, or `nil` if an error occurs.
    /// - Throws: An `NSError` if the receiver does not represent a valid JSON object.
    func jsonObject(options: JSONSerialization.ReadingOptions = []) throws -> Any {
        return try JSONSerialization.jsonObject(with: self, options: options)
    }
}
