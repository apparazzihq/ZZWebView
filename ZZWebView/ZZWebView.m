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


@implementation ZZWebView

@synthesize zzDelegate = _zzDelegate;

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL {
    
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
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    if (connection) {
        receivedData = [NSMutableData data];
    }
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
    
    NSStringEncoding responseEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((CFStringRef)receivedResponse.textEncodingName));
    
    NSString *string = [[NSString alloc] initWithData:receivedData encoding:responseEncoding];
    [self loadHTMLString:string baseURL:receivedResponse.URL];
    
    connection = nil;
    receivedData = nil;
}

@end
