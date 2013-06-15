//
//  TCPServerDelegate.h
//  ChibiRepl
//
//  Created by Aaron Clarke on 6/15/13.
//  Copyright (c) 2013 Aaron Clarke. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TCPServer;

@protocol TCPServerDelegate <NSObject>
-(void)tcpServer:(TCPServer*)server
acceptWithSocket:(CFSocketRef)socket
            type:(CFSocketCallBackType) type
         address:(CFDataRef) address
            data:(const void *)data;
@end
