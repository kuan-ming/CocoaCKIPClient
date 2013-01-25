//
//  CKIP.h
//  CKIPClient
//
//  Created by Kuan-ming Su on 1/24/13.
//  Copyright (c) 2013 SUStudio. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GCDAsyncSocket.h"

@interface CKIP : NSObject <GCDAsyncSocketDelegate, NSXMLParserDelegate>
{
    GCDAsyncSocket *asyncSocket;
    __weak id delegate;
    
    BOOL addSentence;
}

@property (weak) id delegate;
@property NSString *username;
@property NSString *password;
@property NSString *rawText;
@property NSInteger processStatus;
@property NSMutableArray *sentences;
@property (readonly) NSArray *terms;

- (id)initWithDelegate:(id)delegate username:(NSString *)username password:(NSString *)password;
- (void)performCKIP;
- (NSArray *)termsWithSentence:(NSString *)sentence;

@end


#pragma mark -

@protocol CKIPDelegate
@optional
- (void)ckip:(CKIP *)ckip didConnectToHost:(NSString *)host port:(uint16_t)port;
- (void)ckipDidFinish:(CKIP *)ckip;
- (void)ckip:(CKIP *)ckip didReceiveProcessStatus:(NSString *)status code:(NSInteger)code;
- (void)ckipDidFailToEstablishConnection:(CKIP *)ckip;

@end
