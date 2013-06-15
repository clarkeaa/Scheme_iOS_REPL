//
//  TCPServer.h
//  ChibiRepl
//
//  Created by Aaron Clarke on 6/15/13.
//  Copyright (c) 2013 Aaron Clarke. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TCPServerDelegate;

@interface TCPServer : NSObject
@property (nonatomic, assign) id<TCPServerDelegate> delegate;
-(void)startWithPort:(int)port;
@end
