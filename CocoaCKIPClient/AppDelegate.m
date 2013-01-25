//
//  AppDelegate.m
//  CKIPClient
//
//  Created by Kuan-ming Su on 1/24/13.
//  Copyright (c) 2013 SUStudio. All rights reserved.
//

#import "AppDelegate.h"
#import "CKIP.h"

@implementation AppDelegate

@synthesize username;
@synthesize password;
@synthesize rawText;
@synthesize processStatus;
@synthesize sentence;
@synthesize textView;
@synthesize tokenizedTextView;
@synthesize usernameField;
@synthesize passwordField;
@synthesize outputTerms;
@synthesize sheetWindow;
@synthesize sheetSpinner;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    rawText = @"「呼愁」貫穿奧罕．帕慕克的《伊斯坦堡》。這是一本回憶錄，是種羅蘭．巴特式的鏡像自述；是現實，也是虛構；是追憶過去，亦是瞻望未來。奧罕．帕慕克用過往，拼貼出現在，架構出未來。他像是在和自己說話，又似乎在向人述說故事。有時後，他成了歐洲來的西方人；有時候，又像個根深蒂固地頑固土耳其佬。他的《伊斯坦堡》不斷迴盪在東西之間，穿梭於新舊當中，掙扎於保守激進兩頭。如同《伊斯坦堡》的位置，不東不西，不新不舊。";
    [textView setString:rawText];
}

- (void)displayCKIPOutput
{
    if (outputTerms) {
        // displayer term
        NSMutableArray *terms = [NSMutableArray new];
        for (NSDictionary *t in [ckip terms]) {
            [terms addObject:[NSString stringWithFormat:@"%@\t%@", [t objectForKey:@"term"], [t objectForKey:@"tag"]]];
        }
        [tokenizedTextView setString:[terms componentsJoinedByString:@"\n"]];
    }
    else {
        // display sentence
        [tokenizedTextView setString:[[ckip sentences] componentsJoinedByString:@"\n"]];
    }
}

- (IBAction)setOutputType:(id)sender {
    outputTerms = [[sender selectedItem] tag];
    if (ckip) {
        [self displayCKIPOutput];
    }
}

- (IBAction)performCKIP:(id)sender {
    [sheetSpinner startAnimation:self];
    [[NSApplication sharedApplication] beginSheet:[self sheetWindow] modalForWindow:[self window] modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
    
    ckip = [[CKIP alloc] initWithUsername:[usernameField stringValue]
                                 password:[passwordField stringValue]];
    [ckip setDelegate:self];
    [ckip setRawText:[textView string]];
    [ckip performCKIP];
}

- (IBAction)visitSUStudio:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.sustudio.org"]];
}


#pragma mark - CKIPDelegate method

- (void)ckip:(CKIP *)ckip didConnectToHost:(NSString *)host port:(uint16_t)port
{
    [[self sheetWindow] orderOut:self];
    [[NSApplication sharedApplication] endSheet:[self sheetWindow]];
    [sheetSpinner stopAnimation:self];
}

- (void)ckipDidFinish:(id)theCKIP
{
    if ([[theCKIP sentences] count])
        [self displayCKIPOutput];
}

- (void)ckip:(CKIP *)ckip didReceiveProcessStatus:(NSString *)status code:(NSInteger)code
{
    // code = 0: success
    if (code == 0) return;
    
    // code = 1: Service internal error
    // code = 2: XML format error
    // code = 3: Authentication error
    NSAlert *alert = [NSAlert alertWithMessageText:status
                                     defaultButton:@"OK"
                                   alternateButton:nil
                                       otherButton:nil
                         informativeTextWithFormat:@"code %ld", code];
    [alert beginSheetModalForWindow:[self window]
                      modalDelegate:nil
                     didEndSelector:NULL
                        contextInfo:NULL];
}

- (void)ckipDidFailToEstablishConnection:(CKIP *)ckip
{
    NSAlert *alert = [NSAlert alertWithMessageText:@"Connection Fail"
                                     defaultButton:@"OK"
                                   alternateButton:nil
                                       otherButton:nil
                         informativeTextWithFormat:@"Cannot establish connection.\nCKIP server may be down.\nTry again later."];
    [alert beginSheetModalForWindow:[self window]
                      modalDelegate:nil
                     didEndSelector:NULL
                        contextInfo:NULL];
}


@end
