//
//  MailTableViewCell.m
//  IMReasonable
//
//  Created by apple on 15/9/10.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import "MailTableViewCell.h"

@implementation MailTableViewCell

- (void)awakeFromNib {
    // Initialization code
}


- (id)initWithCoder:(NSCoder*)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.backgroundColor=[UIColor colorWithRed:193 green:193 blue:193 alpha:1];
    }
    return self;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
