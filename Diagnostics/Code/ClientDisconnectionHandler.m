//
//  ClientDisconnectionHandler.m
//  Diagnostics
//
//  Created by Luke Redpath on 25/11/2013.
//  Copyright (c) 2013 Pusher. All rights reserved.
//

#import "ClientDisconnectionHandler.h"
#import <Pusher/Pusher.h>
#import <Reachability/Reachability.h>

@implementation ClientDisconnectionHandler {
    PTPusher *_client;
    Reachability *_reachability;
    NSInteger _manualReconnectAttempts;
    BOOL _reconnectsWhenReachabilityChanges;
}

- (id)initWithClient:(PTPusher *)client reachability:(Reachability *)reachability
{
    if ((self = [super init])) {
	    _client = client;
        _reachability = reachability;
        _reconnectAttemptLimit = 1;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_reachabilityChanged:) name:kReachabilityChangedNotification object:_reachability];
    }
    return self;
}

- (void)handleConnection
{
    _manualReconnectAttempts = 0;
}

- (void)handleDisconnectionWithError:(NSError *)error
{
    if (self.reconnectPermitted) {
        /* Pusher will not auto-reconnect in the following circumstances:
         *   1. Connection failed on initial connection attempt (calls pusher:connection:failedWithError:)
         *   2. Connection failed whilst connected (treated as a disconnect, typically due to network failure)
         *   3. Connection disconnected with error code in 4000-4099 range
         *
         * For the third scenario, we simply never reconnect.
         *
         * For the other scenarios, we can handle this by checking to see if we have reachability and
         * if we don't, waiting for reachability to change before manually reconnecting if the user
         * has toggled auto-reconnect.
         *
         * If we do have reachability, then we will optimistically try and reconnect, but with a limit
         * on the number of retries to prevent endless connect -> fail -> connect loops.
         */
        
        // do not reconnect if we get a Pusher 4000-4099 error code
        if ([error.domain isEqualToString:PTPusherErrorDomain]) return;

        if (_manualReconnectAttempts < self.reconnectAttemptLimit) {
            if ([_reachability isReachable]) {
                [self _performManualReconnect];
            }
            else {
                if ([self.delegate respondsToSelector:@selector(disconnectionHandlerWillWaitForReachabilityBeforeReconnecting:)]) {
                    [self.delegate disconnectionHandlerWillWaitForReachabilityBeforeReconnecting:self];
                }
                
                _reconnectsWhenReachabilityChanges = YES;
            }
        }
        else if (_manualReconnectAttempts == self.reconnectPermitted) {
            if ([self.delegate respondsToSelector:@selector(disconnectionHandlerReachedReconnectionLimit:)]) {
                [self.delegate disconnectionHandlerReachedReconnectionLimit:self];
            }
        }
    }
}

- (void)_performManualReconnect
{
    _manualReconnectAttempts++;
    
    if ([self.delegate respondsToSelector:@selector(disconnectionHandlerWillReconnect:attemptNumber:)]) {
        [self.delegate disconnectionHandlerWillReconnect:self attemptNumber:_manualReconnectAttempts];
    }
    
    [_client connect];
}

- (void)_reachabilityChanged:(NSNotification *)note
{
    if ([_reachability isReachable] && _reconnectsWhenReachabilityChanges) {
        _reconnectsWhenReachabilityChanges = NO;
        [self _performManualReconnect];
    }
}

@end
