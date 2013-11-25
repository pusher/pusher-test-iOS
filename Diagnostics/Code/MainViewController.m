//
//  ViewController.m
//  Diagnostics
//
//  Created by Alexander Schuch on 12/03/13.
//  Copyright (c) 2013 Pusher. All rights reserved.
//

#import "MainViewController.h"
#import "UIColor+PusherDiagnostics.h"
#import "PDLogger.h"
#import "PDDeviceInfo.h"
#import "ClientDisconnectionHandler.h"

#import <MessageUI/MessageUI.h>
#import <QuartzCore/QuartzCore.h>
#import <Reachability/Reachability.h>
#import <libPusher/PTPusher.h>
#import <libPusher/PTPusherChannel.h>
#import <libPusher/PTPusherEvent.h>
#import <libPusher/PTPusherAPI.h>

#define kManualReconnectionLimit 3

@interface MainViewController ()<PTPusherDelegate, ClientDisconnectionHandlerDelegate, MFMailComposeViewControllerDelegate> {
    PTPusher *_client;
    Reachability *_reachability;
    NSOperationQueue *_queue;
    ClientDisconnectionHandler *_disconnectionHandler;
}
@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // navigationbar
    UIImage *navigationBarBackground = [UIImage imageNamed:@"navigationbar_background_logo.png"];
    [self.navigationController.navigationBar setBackgroundImage:navigationBarBackground forBarMetrics:UIBarMetricsDefault];
    
    // info button
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [button addTarget:self action:@selector(_infoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:@"info_icon.png"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"info_icon.png"] forState:UIControlStateHighlighted];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = item;
    
    // logging
    [[PDLogger sharedInstance] addTarget:_logTextView];
    
    // view candy
    // connection container
    _connectionContainerView.layer.cornerRadius = 5.0f;
    _connectionContainerView.layer.borderColor = [[UIColor pusherDiagnosticsLightGrey] CGColor];
    _logTextView.layer.cornerRadius = 5.0f;
    //_logTextView.contentInset = UIEdgeInsetsMake(4,4,4,6);
    
    // switches
    _sslSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsSSLEnabled];
    _autoReconnectSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsReconnectEnabled];
    
    // setup
    [self _setupPusher];
    [self _setupReachability];
    [self _setupDisconnectionHandler];
    [self _setupBackgroundingNotifications];
    
    [_client connect];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/////////////////////////////////
#pragma mark - Pusher
/////////////////////////////////

- (void)_setupPusher
{
    BOOL encrypted = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsSSLEnabled];

    // setup client
    _client = [PTPusher pusherWithKey:kPusherKey delegate:self encrypted:encrypted];
    _client.reconnectDelay = 3.0;
  
    [_client connect];
    
    // change view / logs
    [self _pusherConnecting];
    
    // subscribe to channel and bind to event
    PTPusherChannel *channel = [_client subscribeToChannelNamed:@"channel"];
    [channel bindToEventNamed:@"event" handleWithBlock:^(PTPusherEvent *channelEvent) {
        // channelEvent.data is a NSDictianary of the JSON object received

        // convert back to json
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:channelEvent.data options:0 error:&error];
        
        if (!jsonData) {
            NSLog(@"JSON error: %@", error);
            [[PDLogger sharedInstance] logError:@"[App] JSON error: %@", error];
        } else {
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            [[PDLogger sharedInstance] logWarn:@"[Pusher] Event received: %@", jsonString];
        }
    }];
}

- (void)_setupDisconnectionHandler
{
    _disconnectionHandler = [[ClientDisconnectionHandler alloc] initWithClient:_client reachability:_reachability];
    _disconnectionHandler.reconnectPermitted = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsReconnectEnabled];
    _disconnectionHandler.reconnectAttemptLimit = kManualReconnectionLimit;
    _disconnectionHandler.delegate = self;
}


//////////////////////////////////
#pragma mark - Pusher Delegate Connection
//////////////////////////////////

- (void)pusher:(PTPusher *)pusher connectionDidConnect:(PTPusherConnection *)connection
{
    [_disconnectionHandler handleConnection];
    
    BOOL encrypted = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsSSLEnabled];
    NSString *sslStatus = encrypted ? @"SSL" : @"non SSL";
    
    [[PDLogger sharedInstance] logSuccess:@"[Pusher] connected (%@)", sslStatus];
    
    _pusherConnectionView.status = PDStatusViewStatusConnected;
    _connectButton.enabled = YES;
    [_connectButton setTitle:@"Disconnect" forState:UIControlStateNormal];
}

- (void)pusher:(PTPusher *)pusher connection:(PTPusherConnection *)connection failedWithError:(NSError *)error
{
    if (error) {
        [[PDLogger sharedInstance] logError:@"[Pusher] connection failed: %@", [error localizedDescription]];
    } else {
        [[PDLogger sharedInstance] logError:@"[Pusher] connection failed"];
    }
    
    _pusherConnectionView.status = PDStatusViewStatusDisconnected;
    _connectButton.enabled = YES;
    [_connectButton setTitle:@"Connect" forState:UIControlStateNormal];

    [_disconnectionHandler handleDisconnectionWithError:error];
}

- (void)pusher:(PTPusher *)pusher connection:(PTPusherConnection *)connection didDisconnectWithError:(NSError *)error willAttemptReconnect:(BOOL)reconnect
{
    if (error) {
        [[PDLogger sharedInstance] logError:@"[Pusher] didDisconnectWithError: %@ willAttemptReconnect: %@", [error localizedDescription], (reconnect ? @"YES" : @"NO")];
    } else {
        [[PDLogger sharedInstance] logInfo:@"[Pusher] disconnected"];
    }
    
    _pusherConnectionView.status = PDStatusViewStatusDisconnected;
    _connectButton.enabled = YES;
    [_connectButton setTitle:@"Connect" forState:UIControlStateNormal];
    

    // we only want to manually handle disconnections if reconnect will not happen automatically
    if (!reconnect) {
        [_disconnectionHandler handleDisconnectionWithError:error];
    }
}

- (BOOL)pusher:(PTPusher *)pusher connectionWillConnect:(PTPusherConnection *)connection
{
    [[PDLogger sharedInstance] logInfo:@"[Pusher] connecting"];
    _pusherConnectionView.status = PDStatusViewStatusConnecting;

    return YES;
}

- (BOOL)pusher:(PTPusher *)pusher connectionWillAutomaticallyReconnect:(PTPusherConnection *)connection afterDelay:(NSTimeInterval)delay
{
    if (_disconnectionHandler.reconnectPermitted) {
        [[PDLogger sharedInstance] logInfo:@"[Pusher] will reconnect in %.0f seconds", delay];
        _pusherConnectionView.status = PDStatusViewStatusWaiting;
        _connectButton.enabled = NO;
        [_connectButton setTitle:@"Reconnecting" forState:UIControlStateNormal];
    } else {
        [[PDLogger sharedInstance] logInfo:@"[Pusher] will not automatically reconnect", delay];
        _pusherConnectionView.status = PDStatusViewStatusDisconnected;
        _connectButton.enabled = YES;
        [_connectButton setTitle:@"Connect" forState:UIControlStateNormal];
    }

    return _disconnectionHandler.reconnectPermitted;
}

//////////////////////////////////
#pragma mark - Pusher Delegate Channel
//////////////////////////////////

- (void)pusher:(PTPusher *)pusher didSubscribeToChannel:(PTPusherChannel *)channel
{
    [[PDLogger sharedInstance] logSuccess:@"[Pusher] did subscribe to channel: %@", channel.name];
}

- (void)pusher:(PTPusher *)pusher didUnsubscribeFromChannel:(PTPusherChannel *)channel
{
    [[PDLogger sharedInstance] logInfo:@"[Pusher] did unsubscribe to channel: %@", channel.name];
}

- (void)pusher:(PTPusher *)pusher didFailToSubscribeToChannel:(PTPusherChannel *)channel withError:(NSError *)error
{
    [[PDLogger sharedInstance] logError:@"[Pusher] failed to subscribe to channel: %@; Error: %@", channel.name, error];
}

//- (void)pusher:(PTPusher *)pusher willAuthorizeChannelWithRequest:(NSMutableURLRequest *)request
//{
//    NSLog(@"[Pusher] authorize channel with request");
//    [request setValue:@"" forHTTPHeaderField:@"X-Pusher-Token"];
//}

- (void)pusher:(PTPusher *)pusher didReceiveErrorEvent:(PTPusherErrorEvent *)errorEvent
{
    [[PDLogger sharedInstance] logError:@"[Pusher] Error event %@", errorEvent];
}


/////////////////////////////////
#pragma mark - Reachability
/////////////////////////////////

- (void)_setupReachability
{
    [self _internetConnecting];
    
    _reachability = [Reachability reachabilityWithHostname:kPusherReachabilityHostname];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    [_reachability startNotifier];
}

- (void)_reachabilityChanged:(NSNotification *)notification
{
    if ([_reachability isReachable]) {
		[self _internetDidConnect];
	} else {
        [self _internetDidDisconnect];
	}
    
    [[PDLogger sharedInstance] logInfo:@"[Internet] %@", [_reachability currentReachabilityString]];
}

/////////////////////////////////
#pragma mark - Manual disconnection handling
/////////////////////////////////

- (void)disconnectionHandlerWillReconnect:(ClientDisconnectionHandler *)handler attemptNumber:(NSUInteger)attemptNumber
{
    [[PDLogger sharedInstance] logError:@"[Pusher] manual reconnect attempt %d of %d.", attemptNumber, handler.reconnectAttemptLimit];
}

- (void)disconnectionHandlerWillWaitForReachabilityBeforeReconnecting:(ClientDisconnectionHandler *)handler
{
    [[PDLogger sharedInstance] logError:@"[Pusher] will attempt re-connect when reachability changes."];
}

- (void)disconnectionHandlerReachedReconnectionLimit:(ClientDisconnectionHandler *)handler
{
    [[PDLogger sharedInstance] logError:@"[Pusher] reached manual reconnection limit."];
}

/////////////////////////////////
#pragma mark - Backgrounding
/////////////////////////////////

- (void)_setupBackgroundingNotifications
{
    // listen for background changes
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)_appDidEnterBackground:(NSNotification *)notificaiton
{
    [[PDLogger sharedInstance] logInfo:@"[App] did enter background"];
}

- (void)_appDidBecomeActive:(NSNotification *)notification
{
    [[PDLogger sharedInstance] logInfo:@"[App] did become active, connection status is %@", _client.connection.connected ? @"connected" : @"disconnected"];
    
    // work around
    // to make sure the state of the app is consistent even after
    // the app becomes active
    BOOL reconnect = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsReconnectEnabled];
    if (!reconnect && !_client.connection.connected) {
        [[PDLogger sharedInstance] logInfo:@"[Pusher] disconnected"];
        _pusherConnectionView.status = PDStatusViewStatusDisconnected;
        _connectButton.enabled = YES;
        [_connectButton setTitle:@"Connect" forState:UIControlStateNormal];
    }
}


/////////////////////////////////
#pragma mark - View Helper Pusher
/////////////////////////////////

- (void)_pusherConnecting
{
    _pusherConnectionView.status = PDStatusViewStatusConnecting;
    _connectButton.enabled = NO;
    [_connectButton setTitle:@"Connecting" forState:UIControlStateNormal];
}


/////////////////////////////////
#pragma mark - View Helper Internet
/////////////////////////////////

- (void)_internetConnecting
{
    _internetConnectionView.status = PDStatusViewStatusConnecting;
    _triggerEventButton.enabled = NO;
}

- (void)_internetDidConnect
{
    if ([_reachability isReachableViaWWAN]) {
        _internetConnectionView.status = PDStatusViewStatusConnectedCellular;
    } else if ([_reachability isReachableViaWiFi]) {
        _internetConnectionView.status = PDStatusViewStatusConnectedWiFi;
    } else {
        _internetConnectionView.status = PDStatusViewStatusConnected;
    }
    
    _triggerEventButton.enabled = YES;
}

- (void)_internetDidDisconnect
{
    _internetConnectionView.status = PDStatusViewStatusDisconnected;
    _triggerEventButton.enabled = NO;
}


/////////////////////////////////
#pragma mark - Networking
/////////////////////////////////

- (void)_sendEventTriggerRequest
{
    // send request to trigger message
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:kPusherTriggerEventURL];
    request.HTTPMethod = @"POST";
    
    [NSURLConnection sendAsynchronousRequest:request queue:_queue completionHandler:^(NSURLResponse *resonse, NSData *data, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _triggerEventButton.enabled = YES;
        });
        //NSLog(@"Trigger Event Response: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }];
}


/////////////////////////////////
#pragma mark - Email Support
/////////////////////////////////

- (IBAction)emailButtonPressed:(id)sender
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setSubject:@"Pusher iOS"];
        [mailViewController setMessageBody:[self _composeEmailMessage] isHTML:NO];
        [mailViewController setToRecipients:@[kPusherSupportEmail]];

        [self presentViewController:mailViewController animated:YES completion:nil];

    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"Your device does not support email." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)_composeEmailMessage
{
    NSString *deviceInfo = [PDDeviceInfo info];
    NSString *delimiter = @"\n\n----------\n\n";
    NSString *logString = [[[PDLogger sharedInstance] logStringWithTime] string];
    
    return [NSString stringWithFormat:@"Hey Pusherinos,\n\n\n\n\%@*Device Info*\n%@%@*Logs*\n%@", delimiter, deviceInfo, delimiter, logString];
}


/////////////////////////////////
#pragma mark - Button Actions
/////////////////////////////////

- (IBAction)connectButtonPressed:(id)sender
{
    if (_client.connection.connected) {
        [_client disconnect];
    } else {
        [self _pusherConnecting];
        [_client connect];
    }
}

- (IBAction)triggerEventButtonPressed:(id)sender
{
    [[PDLogger sharedInstance] logInfo:@"[Server] triggering event via REST API"];

    _triggerEventButton.enabled = NO;
    [self _sendEventTriggerRequest];
}

- (IBAction)clearButtonPressed:(id)sender
{
    _logTextView.text = @"";
    [[PDLogger sharedInstance] clear];
}

- (IBAction)sslSwitchChanged:(id)sender
{
    UISwitch *sslSwitch = (UISwitch *)sender;
    
    NSString *sslStatus = sslSwitch.on ? @"SSL" : @"non SSL";
    [[PDLogger sharedInstance] logInfo:@"[Pusher] switching to %@ connection...", sslStatus];

    [[NSUserDefaults standardUserDefaults] setBool:sslSwitch.on forKey:kUserDefaultsSSLEnabled];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [_client disconnect];
    [self _setupPusher];
}

- (IBAction)autoReconnectSwitchChanged:(id)sender
{
    UISwitch *reconnectSwitch = (UISwitch *)sender;
    
    // logging
    NSString *reconnectStatus = reconnectSwitch.on ? @"ON" : @"OFF";
    [[PDLogger sharedInstance] logInfo:@"[Pusher] auto reconnect %@", reconnectStatus];
    
    // user defaults
    [[NSUserDefaults standardUserDefaults] setBool:reconnectSwitch.on forKey:kUserDefaultsReconnectEnabled];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    _disconnectionHandler.reconnectPermitted = reconnectSwitch.on;
}

- (void)_infoButtonPressed:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"InfoViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
