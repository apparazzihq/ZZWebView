//
//  ZZViewController.m
//  ZZWebViewSample
//
//  Created by Jonathan Ellis on 31/03/2013.
//  Copyright (c) 2013 Apparazzi. All rights reserved.
//

#import "ZZViewController.h"

@implementation ZZViewController

- (void)loadView {
    ZZWebView *webView = [[ZZWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    self.view = webView;
}

@end
