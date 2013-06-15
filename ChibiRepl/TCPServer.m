//
//  TCPServer.m
//  ChibiRepl
//
//  Created by Aaron Clarke on 6/15/13.
//  Copyright (c) 2013 Aaron Clarke. All rights reserved.
//

#import "TCPServer.h"
#import <CFNetwork/CFNetwork.h>
#include <sys/socket.h>
#include <netinet/in.h>
#import "TCPServerDelegate.h"

@interface TCPServer ()
{
    int _port;
    CFSocketRef _server;
}
@end

@implementation TCPServer

- (void)dealloc
{
    CFRelease(_server);
    [super dealloc];
}

static void acceptCallBack(CFSocketRef socket,
                           CFSocketCallBackType type,
                           CFDataRef address,
                           const void *data,
                           void *info)
{
    TCPServer* self = info;
    if ([self.delegate respondsToSelector:@selector(tcpServer:acceptWithSocket:type:address:data:)]) {
        [self.delegate tcpServer:self
                acceptWithSocket:socket
                            type:type
                         address:address
                            data:data];
    }
}

-(void)startWithPort:(int)port
{
    _port = port;
    int yes = 1;
    CFSocketContext CTX = { 0, self, NULL, NULL, NULL };
    
    _server = CFSocketCreate(NULL,
                             PF_INET,
                             SOCK_STREAM,
                             IPPROTO_TCP,
                             kCFSocketAcceptCallBack,
                             (CFSocketCallBack)acceptCallBack,
                             &CTX);
    assert(_server!=NULL);
    setsockopt(CFSocketGetNative(_server),
               SOL_SOCKET,
               SO_REUSEADDR,
               (void *)&yes,
               sizeof(yes));
    
    struct sockaddr_in addr;
    memset(&addr, 0, sizeof(addr));
    addr.sin_len = sizeof(addr);
    addr.sin_family = AF_INET;
    addr.sin_port = htons(_port);
    addr.sin_addr.s_addr = htonl(INADDR_ANY);
    NSData *address = [ NSData dataWithBytes: &addr length: sizeof(addr) ];
    
    if (CFSocketSetAddress(_server, (CFDataRef) address) != kCFSocketSuccess) {
        fprintf(stderr, "CFSocketSetAddress() failed\n");
        CFRelease(_server);
        assert(false);
    }
    CFRunLoopSourceRef sourceRef = CFSocketCreateRunLoopSource(kCFAllocatorDefault,
                                                               _server,
                                                               0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(),
                       sourceRef,
                       kCFRunLoopCommonModes);
    
    CFRelease(sourceRef);
    printf("Socket listening on port %d\n", _port);
}

@end
