//
//  MailTableViewCell.h
//  IMReasonable
//
//  Created by apple on 15/9/10.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BorderView.h"

@interface MailTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet BorderView *borderview;
@property (weak, nonatomic) IBOutlet UILabel *mailsendername;
@property (weak, nonatomic) IBOutlet UILabel *mailtitle;
@property (weak, nonatomic) IBOutlet UILabel *mailcontent;
@end
