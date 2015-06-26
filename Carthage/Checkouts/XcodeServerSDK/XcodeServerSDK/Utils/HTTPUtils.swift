//
//  HTTPUtils.swift
//  Buildasaur
//
//  Created by Honza Dvorsky on 13/12/2014.
//  Copyright (c) 2014 Honza Dvorsky. All rights reserved.
//

import Foundation

public class HTTP {
    
    public var session: NSURLSession
    
    public init(session: NSURLSession = NSURLSession.sharedSession()) {
        
        //disable all caching
        session.configuration.requestCachePolicy = .ReloadIgnoringLocalCacheData
        session.configuration.URLCache = nil
        
        self.session = session
    }
    
    public typealias Completion = (response: NSHTTPURLResponse?, body: AnyObject?, error: NSError?) -> ()

    public func sendRequest(request: NSURLRequest, completion: Completion) {
        
        guard let task = self.session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            //try to cast into HTTP response
            if let httpResponse = response as? NSHTTPURLResponse {
                
                guard error == nil else {
                    //error in the networking stack
                    completion(response: httpResponse, body: nil, error: error)
                    return
                }
                
                guard let data = data else {
                    //no body, but a valid response
                    completion(response: httpResponse, body: nil, error: nil)
                    return
                }
                
                let code = httpResponse.statusCode
                
                //error is nil and data isn't, let's check the content type
                if let contentType = httpResponse.allHeaderFields["Content-Type"] as? String {
                    
                    switch contentType {
                        
                    case let s where s.rangeOfString("application/json") != nil:
                        
                        let (json, error) = JSON.parse(data)
                        // let headers = httpResponse.allHeaderFields
                        completion(response: httpResponse, body: json, error: error)
                        
                    default:
                        //parse as UTF8 string
                        let string = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
                        
                        //check for common problems
                        let userInfo: NSDictionary? = {
                            
                            switch code {
                            case 401:
                                return ["Response": string]
                            default:
                                return nil;
                            }
                            }()
                        
                        let commonError: NSError? = {
                            if let userInfo = userInfo {
                                return Error.withInfo(nil, internalError: nil, userInfo: userInfo)
                            }
                            return nil
                            }()
                        
                        completion(response: httpResponse, body: string, error: commonError)
                    }
                } else {
                    
                    //no content type, probably a 204 or something - let's just send the code as the content object
                    completion(response: httpResponse, body: code, error: error)
                }
            } else {
                let e = error ?? Error.withInfo("Response is nil")
                completion(response: nil, body: nil, error: e)
            }
        }) else {
            completion(response: nil, body:nil, error:Error.withInfo("Could't create request"))
            return
        }
        
        task.resume()
    }

}

extension HTTP {
    
    public enum Method : String {
        case GET = "GET"
        case POST = "POST"
        case PATCH = "PATCH"
        case DELETE = "DELETE"
        case PUT = "PUT"
    }

    /**
    Class method for generating query String based on input Dictionary.
    
    - parameter query: Optional Dictionary of type [String: String]
    
    - returns: Query or empty String
    */
    public class func stringForQuery(query: [String : String]?) -> String {
        guard let query = query where query.count > 0 else {
            return ""
        }
        
        let pairs = query.keys.sort().map { "\($0)=\(query[$0]!)" }
        let full = "?" + "&".join(pairs)
        
        return full
    }
    
}
