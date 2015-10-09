//
//  SpreadMailViewController.h
//  IMReasonable
//
//  Created by apple on 15/9/10.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMChatListModle.h"
#import "WeChatTableViewCell.h"

@interface SpreadMailViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,WeChatTableViewCellDelegate>
@property (nonatomic,weak) IMChatListModle * from;
@end
