//
//  ZZWebView.m
//  ZZWebViewSample
//
//  Created by Jonathan Ellis on 31/03/2013.
//  Copyright (c) 2013 Apparazzi. All rights reserved.
//

#import "ZZWebView.h"

#define kTAG_OPEN   @"<$"
#define kTAG_CLOSE  @"$>"
#define kESCAPE_CHAR '/'


@interface NSScanner (Simple)

- (NSString *)scanUpToString:(NSString *)string;

@end

@implementation NSScanner (Simple)

- (NSString *)scanUpToString:(NSString *)string {
    NSString *result;
    [self scanUpToString:string intoString:&result];
    return result;
}

@end


@interface NSDictionary (QueryString)

+ (NSDictionary *)dictionaryWithQueryString:(NSString *)queryString;

@end

@implementation NSDictionary (QueryString)

+ (NSDictionary *)dictionaryWithQueryString:(NSString *)queryString {
    
    NSMutableDictionary *result;
    
    NSArray *components = [queryString componentsSeparatedByString:@"&"];
    for (NSString *component in components) {
        NSArray *innerComponents = [component componentsSeparatedByString:@"="];
        if (!result) result = [NSMutableDictionary dictionary];
        result[innerComponents[0]] = innerComponents[1];
    }
    
    return result;
}

@end

@implementation ZZWebView

@synthesize zzDelegate = _zzDelegate;
@synthesize query;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.delegate = self;
    }
    return self;
}

- (NSDictionary *)query {
    return [NSDictionary dictionaryWithQueryString:url.query];
}

- (void)setDelegate:(id<UIWebViewDelegate>)delegate {
    NSAssert(!self.delegate, @"ZZWebView: You cannot set the delegate property. Use the zzDelegate property instead.");
    [super setDelegate:delegate];
}

#pragma mark - UIWebView methods

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL {
    if (!url) url = baseURL;
    
    NSScanner *scanner = [NSScanner scannerWithString:string];
    NSMutableString *outputString = [NSMutableString stringWithString:@""];
    
    do {
        [outputString appendString:[scanner scanUpToString:kTAG_OPEN]];

        int tagOpenPosition = [scanner scanLocation];
        
        BOOL isEscaped = [string characterAtIndex:scanner.scanLocation-1] == kESCAPE_CHAR;
        
        if (tagOpenPosition < string.length) {
            
            [scanner setScanLocation:tagOpenPosition+kTAG_OPEN.length];
            
            if (!isEscaped) {
                NSString *tagTitle = [scanner scanUpToString:kTAG_CLOSE];
                
                int tagClosePosition = scanner.scanLocation;
                [scanner setScanLocation:tagClosePosition+kTAG_CLOSE.length];

                
                NSString *replacementHTML = [self.zzDelegate webView:self htmlForTag:tagTitle];
                [outputString appendString:replacementHTML];
            } else {
                [outputString appendString:kTAG_OPEN];
            }
            
        }
    } while (![scanner isAtEnd]);
    
    [super loadHTMLString:outputString baseURL:baseURL];
}

- (void)loadRequest:(NSURLRequest *)request {
    url = request.URL;
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    if (connection) {
        receivedData = [NSMutableData data];
    }
}

#pragma mark - UIWebViewDelegate methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [self loadRequest:request];
        return NO;
    }

    return YES;
}

#pragma mark - NSURLConnectionDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    receivedResponse = response;
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    connection = nil;
    receivedData = nil;
    
    [self.delegate webView:self didFailLoadWithError:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSStringEncoding responseEncoding = NSUTF8StringEncoding; // Default encoding
    
    if (receivedResponse.textEncodingName) {
        responseEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((CFStringRef)receivedResponse.textEncodingName));
    }
    
    NSString *string = [[NSString alloc] initWithData:receivedData encoding:responseEncoding];
    [self loadHTMLString:string baseURL:receivedResponse.URL];
    
    connection = nil;
    receivedData = nil;
}

@end
