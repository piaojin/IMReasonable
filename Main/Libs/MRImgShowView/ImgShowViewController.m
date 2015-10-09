//
//  ImgShowViewController.m
//  Project-Movie
//
//  Created by Minr on 14-11-14.
//  Copyright (c) 2014年 Minr. All rights reserved.
//

#import "ImgShowViewController.h"
#import "MRImgShowView.h"
#import "MessageModel.h"

@interface ImgShowViewController ()

@end

@implementation ImgShowViewController

- (id)initWithSourceData:(NSArray *)data withIndex:(NSInteger)index{
    
    self = [super init];
    if (self) {
       //[self init];
        _data=data;
        _index = index;
    }
    return self;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title =NSLocalizedString(@"lbImgShowViewB", nil);// @"Images";
    
    //设置导航栏为半透明
    self.navigationController.navigationBar.translucent = YES;
    // 隐藏标签栏
    self.tabBarController.tabBar.hidden = YES;
    // 隐藏导航栏
    self.navigationController.navigationBarHidden = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self.view addGestureRecognizer:tap];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor =[UIColor blackColor];
    [self creatImgShow];
}

// 初始化视图
- (void)creatImgShow{
    
    MRImgShowView *imgShowView = [[MRImgShowView alloc]
                                  initWithFrame:self.view.frame
                                    withSourceData:_data
                                    withIndex:_index];
    
    // 解决谦让
    [imgShowView requireDoubleGestureRecognizer:[[self.view gestureRecognizers] lastObject]];
    [self.view addSubview:imgShowView];
    
    //设置图片显示的标题
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    UILabel * indexnumber=[[UILabel alloc] initWithFrame:CGRectMake((width-80)/2, height-40, 80, 40)];
    indexnumber.tag=989;
    [indexnumber setText:[NSString stringWithFormat:@"%ld/%lu",(_index+1)>_data.count?1:(_index+1),(unsigned long)_data.count]];
    [indexnumber setTextColor:[UIColor whiteColor]];
    [indexnumber setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:indexnumber];

}

#pragma mark -UIGestureReconginzer
- (void)tapAction:(UITapGestureRecognizer *)tap
{
    // 隐藏导航栏
    [UIView animateWithDuration:0.3 animations:^{
        self.navigationController.navigationBarHidden = !self.navigationController.navigationBarHidden;
    }];

}
@end

