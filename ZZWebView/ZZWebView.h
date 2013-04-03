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

- (NSString *)webView:(ZZWebView *)webView htmlForTag:(NSString *)tag;

@end

@interface ZZWebView : UIWebView {
    __unsafe_unretained id<ZZWebViewDelegate> _zzDelegate;
}

@property (nonatomic, assign) id zzDelegate;

@end
