//
//  Errors.swift
//  Buildasaur
//
//  Created by Honza Dvorsky on 07/03/2015.
//  Copyright (c) 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

public enum BuildaError: String {
    case UnknownError = "Unknown error"
}

public struct Error {
    
    public static func fromType(type: BuildaError) -> NSError {
        return self.withInfo(type.rawValue)
    }
    
    public static func withInfo(info: String?, internalError: NSError? = nil, userInfo: NSDictionary? = nil) -> NSError {
        let finalInfo = NSMutableDictionary()
        
        if let info = info {
            finalInfo[NSLocalizedDescriptionKey] = info
        }
        
        if let internalError = internalError {
            finalInfo["encountered_error"] = internalError
        }
        
        if let userInfo = userInfo {
            finalInfo.addEntriesFromDictionary(userInfo as [NSObject : AnyObject])
        }
        
        return NSError(domain: "com.honzadvorsky.Buildasaur", code: 0, userInfo: finalInfo as [NSObject : AnyObject])
    }
}

struct StringError: ErrorType {
    
    let description: String
    let _domain: String = ""
    let _code: Int = 0
    
    init(_ description: String) {
        self.description = description
    }
}
