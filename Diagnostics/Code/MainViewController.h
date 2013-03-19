//
//  ViewController.h
//  Diagnostics
//
//  Created by Alexander Schuch on 12/03/13.
//  Copyright (c) 2013 Pusher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDStatusView.h"

@interface MainViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *connectionContainerView;
@property (weak, nonatomic) IBOutlet PDStatusView *pusherConnectionView;
@property (weak, nonatomic) IBOutlet PDStatusView *internetConnectionView;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UIButton *triggerEventButton;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@property (weak, nonatomic) IBOutlet UISwitch *sslSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *autoReconnectSwitch;

- (IBAction)connectButtonPressed:(id)sender;
- (IBAction)triggerEventButtonPressed:(id)sender;
- (IBAction)emailButtonPressed:(id)sender;
- (IBAction)clearButtonPressed:(id)sender;
- (IBAction)sslSwitchChanged:(id)sender;
- (IBAction)autoReconnectSwitchChanged:(id)sender;

@end
