//
//  SocketCommunicator.m
//  Cop Alert
//
//  Created by Alex Reidy on 1/9/14.
//  Copyright (c) 2014 Alex Reidy. All rights reserved.
//

#import "SocketCommunicator.h"

@implementation SocketCommunicator

- (SocketCommunicator *)initWithIP:(NSString *)connIP port:(int)connPort delegate:(id<NSStreamDelegate>) streamDelegate;
{
    self = [super init];
    
    CFReadStreamRef readStream = NULL; CFWriteStreamRef writeStream = NULL;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)connIP, connPort, &readStream, &writeStream);
    
    self.inputStream = (__bridge NSInputStream *) readStream;
    [self.inputStream setDelegate:streamDelegate];
    self.outputStream = (__bridge NSOutputStream *) writeStream;
    [self.outputStream setDelegate:streamDelegate];
    
    [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.inputStream open]; [self.outputStream open];
    
    return self;
}

- (void)writeToServer:(NSString *)message
{
    message = [message stringByAppendingString:@"\n"];
    NSData *data = [[NSData alloc] initWithData:[message dataUsingEncoding:NSASCIIStringEncoding]];
    [self.outputStream write:[data bytes] maxLength:[data length]];
}

@end
