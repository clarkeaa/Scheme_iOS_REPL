//
//  SingleSexpServer.m
//  ChibiRepl
//
//  Created by Aaron Clarke on 6/15/13.
//  Copyright (c) 2013 Aaron Clarke. All rights reserved.
//

#import "SingleSexpServer.h"
#import "TCPServer.h"
#import "TCPServerDelegate.h"
#import "SingleSexpServerDelegate.h"

@interface SingleSexpServer () <TCPServerDelegate>
{
    CFSocketNativeHandle _sock;
    CFReadStreamRef _readStream;
    CFWriteStreamRef _writeStream;
    dispatch_queue_t _queue;
}
@property (nonatomic, retain) TCPServer* server;
@end

@implementation SingleSexpServer

- (id)init
{
    self = [super init];
    if (self) {
        self.server = [[[TCPServer alloc] init] autorelease];
        self.server.delegate = self;
        _queue = dispatch_queue_create("singlesexpserver", NULL);
    }
    return self;
}

- (void)dealloc
{
    [_server release];
    dispatch_release(_queue);
    [super dealloc];
}

-(void)startWithPort:(int)port
{
    [self.server startWithPort:port];
}

-(void)waitForInput
{
    CFIndex bytes;
    UInt8 buffer[128];
    __block BOOL keepRunning = YES;
    while(keepRunning) {
        UInt8 recv_len = 0;
        memset(buffer, 0, sizeof(buffer));
        while (!strchr((char *) buffer, '\n') && recv_len < sizeof(buffer)) {
            bytes = CFReadStreamRead(_readStream, buffer + recv_len, sizeof(buffer) - recv_len);
            if (bytes < 0) {
                fprintf(stderr, "CFReadStreamRead() failed: %lu\n", bytes);
                close(_sock);
                return;
            }
            recv_len += bytes;
        }
        
        NSString* input = [NSString stringWithUTF8String:(const char*)buffer];
        dispatch_sync(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(singleSexpServer:didReceiveSexp:)]) {
                keepRunning = [self.delegate singleSexpServer:self didReceiveSexp:input];
            }
        });
    }
}

-(void)tcpServer:(TCPServer *)server
acceptWithSocket:(CFSocketRef)socket
            type:(CFSocketCallBackType)type
         address:(CFDataRef)address
            data:(const void *)data
{
    NSLog(@"%s", __func__);    
    /* The native socket, used for various operations */
    if (_sock != 0) {
        [self disconnect];
    }
    _sock = *(CFSocketNativeHandle *) data;
    
    /* Create the read and write streams for the socket */
    CFStreamCreatePairWithSocket(kCFAllocatorDefault, _sock, &_readStream, &_writeStream);
    if (!_readStream || !_writeStream) {
        close(_sock);
        fprintf(stderr, "CFStreamCreatePairWithSocket() failed\n"); return;
    }
    CFReadStreamOpen(_readStream);
    CFWriteStreamOpen(_writeStream);
    
    if ([self.delegate respondsToSelector:@selector(singleSexpServerNewConnection:)]) {
        [self.delegate singleSexpServerNewConnection:self];
    }
    
    dispatch_async(_queue, ^{
        [self waitForInput];
    });
}

-(void)sendStream:(FILE*)stream terminator:(int)terminator
{
    int outChar;
    if (CFWriteStreamCanAcceptBytes(_writeStream)) {
        while ( (outChar = fgetc(stream)) != terminator) {
            CFWriteStreamWrite(_writeStream, (const UInt8*)&outChar, 1);
        }
    }
}

-(void)disconnect
{
    close(_sock);
    _sock = 0;
    CFReadStreamClose(_readStream);
    _readStream = NULL;
    CFWriteStreamClose(_writeStream);
    _writeStream = NULL;
}

@end
