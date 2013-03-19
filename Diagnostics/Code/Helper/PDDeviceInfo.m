//
//  PDDeviceInfo.m
//  Diagnostics
//
//  Created by Alexander Schuch on 14/03/13.
//  Copyright (c) 2013 Pusher. All rights reserved.
//

#import "PDDeviceInfo.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <sys/utsname.h>

@implementation PDDeviceInfo

+ (NSString *)info
{
    return [NSString stringWithFormat:@"Device: %@\nOS Version: %@\n Carrier: %@", [self _deviceName], [self _osVersion], [self _carrier]];
}

+ (NSString *)_deviceName {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

+ (NSString *)_osVersion
{
    return [[UIDevice currentDevice] systemVersion];
}

+ (NSString *)_carrier
{
    CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netInfo subscriberCellularProvider];
    return [carrier carrierName];
}

@end
