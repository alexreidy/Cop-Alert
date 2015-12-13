//
//  ViewController.m
//  Cop Alert
//
//  Created by Alex Reidy on 12/18/13.
//  Copyright (c) 2013 Alex Reidy. All rights reserved.
//

#import "ViewController.h"
#import "ConnDelegate.h"
#include "Annotation.h"

NSString *IP = @"173.255.197.174";

// IF CANNOT CONNECT:
//     POLL DROPBOX FILE WITH SERVER ADDR
//     TRY TO CONNECT TO ADDR

// Reconnect to server whenever app is brought to foreground.

NSMutableArray *coordinateArray;

BOOL updating = NO;

int numCopsSubmitted = 0;

NSString *formatTimeSince(int secondsElapsed)
{
    NSMutableString *timeSinceAdded;
    if (secondsElapsed >= 3600) {
        float hoursSinceAdded = (float) secondsElapsed / 3600;
        NSString *grammaticallyCorrectHour = (int) hoursSinceAdded > 1 ? @"hours" : @"hour";
        float proportionOfHourElapsed = hoursSinceAdded - (int) hoursSinceAdded;
        int minutes = proportionOfHourElapsed * 60;
        NSString *grammaticallyCorrectMinute = minutes > 1 ? @"minutes" : @"minute";
        
        timeSinceAdded = [
            [NSMutableString alloc] initWithFormat:@"Spotted %d %@ ",
            (int) hoursSinceAdded, grammaticallyCorrectHour
        ];
        
        if (minutes > 1) {
            [timeSinceAdded appendFormat:@"and %d %@ ", minutes, grammaticallyCorrectMinute];
        }
        
        [timeSinceAdded appendString:@"ago"];
        
    } else if (secondsElapsed >= 60) {
        int minutes = (int) ((float) secondsElapsed / 60);
        timeSinceAdded = [
            [NSMutableString alloc] initWithFormat:@"Spotted %d %@ ago",
            minutes, minutes > 1 ? @"minutes" : @"minute"
        ];
    } else {
        if (secondsElapsed == 0) {
            timeSinceAdded = @"Spotted just now!";
        } else {
            timeSinceAdded = [
                [NSMutableString alloc] initWithFormat:@"Spotted %d %@ ago",
                secondsElapsed, secondsElapsed > 1 ? @"seconds" : @"second"
            ];
        }
    }
    
    return timeSinceAdded;
}

@interface ViewController ()

@end

@implementation ViewController

- (void)removePins
{
    [self.map removeAnnotations:self.map.annotations];
    [self.map setShowsUserLocation:YES];
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)streamEvent {
    if (streamEvent == NSStreamEventHasBytesAvailable) {
        if (aStream == self.comm.inputStream) {
            uint8_t buffer[1024];
            int len;
            len = [self.comm.inputStream read:buffer maxLength:sizeof(buffer)];
            NSString *copData = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
            if (copData.length > 3) {
                [self updateMapWithData:copData];
            } else {
                [self updateMapWithData:@""];
            }
            
        }
    }
}

- (void)requestUpdateAddCop:(BOOL)toAddCop {
    [self showUserPositionOnMap];
    CLLocationCoordinate2D userpos = [self getUserCoordinate];
    [self.comm writeToServer:[NSString stringWithFormat:@"UPDATE,%f,%f,%d", userpos.latitude, userpos.longitude, toAddCop ? 1 : 0]];
}

- (void)updateMapWithData:(NSString *)data {
    coordinateArray = [[NSMutableArray alloc] init];
    NSMutableString *coordinate = [[NSMutableString alloc] initWithString:@""];
    
    // There's an issue with receiving lots of data at once.
    // We need to wait and read EVERYTHING before acting.
    
    for (int i = 0; i < data.length; i++) {
        char c = [data characterAtIndex:i];
        
        if (c != '\n') {
            [coordinate appendFormat:@"%c", c];
        } else {
            if (coordinate != nil) {
                [coordinateArray addObject:coordinate];
            }
            
            coordinate = [[NSMutableString alloc] initWithString:@""];
        }
    }
    
    [self removePins];
    
    for (int i = 0; i < [coordinateArray count]; i++) {
        CLLocationCoordinate2D c2D;
        NSArray *dataComponent = [coordinateArray[i] componentsSeparatedByString:@","];
        c2D.latitude  = [dataComponent[0] doubleValue];
        c2D.longitude = [dataComponent[1] doubleValue];
        
        Annotation *ann = [[Annotation alloc] init];
        ann.title = @"Cop";
        
        int timeAdded = [dataComponent[2] intValue];
        int secondsSinceAdded = time(NULL) - timeAdded;
        ann.subtitle = formatTimeSince(secondsSinceAdded);
        // Cops! Be cool...
        
        [ann setCoordinate:c2D];
        [self.map addAnnotation:ann];
    }
}


- (void)regularlyUpdateMap
{
    for (int i = 0;;) {
        sleep(5);
        if (!updating) [self requestUpdateAddCop:NO];
        sleep(25);
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.comm = [[SocketCommunicator alloc] initWithIP:IP port:5010 delegate:self];
    
    [self performSelectorInBackground:@selector(regularlyUpdateMap) withObject:NULL];
    
    self.map.showsUserLocation = YES;
    self.map.userTrackingMode = MKUserTrackingModeFollow;
    [self showUserPositionOnMap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CLLocationCoordinate2D)getUserCoordinate
{
    return self.map.userLocation.location.coordinate;
}

- (void)showUserPositionOnMap
{
    [self.map setCenterCoordinate:[self getUserCoordinate] animated:YES];
}

- (IBAction)alertButtonWasClicked:(id)sender
{
    [self requestUpdateAddCop:YES];
}

- (IBAction)updateButtonWasClicked:(id)sender
{
    [self requestUpdateAddCop:NO];
}

@end
