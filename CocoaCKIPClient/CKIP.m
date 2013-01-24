//
//  CKIP.m
//  CKIPClient
//
//  Created by Kuan-ming Su on 1/24/13.
//  Copyright (c) 2013 SUStudio. All rights reserved.
//

#import "CKIP.h"

#define kSentenceTag        @"sentence"
#define kProcessStatusTag   @"processstatus"

const static uint16_t CKIP_PORT = 1501;
#define CKIP_HOST           @"140.109.19.104"


@implementation CKIP

@synthesize delegate;
@synthesize username;
@synthesize password;
@synthesize rawText;
@synthesize processStatus;
@synthesize sentences;

- (id)initWithUsername:(NSString *)user password:(NSString *)pass
{
    self = [super init];
    if (self) {
        username = user;
        password = pass;
    }
    return self;
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    // create XML for CKIP
    NSXMLElement *root = [NSXMLNode elementWithName:@"wordsegmentation"];
    [root addAttribute:[NSXMLNode attributeWithName:@"version" stringValue:@"0.1"]];
    NSXMLDocument *xmlDoc = [[NSXMLDocument alloc] initWithRootElement:root];
    [xmlDoc setVersion:@"1.0"];
    
    // CKIP allows Big5 and UTF-16 encoding.  You can choose one of Big5 or UTF-16 to encode.
    // However, the return XML is always "Big5" encoded.
    //[xmlDoc setCharacterEncoding:@"UTF-16"];
    [xmlDoc setCharacterEncoding:@"Big5"];
    
    // option
    NSXMLElement *option = [NSXMLNode elementWithName:@"option"];
    [option addAttribute:[NSXMLNode attributeWithName:@"showcategory" stringValue:@"1"]];
    [root addChild:option];
    
    // authentication
    NSXMLElement *auth = [NSXMLNode elementWithName:@"authentication"];
    [auth addAttribute:[NSXMLNode attributeWithName:@"username" stringValue:username]];
    [auth addAttribute:[NSXMLNode attributeWithName:@"password" stringValue:password]];
    [root addChild:auth];
    
    // text
    NSXMLElement *text = [NSXMLNode elementWithName:@"text"];
    [text setStringValue:rawText];
    [root addChild:text];
    
    // send
    [sock writeData:[xmlDoc XMLData] withTimeout:-1 tag:0];
}


- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
	// prepare to receive data
    [sock readDataWithTimeout:-1 tag:1];
}


- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	// read CKIP returned data
    //
    // CKIP returns only "Big5" encoded XML, but cocoa needs UTF-8.
    // convert Big5 NSData to UTF8 NSString
    NSString *returnText = [[NSString alloc] initWithData:data encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5)];
    
    // parse returned XML
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:[returnText dataUsingEncoding:NSUTF8StringEncoding]];
    [parser setDelegate:self];
    [parser parse];
    
    // callback delegate's ckipDidFinish:
    if ([delegate respondsToSelector:@selector(ckipDidFinish:)]) {
        __strong id theDelegate = delegate;
        @autoreleasepool {
            [theDelegate ckipDidFinish:self];
        }
    }
    
    // disconnect
    [sock disconnect];
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    // dealing with process status code
    // 0: success
    // 1: Server Internal Error
    // 2: XML Format Error
    // 3: Authentication Error
    if ([elementName isEqualToString:kProcessStatusTag]) {
        processStatus = [[attributeDict objectForKey:@"code"] intValue];
        if (processStatus == 0) {
            [self setSentences:[NSMutableArray new]];
        }
        else if ([delegate respondsToSelector:@selector(ckipDidReceiveEroorProcessStatus:)]) {
            __strong id theDelegate = delegate;
            @autoreleasepool {
                [theDelegate ckipDidReceiveErrorProcessStatus:processStatus];
            }
        }
    }
    // sentence tag - mark
    else if ([elementName isEqualToString:kSentenceTag]) {
        addSentence = YES;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (processStatus == 0 && addSentence) {
        // remove full space among number by thousand seperator (eg. 123,455 => 123,　455(DET) )
        string = [string stringByReplacingOccurrencesOfString:@",　" withString:@","];
        // trim head full-size space and
        string = [string stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"　"]];
        [sentences addObject:string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    // sentence tag - unmark
    if ([elementName isEqualToString:kSentenceTag]) {
        addSentence = NO;
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock
                  withError:(NSError *)err
{
    // release socket
    asyncSocket = nil;
}

- (NSArray *)terms
{
    NSMutableArray *terms = [NSMutableArray new];
    for (NSString *s in sentences) {
        NSArray *termsWithSentence = [self termsWithSentence:s];
        if (termsWithSentence != nil) {
            [terms addObjectsFromArray:termsWithSentence];
        }
    }
    if (terms.count)
        return terms;
    return nil;
}

- (NSArray *)termsWithSentence:(NSString *)sentence
{
    NSMutableArray *terms = [NSMutableArray new];
    for (NSString *term in [sentence componentsSeparatedByString:@"　"]) {
        if ([term isEqualToString:@""]) continue;
        
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(\\S+)\\((\\S+)\\)" options:NSRegularExpressionCaseInsensitive error:nil];
        NSString *tStr = [regex stringByReplacingMatchesInString:term options:0 range:NSMakeRange(0, [term length]) withTemplate:@"$1_$2"];
        
        NSArray *tArr = [tStr componentsSeparatedByString:@"_"];
        NSDictionary *t = [NSDictionary dictionaryWithObjectsAndKeys:[tArr objectAtIndex:0], @"term", [tArr objectAtIndex:1], @"tag", nil];
        [terms addObject:t];
        tArr = nil;
        tStr = nil;
    }
    if (terms.count)
        return terms;
    return nil;
}

-(void)performCKIP
{
    NSError *error = nil;
    asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    if (![asyncSocket connectToHost:CKIP_HOST onPort:CKIP_PORT error:&error]) {
        NSLog(@"Unable to connect to due to invalid configuration: %@", error);
        return;
    }
    
    // After 10 seconds, stop
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 10), dispatch_get_current_queue(), ^{
        if (asyncSocket) {
            [asyncSocket disconnect];
            asyncSocket = nil;
        }
    });
}

@end
