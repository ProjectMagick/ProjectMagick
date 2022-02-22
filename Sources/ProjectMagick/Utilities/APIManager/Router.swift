//
//  File.swift
//  
//
//  Created by Kishan on 29/01/22.
//

import UIKit
import Alamofire


public struct Route {

    public let endPath: String
    public let method: Alamofire.HTTPMethod
    public var parameters: Parameters?
    public var object : Codable?
    public var queryParameters : [String:String]?
    
    public var encoding: Alamofire.ParameterEncoding {
        switch method {
        case .put, .patch, .delete, .post:
            return JSONEncoding.default
        default:
            return URLEncoding.default
        }
    }
}

public extension Route {
    
    init(endPoint : String, httpMethod : Alamofire.HTTPMethod) {
        endPath = endPoint
        method = httpMethod
    }
    
    init(endPoint : String, httpMethod : Alamofire.HTTPMethod, queryParams : [String:String]) {
        endPath = endPoint
        method = httpMethod
        queryParameters = queryParams
    }
    
    init(endPoint : String, httpMethod : Alamofire.HTTPMethod, params : Parameters) {
        endPath = endPoint
        method = httpMethod
        parameters = params
    }
    
    init(endPoint : String, httpMethod : Alamofire.HTTPMethod, modelObject : Codable) {
        endPath = endPoint
        method = httpMethod
        object = modelObject
    }
    
    init(endPoint : String, httpMethod : Alamofire.HTTPMethod, params : Parameters, queryParams : [String:String]) {
        endPath = endPoint
        method = httpMethod
        parameters = params
        queryParameters = queryParams
    }
    
    init(endPoint : String, httpMethod : Alamofire.HTTPMethod, modelObject : Codable, queryParams : [String:String]) {
        endPath = endPoint
        method = httpMethod
        object = modelObject
        queryParameters = queryParams
    }
    
}



/*
enum Router : URLRequestConvertible {
    
    case login(params : Parameters)
    
    
    var route: Route {
        switch self {
        case let .login(params):
            return Route(endPoint: "api/v2/ohlc", httpMethod: .get, params: params)
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        
        var requestUrl = EnvironmentVariables.BaseUrl
        if let queryparams = route.queryParameters {
            requestUrl.appendQueryParameters(queryparams)
        }
        var mutableURLRequest = URLRequest(url: requestUrl.appendingPathComponent(route.endPath))
        mutableURLRequest.httpMethod = route.method.rawValue
        
        var header = HTTPHeaders()
        header.add(.acceptLanguage(""))
        header.add(.authorization(bearerToken: ""))
        header.add(.authorization(""))
        mutableURLRequest.headers = header
        
        print("Request Details-----> ", mutableURLRequest)
        print("Header Details-----> ", mutableURLRequest.allHTTPHeaderFields ?? "")
        
        if let data = route.object {
            print("Parameters -----> ", data.toDictionary() ?? "")
            let actualData = data.toData()
            mutableURLRequest.httpBody = actualData
            return mutableURLRequest
        } else {
            print("Parameters -----> ", route.parameters ?? "")
            return try route.encoding.encode(mutableURLRequest, with: route.parameters)
        }
    }
    
    
}

*/
 
