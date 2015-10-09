//
//  FriendsCircleViewController.m
//  IMReasonable
//
//  Created by apple on 15/8/19.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import "FriendsCircleViewController.h"

@interface FriendsCircleViewController ()

@end

@implementation FriendsCircleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = YES;
    // 隐藏标签栏
  //  self.tabBarController.tabBar.hidden = YES;
    // 隐藏导航栏
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
