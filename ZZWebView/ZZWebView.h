//
//  ZZWebView.h
//  ZZWebViewSample
//
//  Created by Jonathan Ellis on 31/03/2013.
//  Copyright (c) 2013 Apparazzi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZZWebView;

@protocol ZZWebViewDelegate <NSObject>

- (BOOL)webView:(ZZWebView *)webView navigatedToURL:(NSURL *)url;
- (NSString *)webView:(ZZWebView *)webView htmlForTag:(NSString *)tag;

@end

@interface ZZWebView : UIWebView <UIWebViewDelegate, NSURLConnectionDelegate> {
    __unsafe_unretained id<ZZWebViewDelegate> _zzDelegate;

    NSURL *url;
    NSURLResponse *receivedResponse;
    NSMutableData *receivedData;
}

@property (nonatomic, assign) id zzDelegate;
@property (readonly) NSDictionary *query;

@end
