//
//  EmailDetailViewController.m
//  IMReasonable
//
//  Created by 翁金闪 on 15/11/19.
//  Copyright © 2015年 Reasonable. All rights reserved.
//

#import "PJNetWorkHelper.h"
#import "SpreadMailModel.h"
#import "EmailDetailViewController.h"
#import "AnimationHelper.h"
#import "MBProgressHUD.h"

@interface EmailDetailViewController ()

@property(nonatomic,strong)UIWebView *webView;
//是否成功加载过网页一次
@property(nonatomic,assign)BOOL hasLoadSucOnce;
//是否是返回上一个网页
@property(nonatomic,assign)BOOL isGoBack;

@end

@implementation EmailDetailViewController

-(void)initController{
    UIBarButtonItem *backButton =[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BACK", nil)
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = backButton;
    self.webView=[[UIWebView alloc] init];
    CGRect webViewFrame=CGRectMake(0, 0, SCREENWIDTH, SCREENWIHEIGHT);
    self.webView.scalesPageToFit=YES;
    self.webView.frame=webViewFrame;
    [self.view addSubview:self.webView];
    self.webView.delegate=self;
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:self.model.newsletterLinkUrl] cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:16.0];
    NSLog(@"%@",self.model.newsletterLinkUrl);
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
    self.hasLoadSucOnce=true;
    [AnimationHelper removeHUD];
    NSLog(@"webViewDidFinishLoad");
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    if(!self.hasLoadSucOnce){
        
        UIButton *button=[[UIButton alloc]init];
        [button setImage:[UIImage imageNamed:@"network_error"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(reLoad) forControlEvents:UIControlEventTouchUpInside];
        button.frame=CGRectMake(0, 0, 100, 100);
        [self.view addSubview:button];
        button.center=self.view.center;
    }
    [AnimationHelper removeHUD];
    NSLog(@"didFailLoadWithError:%ld",(long)error.code);
}

-(void)reLoad{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:self.model.newsletterLinkUrl] cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:16.0];
        [self.webView loadRequest:request];
    });
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if([PJNetWorkHelper isNetWorkAvailable]){
        
        return true;
    }else if(self.isGoBack){
        
        return true;
    }
    else{
        
        [PJNetWorkHelper NoNetWork];
        return false;
    }
}

-(void)back{
    if(self.webView.canGoBack){
        
        self.isGoBack=YES;
        [self.webView goBack];
    }else{
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
