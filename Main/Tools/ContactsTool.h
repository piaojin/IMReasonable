//
//  ContactsTool.h
//  IMReasonable
//
//  Created by 翁金闪 on 15/10/13.
//  Copyright © 2015年 Reasonable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactsTool : NSObject
-(NSArray *)GetAllPhone;
-(NSArray *)GetAllEmail;
//群邀
+(void)DidInviteAllFriends;
@end
