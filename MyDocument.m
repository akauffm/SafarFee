//
//  MyDocument.m
//  SafarFee
//
//  Created by AK on 4/12/08.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MyDocument.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@implementation MyDocument

- (IBAction)connectURL:(id)sender{
	NSString *theURL = [sender stringValue];
	if (![theURL hasPrefix:@"http://"]) theURL = [@"http://" stringByAppendingString:theURL];
    [[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:theURL]]];
}

- (IBAction)reload:(id)sender{
	[webView reload:sender];
}

- (IBAction)stopLoading:(id)sender{
	[webView stopLoading:sender];
}

- (void)setSomeDelegate:(id)someDelegate
{
	somedelegate = someDelegate;
}

- (id)somedelegate
{
	return somedelegate;
}

-(BOOL)isDocumentEdited{
	return NO;
}

- (WebView *)webView:(WebView *)sender createWebViewWithRequest:(NSURLRequest *)request
{
	id myDocument = [[NSDocumentController sharedDocumentController] openUntitledDocumentOfType:@"DocumentType" display:YES];
    return [myDocument webView];
}

- (id)init
{
    self = [super init];
    if (self) {
		// A notification, see below as well
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewFinishedLoading:) name:WebViewProgressFinishedNotification object:nil];
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
		[NSTimer scheduledTimerWithTimeInterval:0.1
										 target: self
									   selector:@selector(checkForLoading)
									   userInfo:nil
										repeats:YES];
		
    }
    return self;
}

- (WebView*) webView
{
	return webView;
}

- (void) setUrl:(NSString*)url
{
	[textField setStringValue:url];
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
	
	//Sets a delegate so I can open popups
	[webView setUIDelegate:self];
	[webView setResourceLoadDelegate:self];
	[webView setFrameLoadDelegate:self];
	[webView setGroupName:@"MyDocument"];
	[webView setPolicyDelegate:self];
	[self setSomeDelegate: self];
	
	[webView setMainFrameURL:@"http://localhost/thesis_login.php"];
	
	//if(somedelegate != nil && [somedelegate respondsToSelector:@selector(makeInvisible)])
	//	{
	//		[somedelegate performSelector:@selector(makeInvisible)];
	//	}
	//Loads default window
	//NSString *urlText = [NSString stringWithString:@"http://www.nytimes.com"];
	//	[[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlText]]];
	
	count = -1;
	
	
	
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If the given outError != NULL, ensure that you set *outError when returning nil.
	
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
	
    // For applications targeted for Panther or earlier systems, you should use the deprecated API -dataRepresentationOfType:. In this case you can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.
	
    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type.  If the given outError != NULL, ensure that you set *outError when returning NO.
	
    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead. 
    
    // For applications targeted for Panther or earlier systems, you should use the deprecated API -loadDataRepresentation:ofType. In this case you can also choose to override -readFromFile:ofType: or -loadFileWrapperRepresentation:ofType: instead.
    
    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
    return YES;
}

//THE REAL MEAT

- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation
        request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id)listener {
	
	NSString *theHost = [[request URL] absoluteString];
	NSString *domain = [[request URL] host];
	
	if (count == 0) {
		
		if (loggedin != 1) {
			ASIHTTPRequest *checkRequest = [[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString: @"http://localhost/thesis_pre.php"]] autorelease];
			[checkRequest setDelegate:self];
			[checkRequest startSynchronous];
			//this needs fixing: put error in status bar not in browser bar
			if ([checkRequest error]) {
				[textField setStringValue:[[checkRequest error] localizedDescription]];
			} 
			if ([[checkRequest responseString] intValue] == 1) {
				loggedin = 1;
				NSLog(@"Ok we logged in");
			}
		}
		
		ASIHTTPRequest *therequest = [[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://localhost/thesis_check.php?host=%@&url=%@",domain,theHost]]] autorelease];
		
		[therequest setDelegate:self];
		[therequest startSynchronous];
		
		//this needs fixing: put error in status bar not in browser bar
		if ([therequest error]) {
			[textField setStringValue:[[therequest error] localizedDescription]];
		} else if ([therequest responseString]) {
			NSLog(@"Successfully checked for site ownership");
			NSLog(@"%@",[NSString stringWithFormat:@"http://localhost/thesis_check.php?host=%@&url=%@",domain,theHost]);
		}
		
		
		[stopButton setTransparent: NO];
		[stopButton setEnabled: YES];
		[reloadButton setTransparent: YES];
		[reloadButton setEnabled: NO];
		//		[reloadButton setImage:[NSImage imageNamed:@"NSStopProgressTemplate"]];
		
		count++;
	}
	
	
	if ([theHost hasSuffix:@"thesis_home.php"] || [theHost hasSuffix:@"thesis_login.php"] || [theHost hasSuffix:@"thesis_register.php"]) {
		if(somedelegate != nil && [somedelegate respondsToSelector:@selector(makeInvisible)])
		{
			[somedelegate performSelector:@selector(makeInvisible)];
		}
		
	}
	
	else {
		if (somedelegate != nil && [somedelegate respondsToSelector:@selector(makeVisible)])
		{
			[somedelegate performSelector:@selector(makeVisible)];
		}
	}
	
	
	
	//NSString *hello;
	//	NSScanner *theScanner = [NSScanner scannerWithString:theHost];
	//	//NSLog(@"%@", theHost);
	//	
	//	if ([theScanner scanString:@"ipod" intoString:&hello] && count == 1){
	//		[listener ignore];
	//		[[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.zune.com"]]];
	//	}
	//	
	//	NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES 'apple\\.com'"];
	//	BOOL myStringMatchesRegEx = [regExPredicate evaluateWithObject:theHost];
	//	//NSLog(@"Number 1 is: %d and count is: %d", myStringMatchesRegEx, count);
	//	
	//	//NSPredicate *regExPredicate1 = [NSPredicate predicateWithFormat:@"SELF MATCHES 'ipod'"];
	//	//BOOL myStringMatchesRegEx1 = [regExPredicate1 evaluateWithObject:theHost];
	//	//NSLog(@"Number 2 is: %d and count is: %d", myStringMatchesRegEx1, count);
	//	
	//	NSPredicate *regExPredicate2 = [NSPredicate predicateWithFormat:@"SELF MATCHES '.*ipad.*'"];
	//	BOOL myStringMatchesRegEx2 = [regExPredicate2 evaluateWithObject:theHost];
	//	//NSLog(@"Number 3 is: %d and count is: %d", myStringMatchesRegEx2, count);
	//	
	//	if (myStringMatchesRegEx && count == 1) {		
	//		[listener ignore];
	//		[[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.microsoft.com"]]];
	//	}
	//	
	//	//else if (myStringMatchesRegEx1 && count == 1) {
	//	//		[listener ignore];
	//	//		[[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.zune.com"]]];
	//	//	}
	//	
	//	else if (myStringMatchesRegEx2 && count == 1) {
	//		[listener ignore];
	//		[[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://en.wikipedia.org/wiki/Failure"]]];
	//	}
	
	[listener use];
	count++;
}


//For popups

- (void)webViewShow:(WebView *)sender
{
    id myDocument = [[NSDocumentController sharedDocumentController] documentForWindow:[sender window]];
    [myDocument showWindows];
}

//For Buttons

- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame
{
	
	NSLog(@"webView:didStartProvisionalLoadForFrame:");
    // Only report feedback for the main frame.
    if (frame == [sender mainFrame]){
        NSString *url = [[[[frame provisionalDataSource] request] URL] absoluteString];
        [textField setStringValue:url];
    }
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{		
	NSLog(@"webView:didFinishLoadForFrame");
    // Only report feedback for the main frame.
    if (frame == [sender mainFrame]){
		[backButton setEnabled:[sender canGoBack]];
		[forwardButton setEnabled:[sender canGoForward]];
    }
}

//A notification, should I need an example (see above too)
-(void)viewFinishedLoading:(NSNotification *)aNotification {
}

//Displays Page Title
- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame
{
    // Report feedback only for the main frame.
    if (frame == [sender mainFrame]){
        [[sender window] setTitle:title];
    }
}

- (void)checkForLoading {
	if (![webView isLoading]) {
		[progress stopAnimation:nil];
		[stopButton setTransparent: YES];
		[stopButton setEnabled: NO];
		[reloadButton setTransparent: NO];
		[reloadButton setEnabled: YES];
		//[reloadButton setImage:[NSImage imageNamed:@"NSRefreshTemplate"]];
		count = 0;
	}
	else
		[progress setDoubleValue:[webView estimatedProgress]];
}

- (BOOL)webView:(WebView *)sender shouldPerformAction:(SEL)action fromSender:(id)fromObject
{
	return YES;
}

- (void)makeVisible
{
	[textField setEnabled:YES];
	[textField setHidden:NO];
	[stopButton setHidden: YES];
	[stopButton setEnabled: NO];
	[reloadButton setHidden: NO];
	[reloadButton setEnabled: YES];	
	[backButton setHidden:NO];
	[forwardButton setHidden:NO];
}

- (void)makeInvisible
{
	[textField setEnabled:NO];
	[textField setHidden:YES];
	[stopButton setHidden: YES];
	[stopButton setEnabled: NO];
	[reloadButton setHidden: YES];
	[reloadButton setEnabled: NO];	
	[backButton setHidden:YES];
	[forwardButton setHidden:YES];
}

@end
