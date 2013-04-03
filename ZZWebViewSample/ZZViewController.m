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
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://github.com/apparazzihq/ZZWebView/blob/master/ZZWebViewSample/example.htm"]];
    
    [webView loadRequest:request];
}

- (NSString *)webView:(ZZWebView *)webView htmlForTag:(NSString *)tag {
    
    if ([tag isEqualToString:@"name"]) return @"John Smith";
    if ([tag isEqualToString:@"age"]) return @"45";
    if ([tag isEqualToString:@"location"]) return @"New York, NY";
    return nil;
}

@end
