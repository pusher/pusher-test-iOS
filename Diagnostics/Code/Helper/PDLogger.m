//
//  PDLogger.m
//  Diagnostics
//
//  Created by Alexander Schuch on 13/03/13.
//  Copyright (c) 2013 Pusher. All rights reserved.
//

#import "PDLogger.h"
#import "NSDate+Utilities.h"

#define kPDLoggerColorSuccess       [UIColor colorWithRed:37/255.0 green:180/255.0 blue:127/255.0 alpha:1.0]
#define kPDLoggerColorWarn          [UIColor colorWithRed:226/255.0 green:154/255.0 blue:80/255.0 alpha:1.0]
#define kPDLoggerColorError         [UIColor colorWithRed:206/255.0 green:75/255.0 blue:73/255.0 alpha:1.0]
#define kPDLoggerColorInfo          [UIColor grayColor]


NSString *const PDLoggerLogReceivedNotification = @"PDLoggerLogReceivedNotification";

@implementation PDLogger {
    NSMutableArray *_logArray;
    NSMutableArray *_logArrayWithTime;
    NSMutableSet *_targets;
}

+ (PDLogger *)sharedInstance
{
    static dispatch_once_t p = 0;    
    __strong static id sharedObject = nil;
    dispatch_once(&p, ^{
        sharedObject = [[self alloc] init];
    });
    return sharedObject;
}

- (id)init
{
    self = [super init];
    if (self) {
        _logArray = [[NSMutableArray alloc] init];
        _logArrayWithTime = [[NSMutableArray alloc] init];
        _targets = [[NSMutableSet alloc] init];
    }
    return self;
}

////////////////////////////////////////
#pragma mark - Logging
////////////////////////////////////////

- (void)logSuccess:(NSString *)format, ...
{
    va_list arg_list;
    va_start (arg_list, format);
    
    NSString *message = [[NSString alloc] initWithFormat:format arguments:arg_list];
    [self _logMessage:message withColor:kPDLoggerColorSuccess];

    va_end(arg_list);
}

- (void)logWarn:(NSString *)format, ...
{
    va_list arg_list;
    va_start (arg_list, format);
    
    NSString *message = [[NSString alloc] initWithFormat:format arguments:arg_list];
    
    [self _logMessage:message withColor:kPDLoggerColorWarn];
    va_end(arg_list);
}

- (void)logError:(NSString *)format, ...
{
    va_list arg_list;
    va_start (arg_list, format);
    
    NSString *message = [[NSString alloc] initWithFormat:format arguments:arg_list];
    
    [self _logMessage:message withColor:kPDLoggerColorError];
    va_end(arg_list);
}

- (void)logInfo:(NSString *)format, ...
{
    va_list arg_list;
    va_start (arg_list, format);
    
    NSString *message = [[NSString alloc] initWithFormat:format arguments:arg_list];
    
    [self _logMessage:message withColor:kPDLoggerColorInfo];
    va_end(arg_list);
}


////////////////////////////////////////
#pragma mark - Logging Helper
////////////////////////////////////////

- (void)_logMessage:(NSString *)message withColor:(UIColor *)color
{
    UIFont *font = [UIFont systemFontOfSize:13.0];
    NSDictionary *attributes = @{NSForegroundColorAttributeName: color,
                                 NSFontAttributeName: font};
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:message attributes:attributes];
    [_logArray addObject:string];
    
    NSDate *date = [NSDate date];
    NSString *dateString = [NSString stringWithFormat:@"%i:%i:%i ", [date hour], [date minute], [date seconds]];
    NSMutableAttributedString *stringWithTime = [[NSMutableAttributedString alloc] initWithString:dateString];
    [stringWithTime appendAttributedString:string];
    
    [_logArrayWithTime addObject:stringWithTime];
    
    [self _postNotification];
    [self _updateTargets];
}

- (void)_postNotification
{
    NSDictionary *userInfo = @{@"log": self.logString};
    [[NSNotificationCenter defaultCenter] postNotificationName:PDLoggerLogReceivedNotification object:self userInfo:userInfo];
}

- (void)_updateTargets
{
    NSAttributedString *logString = self.logString;
    
    for (UITextView *view in _targets) {
        if ([view respondsToSelector:@selector(setAttributedText:)]) {
            view.attributedText = logString;
            [view scrollRangeToVisible:NSMakeRange(view.attributedText.length - 1, 1)];
        }
    }
}


////////////////////////////////////////
#pragma mark - Targets
////////////////////////////////////////

- (void)addTarget:(UITextView *)view
{
    [_targets addObject:view];
}

- (void)removeTarget:(UITextView *)view
{
    [_targets removeObject:view];
}

- (void)removeAllTargets
{
    [_targets removeAllObjects];
}


////////////////////////////////////////
#pragma mark - Getter
////////////////////////////////////////

- (NSArray *)logs
{
    return [_logArray copy];
}

- (NSArray *)logsWithTime
{
    return [_logArrayWithTime copy];
}

- (NSAttributedString *)logString
{
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] init];

    NSAttributedString *delimiter = [[NSAttributedString alloc] initWithString:@"\n"];
    for (NSAttributedString *str in _logArray) {
        if (result.length) {
            [result appendAttributedString:delimiter];
        }
        [result appendAttributedString:str];
    }
    
    return [result copy];
}

- (NSAttributedString *)logStringWithTime
{
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] init];
    
    NSAttributedString *delimiter = [[NSAttributedString alloc] initWithString:@"\n"];
    for (NSAttributedString *str in _logArrayWithTime) {
        if (result.length) {
            [result appendAttributedString:delimiter];
        }
        [result appendAttributedString:str];
    }
    
    return [result copy];
}


////////////////////////////////////////
#pragma mark - Clear
////////////////////////////////////////

- (void)clear
{
    _logArray = [[NSMutableArray alloc] init];
    _logArrayWithTime = [[NSMutableArray alloc] init];
}

@end
