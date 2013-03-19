//
//  UIColor+PusherDiagnostics.h
//  Diagnostics
//
//  Created by Alexander Schuch on 12/03/13.
//  Copyright (c) 2013 Pusher. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (PusherDiagnostics)

+ (UIColor *)pusherDiagnosticsLightGrey;

+ (UIColor *)pusherDiagnosticsSuccess;
+ (UIColor *)pusherDiagnosticsError;
+ (UIColor *)pusherDiagnosticsWarn;

@end
