//
//  ConnDelegate.m
//  Cop Alert
//
//  Created by Alex Reidy on 12/18/13.
//  Copyright (c) 2013 Alex Reidy. All rights reserved.
//

#import "ConnDelegate.h"

@implementation ConnDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"Got data!\n");
    [self.dataCollection appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"DONE LOADING!\n");
    NSString *coordinates = [[NSString alloc] initWithData:self.dataCollection encoding:NSASCIIStringEncoding];
}

@end
