//
//  PDStatusView.m
//  Diagnostics
//
//  Created by Alexander Schuch on 13/03/13.
//  Copyright (c) 2013 Pusher. All rights reserved.
//

#import "PDStatusView.h"
#import "UIColor+PusherDiagnostics.h"

#import <QuartzCore/QuartzCore.h>

@implementation PDStatusView

- (id)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self _setup];
}

/////////////////////////////////
#pragma mark - setup
/////////////////////////////////

- (void)_setup
{
    self.status = PDStatusViewStatusConnecting;
    
    // corner radius
    self.layer.cornerRadius = 5.0f;
    
    // status label
    _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 140, 35)];
    _statusLabel.backgroundColor = [UIColor clearColor];
    _statusLabel.font =[UIFont systemFontOfSize:15];
    [self addSubview:_statusLabel];
}


/////////////////////////////////
#pragma mark - Setter
/////////////////////////////////

- (void)setStatus:(PDStatusViewStatus)status
{
    _status = status;
    
    UIColor *color;
    NSString *text;
    
    switch (_status) {
        case PDStatusViewStatusConnecting:
            text = @"Connecting...";
            color = [UIColor pusherDiagnosticsWarn];
            break;
            
        case PDStatusViewStatusReconnecting:
            text = @"Reconnecting...";
            color = [UIColor pusherDiagnosticsWarn];
            break;
            
        case PDStatusViewStatusConnected:
            text = @"Connected";
            color = [UIColor pusherDiagnosticsSuccess];
            break;
            
        case PDStatusViewStatusConnectedWiFi:
            text = @"Connected (WiFi)";
            color = [UIColor pusherDiagnosticsSuccess];
            break;
            
        case PDStatusViewStatusConnectedCellular:
            text = @"Connected (Cellular)";
            color = [UIColor pusherDiagnosticsSuccess];
            break;
            
        case PDStatusViewStatusDisconnected:
            text = @"Disconnected";
            color = [UIColor pusherDiagnosticsError];
            break;
            
        default:
            break;
    }
    
    self.backgroundColor = color;
    _statusLabel.text = text;
}

@end
