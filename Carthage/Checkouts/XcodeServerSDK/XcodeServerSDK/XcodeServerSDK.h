//
//  XcodeServerSDK.h
//  XcodeServerSDK
//
//  Created by Honza Dvorsky on 11/06/2015.
//  Copyright (c) 2015 Honza Dvorsky. All rights reserved.
//

#import "TargetConditionals.h"

#if TARGET_OS_IPHONE
@import Foundation;
#elif TARGET_OS_MAC
#import <Cocoa/Cocoa.h>
#endif

//! Project version number for XcodeServerSDK.
FOUNDATION_EXPORT double XcodeServerSDKVersionNumber;

//! Project version string for XcodeServerSDK.
FOUNDATION_EXPORT const unsigned char XcodeServerSDKVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <XcodeServerSDK/PublicHeader.h>

