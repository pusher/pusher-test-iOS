//
//  UIColor+PusherDiagnostics.m
//  Diagnostics
//
//  Created by Alexander Schuch on 12/03/13.
//  Copyright (c) 2013 Pusher. All rights reserved.
//

#import "UIColor+PusherDiagnostics.h"

@implementation UIColor (PusherDiagnostics)


/////////////////////////////////
#pragma mark - Branding Colors
/////////////////////////////////

+ (UIColor *)pusherDiagnosticsLightGrey
{
    return [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0];
}


/////////////////////////////////
#pragma mark - Status View Colors
/////////////////////////////////

+ (UIColor *)pusherDiagnosticsSuccess
{
    return [UIColor colorWithRed:37/255.0 green:180/255.0 blue:127/255.0 alpha:1.0];
}

+ (UIColor *)pusherDiagnosticsError
{
    return [UIColor colorWithRed:206/255.0 green:75/255.0 blue:73/255.0 alpha:1.0];
}

+ (UIColor *)pusherDiagnosticsWarn
{
    return [UIColor colorWithRed:226/255.0 green:154/255.0 blue:80/255.0 alpha:1.0];
}

@end
