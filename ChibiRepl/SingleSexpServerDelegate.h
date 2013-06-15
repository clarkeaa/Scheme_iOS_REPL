//
//  SingleSexpServerDelegate.h
//  ChibiRepl
//
//  Created by Aaron Clarke on 6/15/13.
//  Copyright (c) 2013 Aaron Clarke. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SingleSexpServer;

@protocol SingleSexpServerDelegate <NSObject>
-(void)singleSexpServerNewConnection:(SingleSexpServer*)server;
-(BOOL)singleSexpServer:(SingleSexpServer*)server
         didReceiveSexp:(NSString*)nsSexp;
@end
