//
//  SingleSexpServer.h
//  ChibiRepl
//
//  Created by Aaron Clarke on 6/15/13.
//  Copyright (c) 2013 Aaron Clarke. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SingleSexpServerDelegate;

@interface SingleSexpServer : NSObject
@property (nonatomic, assign) id<SingleSexpServerDelegate> delegate;
-(void)startWithPort:(int)port;
-(void)sendStream:(FILE*)stream terminator:(int)terminator;
-(void)disconnect;
@end
