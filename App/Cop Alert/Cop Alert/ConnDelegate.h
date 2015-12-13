//
//  ConnDelegate.h
//  Cop Alert
//
//  Created by Alex Reidy on 12/18/13.
//  Copyright (c) 2013 Alex Reidy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConnDelegate : NSObject <NSURLConnectionDelegate>

@property (nonatomic) NSMutableData *dataCollection;

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;

- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

@end
