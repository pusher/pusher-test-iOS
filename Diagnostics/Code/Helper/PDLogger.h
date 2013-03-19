//
//  PDLogger.h
//  Diagnostics
//
//  Created by Alexander Schuch on 13/03/13.
//  Copyright (c) 2013 Pusher. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const PDLoggerLogReceivedNotification;

@interface PDLogger : NSObject

@property(strong, nonatomic, readonly) NSArray *logs;
@property(strong, nonatomic, readonly) NSAttributedString *logString;
@property(strong, nonatomic, readonly) NSArray *logsWithTime;
@property(strong, nonatomic, readonly) NSAttributedString *logStringWithTime;

+ (PDLogger *)sharedInstance;

- (void)logSuccess:(NSString *)format, ...;
- (void)logWarn:(NSString *)format, ...;
- (void)logError:(NSString *)format, ...;
- (void)logInfo:(NSString *)format, ...;

- (void)addTarget:(UITextView *)view;
- (void)removeTarget:(UITextView *)view;
- (void)removeAllTargets;

- (void)clear;
@end
