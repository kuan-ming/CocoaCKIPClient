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

- (id)initWithUsername:(NSString *)username password:(NSString *)password;
- (void)performCKIP;
- (NSArray *)termsWithSentence:(NSString *)sentence;

@end


#pragma mark -

@protocol CKIPDelegate
@optional
- (void)ckipDidFinish:(CKIP *)ckip;
- (void)ckipDidReceiveErrorProcessStatus:(NSInteger)code;
- (void)ckipCannotEstablishConnection:(CKIP *)ckip;

@end
