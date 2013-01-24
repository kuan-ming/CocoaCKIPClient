//
//  AppDelegate.h
//  CKIPClient
//
//  Created by Kuan-ming Su on 1/24/13.
//  Copyright (c) 2013 SUStudio. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CKIP.h"

@interface AppDelegate : NSObject <CKIPDelegate>
{
    CKIP *ckip;
}

@property NSString *username;
@property NSString *password;
@property NSString *rawText;
@property NSInteger processStatus;
@property NSMutableArray *sentence;
@property (readonly) NSMutableArray *term;
@property BOOL outputTerms;

@property (assign) IBOutlet NSWindow *window;
@property (unsafe_unretained) IBOutlet NSTextView *textView;
@property (unsafe_unretained) IBOutlet NSTextView *tokenizedTextView;
@property (weak) IBOutlet NSTextField *usernameField;
@property (weak) IBOutlet NSSecureTextField *passwordField;

- (IBAction)setOutputType:(id)sender;
- (IBAction)performCKIP:(id)sender;
- (IBAction)visitSUStudio:(id)sender;


@end
