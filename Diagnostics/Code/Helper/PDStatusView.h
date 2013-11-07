//
//  PDStatusView.h
//  Diagnostics
//
//  Created by Alexander Schuch on 13/03/13.
//  Copyright (c) 2013 Pusher. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PDStatusViewStatus) {
    PDStatusViewStatusConnecting,
    PDStatusViewStatusReconnecting,
    PDStatusViewStatusWaiting,
    PDStatusViewStatusConnected,
    PDStatusViewStatusConnectedWiFi,
    PDStatusViewStatusConnectedCellular,
    PDStatusViewStatusDisconnected
};

@interface PDStatusView : UIView

@property(assign, nonatomic) PDStatusViewStatus status;
@property(strong, nonatomic) UILabel *statusLabel;

@end
