//
//  SocketCommunicator.h
//  Cop Alert
//
//  Created by Alex Reidy on 1/9/14.
//  Copyright (c) 2014 Alex Reidy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StreamDelegate.h"

@interface SocketCommunicator : NSObject // <NSStreamDelegate>

@property (nonatomic) NSInputStream *inputStream;
@property (nonatomic) NSOutputStream *outputStream;

- (SocketCommunicator *)initWithIP:(NSString *)connIP port:(int)connPort delegate:(id<NSStreamDelegate>) streamDelegate;

- (void)writeToServer:(NSString *)message;

@end
