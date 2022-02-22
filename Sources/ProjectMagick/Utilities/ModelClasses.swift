//
//  File.swift
//  
//
//  Created by Kishan on 01/02/22.
//

import UIKit


/// Used for country list json file.
public struct Countries : Codable {
    public var name = ""
    public var dial = ""
    public var code = ""
}

/// Can be used for Generic response type.
public struct Response<T:Codable> : Codable {
    public var code = 0
    public var message = ""
    public var data : T
}

/// Can be used for simple response type.
public class GeneralModel : Codable {
    public var message = ""
    public var code = 0
    public var data : EmptyObject? = EmptyObject()
    
    enum CodingKeys : String, CodingKey {
        case message, code
    }
}

public struct EmptyObject: Codable {
    
}
