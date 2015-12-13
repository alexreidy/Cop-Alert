//
//  Annotation.m
//  Cop Alert
//
//  Created by Alex Reidy on 12/30/13.
//  Copyright (c) 2013 Alex Reidy. All rights reserved.
//

#import "Annotation.h"

@implementation Annotation

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    _coordinate = newCoordinate;
}

- (void)initWithCoordinate:(CLLocationCoordinate2D)position
{
    [self init];
    _coordinate = position;
}

@end
