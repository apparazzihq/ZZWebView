//
//  ZZViewController.m
//  ZZWebViewSample
//
//  Created by Jonathan Ellis on 31/03/2013.
//  Copyright (c) 2013 Apparazzi. All rights reserved.
//

#import "ZZViewController.h"

@implementation ZZViewController

- (id)init {
    if (self = [super init]) {
        webView = [[ZZWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        webView.zzDelegate = self;
    }
    return self;
}

- (void)loadView {
    self.view = webView;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSString *html = @"<h1><$title$></h1><$body$>";
    
    [webView loadHTMLString:html baseURL:nil];
}

- (NSString *)webView:(ZZWebView *)webView htmlForTag:(NSString *)tag {
    
    if ([tag isEqualToString:@"title"]) return @"Page Title";
    else return @"This is the body. Bla bla bla.";
}

@end
