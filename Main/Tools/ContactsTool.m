//
//  ContactsTool.m
//  IMReasonable
//
//  Created by 翁金闪 on 15/10/13.
//  Copyright © 2015年 Reasonable. All rights reserved.
//

#import "PJSendInviteHttpTool.h"
#import "ContactsTool.h"
#import <AddressBook/AddressBook.h>
#import "AnimationHelper.h"
#import "XMPPDao.h"

#define STARTWITHONE @"1"
#define LENGTH11 11
#define LENGTH8 8
#define INVITE_ALL_FRIENDS_COMPLETE @"INVITE_ALL_FRIENDS_COMPLETE"

@interface ContactsTool()
/**
 *  群邀用到的变量
 */
//群邀到哪个手机号码
@property(nonatomic,assign)int invitationindex;
//待群邀的用户手机号码
@property(nonatomic,copy)NSArray *invitationarray;
//待群邀的用户数量
@property(nonatomic,assign)int count;
@end
@implementation ContactsTool

-(int)count{
    if(_count==0){
        
        _count=self.invitationarray.count;
    }
    return _count;
}

//懒加载所有的手机号码
-(NSArray *)invitationarray{
    if(!_invitationarray){
        
        _invitationarray=[self GetAllPhone];
    }
    return _invitationarray;
}

//添加了国家代码前缀的手机号码
-(NSArray *)GetAllPhone{
    __block NSMutableArray *array=[NSMutableArray array];
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        ABAddressBookRef addressBook = ABAddressBookCreate();
        CFArrayRef results = ABAddressBookCopyArrayOfAllPeople(addressBook);
        array=GetPhone_Block(results);
        CFRelease(results);
        CFRelease(addressBook);
    });
    return array;
}
-(NSArray *)GetAllEmail{
    __block NSMutableArray *array=[NSMutableArray array];
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        ABAddressBookRef addressBook = ABAddressBookCreate();
        CFArrayRef results = ABAddressBookCopyArrayOfAllPeople(addressBook);
        array=GetEmail_Block(results);
        CFRelease(results);
        CFRelease(addressBook);
    });
    return array;
}

//获取邮箱账号
NSMutableArray *(^GetEmail_Block)(CFArrayRef)=^(CFArrayRef results){
    NSMutableArray *array=[NSMutableArray array];
    for(int i = 0; i < CFArrayGetCount(results); i++)
    {
        ABRecordRef person = CFArrayGetValueAtIndex(results, i);
        //获取email多值
        ABMultiValueRef email = ABRecordCopyValue(person, kABPersonEmailProperty);
        int emailcount = ABMultiValueGetCount(email);
        for (int x = 0; x < emailcount; x++)
        {
            //获取email值
            NSString* emailContent = (__bridge NSString*)ABMultiValueCopyValueAtIndex(email, x);
            //邮箱格式验证
            if([Tool isValidateEmail:emailContent]){
                
                [array addObject:emailContent];
            }
        }
    }
    return array;
};

//发送邀请短信，如果是talking用户则发送好友邀请
-(void)sendTalkingInvite:(id)requestObject{
    
    NSDictionary *data=requestObject;
    NSDictionary * code=[data objectForKey:@"SendInvitationResult"];
    NSInteger state=(NSInteger)[code valueForKey:@"count"];
    if (state>0) {
        NSArray * user=[code objectForKey:@"userarr"];
        if ( ![user isKindOfClass:[NSNull class]]  && user != nil && user.count != 0) {//如果有用户是使用过的
            NSString * data=@"";
            for (int i=0; i<user.count; i++) {
                
                NSString * phone=[user objectAtIndex:i];
                if (phone && ![phone isEqualToString:@""]) {
                    data=[NSString stringWithFormat:@"%@,%@",phone,data];
                    [[XMPPDao sharedXMPPManager] XMPPAddFriendSubscribe:phone]; //是openfire的用户就发送好友邀请
                    [[XMPPDao sharedXMPPManager] queryOneRoster:[NSString stringWithFormat:@"%@%@",phone,XMPPSERVER2]];//请求该联系人的信息
                }
            }
            if (data && data.length>2) {
                
                NSString *indata = [data substringToIndex:data.length - 1];
                [IMReasonableDao  updateUserIsLocal:indata];
                
            }
        }
    }

}

//获取手机号码
NSMutableArray *(^GetPhone_Block)(CFArrayRef)=^(CFArrayRef results){
    NSMutableArray *array=[NSMutableArray array];
    for(int i = 0; i < CFArrayGetCount(results); i++)
    {
        ABRecordRef person = CFArrayGetValueAtIndex(results, i);
        //读取电话多值
        ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
        for (int k = 0; k<ABMultiValueGetCount(phone); k++)
        {
            //获取該Label下的电话值
            NSString * personPhone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phone, k);
            if(personPhone!=nil&&![personPhone isEqualToString:@""]){
                
                personPhone = [personPhone stringByReplacingOccurrencesOfString:@" " withString:@""];
                personPhone = [personPhone stringByReplacingOccurrencesOfString:@"+" withString:@""];
                personPhone = [personPhone stringByReplacingOccurrencesOfString:@"-" withString:@""];
                //手机号码位数判断(香港的手机号码位数比大陆的少)
                if(personPhone.length>=8){
                    
                    //这边只判断大陆手机号码与香港手机号码
                    if([personPhone hasPrefix:STARTWITHONE]){//以1开头的手机号码
                        
                        if(personPhone.length==LENGTH11){//大陆未加86的手机号码
                            
                            personPhone = [@"" stringByAppendingFormat:@"%@%@",@"86", personPhone];
                        }
                    }else{
                        
                        if(personPhone.length==LENGTH8){//香港未加前缀的手机号码
                            
                            personPhone = [@"" stringByAppendingFormat:@"%@%@",@"00852", personPhone];
                        }
                    }
                    [array addObject:personPhone];
                }
            }
        }
        
    }
    return array;
};

//群邀
-(void)Invite{
    if(self.count>0&&self.invitationindex<=self.count-1){
        
        NSDictionary *param=[NSDictionary dictionaryWithObject:_invitationarray[self.invitationindex] forKey:@"phone"];
        [PJSendInviteHttpTool SendInviteByPostWithParam:param success:^(id success) {
            NSLog(@"success");
            self.invitationindex++;
            [self sendTalkingInvite:success];
            [self Invite];
        } failure:^(NSError * error) {
            NSLog(@"error");
            self.invitationindex++;
            [self Invite];
        }];
        
    }else{
        
        if(self.count>0){
            
            //群邀完成
            [Tool alert:NSLocalizedString(INVITE_ALL_FRIENDS_COMPLETE, nil)];
        }
        self.invitationindex=0;
    }
}

+(void)DidInviteAllFriends{
    [[[self alloc] init] Invite];
}
@end
