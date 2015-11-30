//
//  EmailDetailViewController.m
//  IMReasonable
//
//  Created by 翁金闪 on 15/11/19.
//  Copyright © 2015年 Reasonable. All rights reserved.
//

#import "SpreadMailModel.h"
#import "EmailDetailViewController.h"
#import "AnimationHelper.h"

@interface EmailDetailViewController ()

@property(nonatomic,strong)UIWebView *webView;
//@property(nonatomic,assign)BOOL 

@end

@implementation EmailDetailViewController

-(void)initController{
    self.webView=[[UIWebView alloc] init];
    CGRect webViewFrame=CGRectMake(0, 0, SCREENWIDTH, SCREENWIHEIGHT);
    self.webView.frame=webViewFrame;
    [self.view addSubview:self.webView];
    self.webView.delegate=self;
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:self.model.newsletterLinkUrl] cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:16.0];
    [self.webView loadRequest:request];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self initController];
    NSLog(@"%@",self.model.newsletterLinkUrl);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)webViewDidStartLoad:(UIWebView *)webView{
    [AnimationHelper showHUD:@"load......"];
    NSLog(@"webViewDidStartLoad");
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [AnimationHelper removeHUD];
    NSLog(@"webViewDidFinishLoad");
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [AnimationHelper removeHUD];
    NSLog(@"didFailLoadWithError");
}

@end
