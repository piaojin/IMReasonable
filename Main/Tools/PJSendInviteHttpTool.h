//
//  PJSendInviteHttpTool.h
//  IMReasonable
//
//  Created by 翁金闪 on 15/10/13.
//  Copyright © 2015年 Reasonable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PJSendInviteHttpTool : NSObject
//发送短信邀请
+(void)SendInviteByPostWithParam:(NSDictionary *)param success:(void (^)(id))success failure:(void (^)(NSError *))failure;
@end
