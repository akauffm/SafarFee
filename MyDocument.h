//
//  MyDocument.h
//  SafarFee
//
//  Created by AK on 4/12/08.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@class ASIHTTPRequest;

@interface MyDocument : NSDocument
{
	IBOutlet NSView  *view;
	IBOutlet WebView *webView;
	IBOutlet NSTextField *textField;
	IBOutlet NSTextField *statusBar;
	IBOutlet NSButton *backButton;
	IBOutlet NSButton *forwardButton;
	IBOutlet NSProgressIndicator *progress;
	IBOutlet NSButton *reloadButton;
	IBOutlet NSButton *stopButton;
	
	id somedelegate;
	int count;
	int loggedin;
	NSTimer *timer;
}

- (IBAction)connectURL:(id)sender;
- (IBAction)reload:(id)sender;
- (IBAction)stopLoading:(id)sender;
- (void)setSomeDelegate:(id)someDelegate;
- (id)somedelegate;
- (void)makeVisible;
- (void)makeInvisible;

@end
