//
//  ViewController.m
//  ChibiRepl
//
//  Created by Aaron Clarke on 6/15/13.
//  Copyright (c) 2013 Aaron Clarke. All rights reserved.
//

#import "ViewController.h"
#import <chibi/eval.h>
#import "SingleSexpServer.h"
#import "SingleSexpServerDelegate.h"

#define PORT 2048

@interface ViewController () <SingleSexpServerDelegate>
{
    sexp _ctx;
    int _fd[2];
    FILE* _inpipe;
    FILE* _outpipe;
}
@property (nonatomic, retain) SingleSexpServer* server;
@end

@implementation ViewController

-(void)dealloc
{
    sexp_destroy_context(_ctx);
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (pipe(_fd)) {
        assert(false);
    }
    _inpipe = fdopen(_fd[0], "r");
    if (!_inpipe) {
        assert(false);
    }
    _outpipe = fdopen(_fd[1], "w");
    if (!_outpipe) {
        assert(false);
    }
    
    _ctx = sexp_make_eval_context(NULL, NULL, NULL, 0, 0);
    sexp_load_standard_env(_ctx, NULL, SEXP_SEVEN);
    sexp_load_standard_ports(_ctx, NULL, stdin, _outpipe, _outpipe, 1);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)singleSexpServerNewConnection:(SingleSexpServer *)server
{
    NSLog(@"new connection");
}

-(BOOL)singleSexpServer:(SingleSexpServer *)server didReceiveSexp:(NSString *)nsSexp
{
    BOOL keepRunning = YES;
    sexp out = sexp_eval_string(self->_ctx, "(current-output-port)", -1, NULL);
    sexp inexp = sexp_read_from_string(self->_ctx, nsSexp.UTF8String, nsSexp.length);

    if (inexp == SEXP_EOF) {
        keepRunning = NO;
    } else if (sexp_exceptionp(inexp)) {
        sexp_print_exception(self->_ctx, inexp, out);
    } else {
        NSLog(@"%@",nsSexp);
        
        sexp result = sexp_eval_string(self->_ctx, nsSexp.UTF8String, -1, NULL);
        fputc('\0', self->_outpipe);
        fflush(self->_outpipe);
        
        int outChar;
        while ( (outChar = fgetc(self->_inpipe)) != '\0') {
            fputc(outChar, stdout);
        }
        fputc('\n', stdout);
        
        if (sexp_exceptionp(result)) {
            sexp_print_exception(self->_ctx, result, out);
            sexp_stack_trace(self->_ctx, out);
        } else {
            sexp_write(self->_ctx, result, out);
            fputc('\n', self->_outpipe);
        }
    }

    fputc('\0', self->_outpipe);
    fflush(self->_outpipe);
    
    [server sendStream:self->_inpipe terminator:'\0'];
    
    return keepRunning;
}

-(void)viewDidAppear:(BOOL)animated
{
    self.server = [[[SingleSexpServer alloc] init] autorelease];
    self.server.delegate = self;
    [self.server startWithPort:PORT];
}

@end
