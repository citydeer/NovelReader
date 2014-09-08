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
#import "PKMappingObject.h"
#import "Encodings.h"
#import "Properties.h"
#import <AdSupport/AdSupport.h>



@interface SortTypeModel : PKMappingObject
@property (readonly) NSInteger sortid;
@property (readonly) NSString* sortname;
@end

@implementation SortTypeModel
@dynamic sortid, sortname;
@end



@interface XLWebViewController () <UIWebViewDelegate, SelectViewDelegate>
{
	BOOL _loaded;
	BOOL _shouldReload;
	
	NSInteger _sortIndex;
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
	_webview.backgroundColor = CDColor(nil, @"e7e7e7");
	_webview.scrollView.backgroundColor = CDColor(nil, @"e7e7e7");
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
	NSDictionary* params = [url queryDictionary];
	NSString* appclient = params[@"appclient"];
	if ([appclient isEqualToString:@"2"])
	{
		_sortTypeNames = [params[@"sortfield"] JSONValue];
		if (_sortTypeNames.count > 0)
		{
			if (_sortIndex >= _sortTypeNames.count)
				_sortIndex = 0;
			[self updateSortButton];
			SortTypeModel* sm = [[SortTypeModel alloc] initWithDictionary:_sortTypeNames[_sortIndex]];
			url = [NSURL URLWithString:[NSString stringWithFormat:@"%@&sortid=%d", _pageURL, sm.sortid]];
		}
	}
	else if ([appclient isEqualToString:@"3"])
	{
		url = [NSURL URLWithString:[NSString stringWithFormat:@"%@&fav=0&down=0", _pageURL]];
	}
	
	_shouldReload = YES;
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
	NSNumber* uid = CDIDProp(PropUserID);
	NSString* userid = (uid == nil ? @"" : uid.stringValue);
	NSString* session = CDProp(PropUserSession);
	if (userid.length > 0 && session.length > 0)
	{
		NSString* account = CDProp(PropUserAccount);
		NSString* name = CDProp(PropUserName);
		NSString* uuid = [ASIdentifierManager sharedManager].advertisingIdentifier.UUIDString;
		if (account == nil) account = @"";
		if (name == nil) name = @"";
		if (uuid == nil) uuid = @"";
		NSString* cookieStr = [NSString stringWithFormat:@"userid=%@; sessionid=%@; usrname=%@; nickname=%@; uuid=%@", userid, session, account, name, uuid];
		[request setValue:cookieStr forHTTPHeaderField:@"Cookie"];
	}
	[_webview loadRequest:request];
}

-(void) updateSortButton
{
	[UIHelper setView:self.rightButton toWidth:100];
	[UIHelper moveView:self.rightButton toX:self.view.bounds.size.width-100];
	[self.rightButton setImage:CDImage(@"store/menu_arrow") forState:UIControlStateNormal];
	self.rightButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
	[self.rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	SortTypeModel* sm = [[SortTypeModel alloc] initWithDictionary:_sortTypeNames[_sortIndex]];
	NSString* sortName = [NSString stringWithFormat:@"按%@", sm.sortname];
	[self.rightButton setTitle:sortName forState:UIControlStateNormal];
	
	CGFloat iw = self.rightButton.imageView.frame.size.width;
	CGFloat bw = self.rightButton.frame.size.width;
	self.rightButton.titleEdgeInsets = UIEdgeInsetsMake(0, -10, 0, iw);
	self.rightButton.imageEdgeInsets = UIEdgeInsetsMake(0, bw-iw-10, 0, 0);
}

-(void) rightButtonAction:(id)sender
{
	SelectorView* sv = [[SelectorView alloc] initWithFrame:CGRectMake(320-93-4, _naviBarHeight-13, 93, 150)];
	sv.delegate = self;
	NSMutableArray* items = [NSMutableArray array];
	for (NSDictionary* dic in _sortTypeNames)
	{
		SortTypeModel* sm = [[SortTypeModel alloc] initWithDictionary:dic];
		NSString* sortName = [NSString stringWithFormat:@"按%@", sm.sortname];
		[items addObject:sortName];
	}
	sv.selectedIndex = _sortIndex;
	sv.items = [NSArray arrayWithArray:items];
	[UIHelper setView:sv toHeight:sv.totalHeight];
	[sv showInView:self.view];
}

-(void) didSelect:(SelectorView *)selectorView index:(NSUInteger)index
{
	[selectorView dismiss];
	_sortIndex = index;
	[self reloadPage];
}

-(BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	NSLog(@"%@", request.URL.absoluteString);
	
	if (_shouldReload)
	{
		// 对第一次请求不会拦截
		_shouldReload = NO;
		return YES;
	}
	
	NSString* scheme = request.URL.scheme;
	if ([scheme isEqualToString:@"xlreader"])
	{
		NSString* path = request.URL.path;
		NSDictionary* params = [request.URL queryDictionary];
		if ([path isEqualToString:@"/showreader"])
		{
			[self.view showPopMsg:[NSString stringWithFormat:@"阅读, bookid=%@, dirid=%@", params[@"bookid"], params[@"dirid"]] timeout:5];
		}
		else if ([path isEqualToString:@"/addfav"])
		{
			[self.view showPopMsg:[NSString stringWithFormat:@"收藏, bookid=%@", params[@"bookid"]] timeout:5];
		}
		else if ([path isEqualToString:@"/download"])
		{
			[self.view showPopMsg:[NSString stringWithFormat:@"下载, bookid=%@", params[@"bookid"]] timeout:5];
		}
		return NO;
	}
	
	NSDictionary* params = [request.URL queryDictionary];
	if ([params[@"appclient"] isEqualToString:@"4"])
	{
		[[UIApplication sharedApplication] openURL:request.URL];
		return NO;
	}
	
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

