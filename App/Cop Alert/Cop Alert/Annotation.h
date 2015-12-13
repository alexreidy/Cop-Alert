//
//  Annotation.h
//  Cop Alert
//
//  Created by Alex Reidy on 12/30/13.
//  Copyright (c) 2013 Alex Reidy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Annotation : NSObject <MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy) NSString *title, *subtitle;

- (void)initWithCoordinate:(CLLocationCoordinate2D)position;

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

@end