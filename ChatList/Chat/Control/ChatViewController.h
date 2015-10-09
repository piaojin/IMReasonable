//
//  ChatViewControl.h
//  IMReasonable
//
//  Created by apple on 15/6/12.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMChatListModle.h"
#import "WeChatKeyBoard.h"
#import "WeChatTableViewCell.h"
#import "AppDelegate.h"

@interface ChatViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,WeChatKeyBoardDelegate,WeChatTableViewCellDelegate,ChatHelerpDelegate,FriendreceivemsgDelegate,AuthloginDelegate>

@property (nonatomic,copy) IMChatListModle * from;
@property (nonatomic,copy) NSString * myjibstr;

@property (nonatomic,copy) NSString * forwardmssage;//转发的信息内容
@property  BOOL  isforward;//是否转发

@property  BOOL  isNeedCustom;

@end
