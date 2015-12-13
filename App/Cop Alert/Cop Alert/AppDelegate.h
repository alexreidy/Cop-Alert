//
//  AppDelegate.h
//  Cop Alert
//
//  Created by Alex Reidy on 12/18/13.
//  Copyright (c) 2013 Alex Reidy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SocketCommunicator.h"
#import "ViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic) ViewController *viewController;

@property (nonatomic) StreamDelegate *streamDelegate;

@end
