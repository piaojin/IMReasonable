//
//  SelectUserViewController.h
//  IMReasonable
//
//  Created by apple on 15/2/3.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectDelegate.h"
#import "IMChatListModle.h"

@interface SelectUserViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate>


@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic,strong) id<SelectUserDelegate> selectUserdelegate;

@property BOOL  flag;
@property BOOL  isGroup;
@property BOOL  isAddGroupUser;
@property NSString *  tempsubject;
@property NSString *   forwardmessage;
@property BOOL  isforward;
@property  IMChatListModle * from;


@end
