//
//  XLWebViewController.m
//  NovelReader
//
//  Created by Pang Zhenyu on 14-8-31.
//  Copyright (c) 2014年 citydeer. All rights reserved.
//

#import "XLWebViewController.h"
#import "KYTipsView.h"



@interface XLWebViewController () <UIWebViewDelegate>
{
	BOOL _loaded;
}

-(BOOL) clientURLDetected:(NSDictionary*)params;

@end



@implementation XLWebViewController

-(id) init
{
	self = [super init];
	if (self)
	{
	}
	return self;
}

-(void) dealloc
{
	_webview.delegate = nil;
}

-(void) loadView
{
	[super loadView];
	
	self.titleLabel.text = _pageTitle;
	[self.leftButton setImage:CDImage(@"main/navi_back") forState:UIControlStateNormal];
	self.leftButton.imageEdgeInsets = UIEdgeInsetsMake(0, -15.0f, 0, 0);
	
	CGRect rect = self.view.bounds;
	
	_webview = [[UIWebView alloc] initWithFrame:CGRectMake(0, _naviBarHeight, rect.size.width, rect.size.height-_naviBarHeight)];
	_webview.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	_webview.delegate = self;
	_webview.scalesPageToFit = NO;
	_webview.suppressesIncrementalRendering = NO;
	_webview.backgroundColor = [UIColor whiteColor];
	_webview.scrollView.backgroundColor = [UIColor whiteColor];
	_webview.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
	[self.view addSubview:_webview];
}

-(void) willPresentView:(NSTimeInterval)duration
{
	[super willPresentView:duration];
	if (!_loaded)
	{
		_loaded = YES;
		[self reloadPage];
	}
}

-(void) reloadPage
{
	if (_request != nil)
	{
		[_webview loadRequest:_request];
	}
	else
	{
		NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:_pageURL]];
		[_webview loadRequest:request];
	}
}

-(BOOL) clientURLDetected:(NSDictionary*)params
{
	return NO;
}

-(BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	NSArray* query = [request.URL.query componentsSeparatedByString:@"&"];
	NSMutableDictionary* params = [NSMutableDictionary dictionary];
	for (NSString* str in query)
	{
		NSArray* kv = [str componentsSeparatedByString:@"="];
		if (kv.count == 2)
		{
			[params setObject:[kv[1] stringByRemovingPercentEncoding] forKey:[kv[0] stringByRemovingPercentEncoding]];
		}
	}
	if ([[params objectForKey:@"appClient"] isEqualToString:@"1"])
	{
		return [self clientURLDetected:params];
	}
	
	return YES;
}

-(void) webViewDidStartLoad:(UIWebView *)webView
{
	[self.view showColorIndicatorFreezeUI:NO];
}

-(void) webViewDidFinishLoad:(UIWebView *)webView
{
	[self.view dismiss];
}

-(void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[self.view dismiss];
}

@end

