//
//  ClientDisconnectionHandler.h
//  Diagnostics
//
//  Created by Luke Redpath on 25/11/2013.
//  Copyright (c) 2013 Pusher. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PTPusher;
@class Reachability;

@protocol ClientDisconnectionHandlerDelegate;

/* This class is used to handle client disconnections and failures
 * in any scenario where the client will not auto-reconnect.
 */
@interface ClientDisconnectionHandler : NSObject

@property (nonatomic, assign) BOOL reconnectPermitted;
@property (nonatomic, assign) NSUInteger reconnectAttemptLimit;
@property (nonatomic, assign) id<ClientDisconnectionHandlerDelegate> delegate;

- (id)initWithClient:(PTPusher *)client reachability:(Reachability *)reachability;

- (void)handleConnection;
- (void)handleDisconnectionWithError:(NSError *)error;

@end

@protocol ClientDisconnectionHandlerDelegate <NSObject>

@optional

- (void)disconnectionHandlerWillReconnect:(ClientDisconnectionHandler *)handler attemptNumber:(NSUInteger)attemptNumber;
- (void)disconnectionHandlerWillWaitForReachabilityBeforeReconnecting:(ClientDisconnectionHandler *)handler;
- (void)disconnectionHandlerReachedReconnectionLimit:(ClientDisconnectionHandler *)handler;

@end
