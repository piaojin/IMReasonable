//
//  AnimationHelper.m
//  IMReasonable
//
//  Created by apple on 14/11/14.
//  Copyright (c) 2014年 Reasonable. All rights reserved.
//

#import "AnimationHelper.h"
#import "MBProgressHUD.h"

@implementation AnimationHelper

static MBProgressHUD *HUD;
//MBProgressHUD 的使用方式，只对外两个方法，可以随时使用(但会有警告！)，其中窗口的 alpha 值 可以在源程序里修改。
+ (void)showHUD:(NSString *)msg{
    
    HUD = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
    [[UIApplication sharedApplication].keyWindow addSubview:HUD];
    HUD.dimBackground = YES;
    HUD.labelText = msg;
    [HUD show:YES];
}
+ (void)removeHUD{
    
    [HUD hide:YES];
    [HUD removeFromSuperViewOnHide];
 
}

@end
