//
//  ContactsTool.m
//  IMReasonable
//
//  Created by 翁金闪 on 15/10/13.
//  Copyright © 2015年 Reasonable. All rights reserved.
//

#import "SendEmailInvitationEntity.h"
#import "PJSendInviteHttpTool.h"
#import "ContactsTool.h"
#import <AddressBook/AddressBook.h>
#import "AnimationHelper.h"
#import "XMPPDao.h"

#define USETALKING @"Use Talkking"
#define GETALLPHONE 0//获取所有的手机号码
#define GETALLEMAIL 1//获取所有的邮箱
#define STARTWITHONE @"1"
#define LENGTH11 11
#define LENGTH8 8
#define INVITE_ALL_FRIENDS_COMPLETE @"INVITE_ALL_FRIENDS_COMPLETE"
#define INVITEBODY @"InvitationBody"
#define BODY @"<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'><html><body><div align='center'><a href='https://app.rspread.com/' target='_blank' title='Spread' style='text-decoration: none;'><img src='http://app.rspread.com/images/spreadlogocn.jpg' height='87' width='105' style='border: 0 none;color: #6dc6dd !important;font-family: Helvetica,Arial,sans-serif;font-size: 60px;font-weight: bold;height: auto !important;letter-spacing: -4px;line-height: 100%;outline: medium none;text-align: center;text-decoration: none;'></a></div><div align='center'><h1 style='color: #606060 !important; font-family: Helvetica, Arial,    sans-serif; font-size: 32px; font-weight: bold; letter-spacing: -1px; line-height: 115%; margin: 0; padding: 0; text-align: center;'>%@</h1><br><font style='color: #606060;font-family: Helvetica, Arial, sans-serif; font-size: 15px;text-align: center;'>Click and DownLoad Talkking.</font></div><br><div align='center'><div align='center'  style='background-color: #6DC6DD;width:100px;height:60px;line-height:60px;'><a href='' target='_blank' style='color: #FFFFFF; text-decoration: none;'>DownLoad Talkking</a></div></div><br><div align='center'><font align='center'  class='footerContent' style='color: #606060; font-family: Helvetica, Arial, sans-serif; font-size: 13px; line-height: 125%;'>Copyright<span style='border-bottom:1px dashed #ccc;z-index:1' onclick='return false;' data='2006-2015'>2006-2015</span><br>Reasonable Software House Limited. All Rights Reserved.</font></div></body></html>"

@interface ContactsTool()
/**
 *  群邀用到的变量
 */
//存放所有的手机号码和邮箱
@property(nonatomic,copy)NSArray *invitationarrays;
//群邀到哪个手机号码
@property(nonatomic,assign)int invitationphoneindex;
//待群邀的用户手机号码
@property(nonatomic,copy)NSArray *invitationphonearray;
//待群邀的手机号码数量
@property(nonatomic,assign)int invitationphonecount;
//待群邀的邮箱
@property(nonatomic,copy)NSArray *invitationemailarray;
//群邀到哪个邮箱
@property(nonatomic,assign)int invitationemailindex;
//待群邀的邮箱数量
@property(nonatomic,assign)int invitationemailcount;
@end
@implementation ContactsTool

//懒加载所有的手机号码和邮箱
-(NSArray *)invitationarrays{
    if(!_invitationarrays){
        
        _invitationarrays=[self GetAllPhoneAndAllEmail];
    }
    return _invitationarrays;
}

-(int)invitationphonecount{
    if(_invitationphonecount==0){
        
        _invitationphonecount=self.invitationphonearray.count;
    }
    return _invitationphonecount;
}

//懒加载所有的手机号码
-(NSArray *)invitationphonearray{
    if(!_invitationphonearray){
        
        _invitationphonearray=(NSArray *)self.invitationarrays[GETALLPHONE];
    }
    return _invitationphonearray;
}

-(int)invitationemailcount{
    if(_invitationemailcount==0){
        
        _invitationemailcount=self.invitationemailarray.count;
    }
    return _invitationemailcount;
}

//懒加载所有的邮箱
-(NSArray *)invitationemailarray{
    if(!_invitationemailarray){
        
        _invitationemailarray=(NSArray *)self.invitationarrays[GETALLEMAIL];
    }
    return _invitationemailarray;
}

//获取所有的手机号码和邮箱地址
-(NSArray *)GetAllPhoneAndAllEmail{
   __block NSMutableArray *array=[NSMutableArray array];
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        ABAddressBookRef addressBook = ABAddressBookCreate();
        CFArrayRef results = ABAddressBookCopyArrayOfAllPeople(addressBook);
        array=GetPhoneAndEmail_Block(results);
        CFRelease(results);
        CFRelease(addressBook);
    });
    return array;
}

NSMutableArray *(^GetPhoneAndEmail_Block)(CFArrayRef)=^(CFArrayRef results){
    NSMutableArray *array=[NSMutableArray array];
    NSMutableArray *phonearray=[NSMutableArray array];
    NSMutableArray *emailarray=[NSMutableArray array];
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
                    [phonearray addObject:personPhone];
                }
            }
        }
        //获取email多值
        ABMultiValueRef email = ABRecordCopyValue(person, kABPersonEmailProperty);
        int emailcount = ABMultiValueGetCount(email);
        //获取邮件
        for (int x = 0; x < emailcount; x++)
        {
            //获取email值
            NSString* emailContent = (__bridge NSString*)ABMultiValueCopyValueAtIndex(email, x);
            //邮箱格式验证
            if([Tool isValidateEmail:emailContent]){
                
                [emailarray addObject:emailContent];
            }
        }
    }
    [array addObject:phonearray];
    [array addObject:emailarray];
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

//群邀手机号码
-(void)InvitePhone{
    if(self.invitationphonecount>0&&self.invitationphoneindex<=self.invitationphonecount-1){
        
        NSDictionary *param=[NSDictionary dictionaryWithObject:_invitationphonearray[self.invitationphoneindex] forKey:@"phone"];
        [PJSendInviteHttpTool SendInviteByPostWithParam:param success:^(id success) {
            NSLog(@"success");
            self.invitationphoneindex++;
            [self sendTalkingInvite:success];
            [self InvitePhone];
        } failure:^(NSError * error) {
            NSLog(@"error");
            self.invitationphoneindex++;
            [self InvitePhone];
        }];
        
    }else{
        
        if(self.invitationphonecount>0){
            
            //群邀手机号码完成，开始群邀邮箱
            [self InviteEmail];
        }
        self.invitationphoneindex=0;
    }
}

//群邀邮箱
-(void)InviteEmail{
    if(self.invitationemailcount>0&&self.invitationemailindex<=self.invitationemailcount-1){
        
        NSString* phone= [[[[NSUserDefaults standardUserDefaults] objectForKey:XMPPREASONABLEJID] componentsSeparatedByString:@"@"] objectAtIndex:0];
            SendEmailInvitationEntity *entity=[[SendEmailInvitationEntity alloc] init];
            entity.LoginEmail=LOGINEMAIL;
            entity.Password=PASSWORD;
            entity.From=FROM;
            entity.FromName=FROMNAME;
            entity.To=_invitationemailarray[self.invitationemailindex];
            entity.Subject=USETALKING;
            NSString *body=[NSString stringWithFormat:BODY,[NSString stringWithFormat:NSLocalizedString(INVITEBODY, nil),phone]];
            entity.Body=body;
            [PJSendInviteHttpTool SendEmailInviteByPostWithParam:entity success:^(id requestObject) {
                NSLog(@"success");
                self.invitationemailindex++;
                [self InviteEmail];
            } failure:^(NSError * error) {
                NSLog(@"error");
                self.invitationemailindex++;
                [self InviteEmail];
            }];
    }else{
        
        if(self.invitationemailcount>0){
            
            //群邀手机号码完成，开始群邀邮箱
            [Tool alert:NSLocalizedString(INVITE_ALL_FRIENDS_COMPLETE, nil)];
        }
        self.invitationemailindex=0;
    }
}

+(void)DidInviteAllFriends{
    [[[self alloc] init] InvitePhone];
}
@end
