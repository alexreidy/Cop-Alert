//
//  ViewController.h
//  Cop Alert
//
//  Created by Alex Reidy on 12/18/13.
//  Copyright (c) 2013 Alex Reidy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#include "SocketCommunicator.h"

@interface ViewController : UIViewController <NSStreamDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *map;

@property (nonatomic) SocketCommunicator *comm;

- (CLLocationCoordinate2D)getUserCoordinate;

- (void)showUserPositionOnMap;

- (void)removePins;

- (IBAction)alertButtonWasClicked:(id)sender;
- (IBAction)updateButtonWasClicked:(id)sender;

- (void)requestUpdateAddCop:(BOOL)toAddCop;
- (void)updateMapWithData:(NSString *)data;

- (void)regularlyUpdateMap;

- (void)onActive;

@end
