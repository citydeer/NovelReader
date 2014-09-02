//
//  XLWebViewController.m
//  NovelReader
//
//  Created by Pang Zhenyu on 14-8-31.
//  Copyright (c) 2014年 citydeer. All rights reserved.
//

#import "XLWebViewController.h"
#import "KYTipsView.h"
#import "Encodings.h"
#import "SelectorView.h"
#import "UIHelper.h"



@interface XLWebViewController () <UIWebViewDelegate, SelectViewDelegate>
{
	BOOL _loaded;
	BOOL _shouldReload;
	
	NSInteger _sortType;
	NSArray* _sortTypeNames;
}

-(void) updateSortButton;

@end



@implementation XLWebViewController

-(id) init
{
	self = [super init];
	if (self)
	{
		_sortTypeNames = @[@"按热度", @"按更新", @"按评分"];
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
	NSURL* url = [NSURL URLWithString:_pageURL];
	NSString* appclient = [url queryDictionary][@"appclient"];
	if ([appclient isEqualToString:@"2"])
	{
		[self updateSortButton];
		url = [NSURL URLWithString:[NSString stringWithFormat:@"%@&sort=%d", _pageURL, _sortType]];
	}
	else if ([appclient isEqualToString:@"3"])
	{
		url = [NSURL URLWithString:[NSString stringWithFormat:@"%@&fav=0&down=0", _pageURL]];
	}
	
	_shouldReload = YES;
	NSURLRequest* request = [NSURLRequest requestWithURL:url];
	[_webview loadRequest:request];
}

-(void) updateSortButton
{
	[UIHelper setView:self.rightButton toWidth:100];
	[UIHelper moveView:self.rightButton toX:self.view.bounds.size.width-100];
	[self.rightButton setImage:CDImage(@"store/menu_arrow") forState:UIControlStateNormal];
	self.rightButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
	[self.rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[self.rightButton setTitle:_sortTypeNames[_sortType] forState:UIControlStateNormal];
	
	CGFloat iw = self.rightButton.imageView.frame.size.width;
	CGFloat bw = self.rightButton.frame.size.width;
	self.rightButton.titleEdgeInsets = UIEdgeInsetsMake(0, -10, 0, iw);
	self.rightButton.imageEdgeInsets = UIEdgeInsetsMake(0, bw-iw-10, 0, 0);
}

-(void) rightButtonAction:(id)sender
{
	SelectorView* sv = [[SelectorView alloc] initWithFrame:CGRectMake(320-93-4, _naviBarHeight-13, 93, 150)];
	sv.delegate = self;
	sv.items = _sortTypeNames;
	[UIHelper setView:sv toHeight:sv.totalHeight];
	[sv showInView:self.view];
}

-(void) didSelect:(SelectorView *)selectorView index:(NSUInteger)index
{
	[selectorView dismiss];
	_sortType = index;
	[self reloadPage];
}

-(BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	NSLog(@"%@", request.URL.absoluteString);
	
	if (_shouldReload)
	{
		_shouldReload = NO;
		return YES;
	}
	
	NSString* scheme = request.URL.scheme;
	if ([scheme isEqualToString:@"xlreader"])
	{
		NSString* path = request.URL.path;
		NSDictionary* params = [request.URL queryDictionary];
		if ([path isEqualToString:@"showreader"])
		{
			[self.view showPopMsg:[NSString stringWithFormat:@"阅读, bookid=%@, dirid=%@", params[@"bookid"], params[@"dirid"]] timeout:5];
		}
		else if ([path isEqualToString:@"addfav"])
		{
			[self.view showPopMsg:[NSString stringWithFormat:@"收藏, bookid=%@", params[@"bookid"]] timeout:5];
		}
		else if ([path isEqualToString:@"download"])
		{
			[self.view showPopMsg:[NSString stringWithFormat:@"下载, bookid=%@", params[@"bookid"]] timeout:5];
		}
		return NO;
	}
	
	NSDictionary* params = [request.URL queryDictionary];
	if (params[@"appclient"] != nil)
	{
		XLWebViewController* vc = [[XLWebViewController alloc] init];
		vc.pageURL = request.URL.absoluteString;
		vc.pageTitle = params[@"title"];
		[self.cdNavigationController pushViewController:vc];
		return NO;
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

