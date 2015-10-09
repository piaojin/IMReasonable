//
//  ThirdViewController.m
//  IMReasonable
//
//  Created by apple on 15/1/12.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import "ThirdViewController.h"
#import "AppDelegate.h"
#import "MainViewController.h"
#import "AnimationHelper.h"
#import <AddressBook/AddressBook.h>
#import "ASIFormDataRequest.h"
#import "MBProgressHUD.h"


@interface ThirdViewController ()
{
   /// NSMutableArray * friends;
    
    BOOL isneedchange;
}

@end

@implementation ThirdViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    isneedchange=false;
   // [self.view setBackgroundColor:[UIColor whiteColor]];
  
    [self.img.layer setBorderWidth:1]; //设置头像选择边框
    //设置边框线的颜色
    [self.img.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    
    self.nav.title=NSLocalizedString(@"lbTTile", nil);
    
    NSString * imagename=[[NSUserDefaults standardUserDefaults] objectForKey:XMPPMYFACE];
    UIImage * tempimg=[UIImage imageWithContentsOfFile:[Tool getFilePathFromDoc:imagename]];
    self.img.image=tempimg;
    
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    NSString * locaname=[defaults objectForKey:MyLOCALNICKNAME];
    NSString * localemail=[defaults objectForKey:MyEmail];
    self.txtName.text=locaname;
    self.email.text=localemail;
    
    //为调试用 设置这个名字会弹出设备的Token
    if ([locaname isEqualToString:@"__Tim"]) {
          NSString *token= [defaults stringForKey:@"DeviceToken"];
        [Tool alert:token];
    }
   
    
    self.txtmsg.text=NSLocalizedString(@"lbmsgTitle", nil);
    if (![XMPPDao sharedXMPPManager].xmppStream.isConnected) {
        [[XMPPDao sharedXMPPManager] connect];
    }
    [[XMPPDao sharedXMPPManager] getAllMyRoom];//服务器拉取所有的群
    if (self.isSetting) {
         self.navigationItem.title=NSLocalizedString(@"lbTTile", nil);
        UIBarButtonItem * right=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(doDone:)];
        // right.tintColor=[UIColor colorWithRed:0.13 green:0.67 blue:0.22 alpha:1]; 改成青绿色
        self.navigationItem.rightBarButtonItem=right;
    }else{
        [self GetContacts];
    }
   
   //监听键盘状态
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    //监听输入法状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    
}

#pragma mark Notification
//keyBoard已经展示出来
- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect rect=self.view.frame;
    
    if (rect.origin.y>=0 && self.view.frame.size.height<=480) {
        NSLog(@"%@",NSStringFromCGRect(rect));
        [UIView beginAnimations:nil context:nil];
        //设定动画持续时间
        [UIView setAnimationDuration:2];
        //动画的内容
        
        rect.origin.y -= 130;
        [self.view setFrame:rect];
        //动画结束
        [UIView commitAnimations];
        NSLog(@" 出现");

    }
   }

- (void)keyboardWillHide:(NSNotification *)notification
{
    CGRect rect=self.view.frame;
    if (rect.origin.y<0) {
        [UIView beginAnimations:nil context:nil];
        //设定动画持续时间
        [UIView setAnimationDuration:1];
        //动画的内容
        CGRect rect=self.view.frame;
        rect.origin.y += 130;
        [self.view setFrame:rect];
        //动画结束
        [UIView commitAnimations];
        NSLog(@"关闭");
    }
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.txtName resignFirstResponder];
    [self.email resignFirstResponder];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
//在这个函数里面创建数据库并获取扫描联系人
- (void)GetContacts
{
   
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
         // [AnimationHelper showHUD:NSLocalizedString(@"lblookforfriend",nil)];
        
        ABAddressBookRef tmpAddressBook = nil;
        //根据系统版本不同，调用不同方法获取通讯录
        if ([[UIDevice currentDevice].systemVersion floatValue]>=6.0) {
            tmpAddressBook=ABAddressBookCreateWithOptions(NULL, NULL);
            dispatch_semaphore_t sema=dispatch_semaphore_create(0);
            ABAddressBookRequestAccessWithCompletion(tmpAddressBook, ^(bool greanted, CFErrorRef error){
                dispatch_semaphore_signal(sema);
            });
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            
        }
        if (tmpAddressBook==nil) {
            return ;
        };
        
        CFArrayRef results = ABAddressBookCopyArrayOfAllPeople(tmpAddressBook);
        
        NSString* myphone= [[[[NSUserDefaults standardUserDefaults] objectForKey:XMPPREASONABLEJID] componentsSeparatedByString:@"@"] objectAtIndex:0];
        
        //在这里边获取所有的联系人
        for(int i = 0; i < CFArrayGetCount(results); i++)
        {
            ABRecordRef person = CFArrayGetValueAtIndex(results, i);
            //读取firstname
            NSString *firstname = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
            //读取lastname
            NSString *lastname = (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
            
            NSString * fullname;
            
            
            NSInteger personID = ABRecordGetRecordID(person);
            
            if ([Tool isHaveChinese:firstname]) {
                fullname=[NSString stringWithFormat:@"%@%@",lastname?lastname:@"",firstname?firstname:@""];
                
            }else{
                fullname=[NSString stringWithFormat:@"%@ %@",firstname?firstname:@"",lastname?lastname:@""];
            }
            
            
            
            //读取电话多值
            ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
            for (int k = 0; k<ABMultiValueGetCount(phone); k++)
            {
                NSString * personPhoneLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(phone, k));
                //  获取該Label下的电话值
                NSString * tmpPhoneIndex = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phone, k);
                
                NSString * unknowphone=[tmpPhoneIndex substringWithRange:NSMakeRange(0,1)];
                tmpPhoneIndex=[Tool getPhoneNumber:tmpPhoneIndex];
                NSString * flag=@"0";
                if (![tmpPhoneIndex isEqualToString:@""]) {
                    
                    if (![unknowphone isEqualToString:@"+"]) {//需要当前用户的国家代码
                        NSString * countrycode=[[NSUserDefaults standardUserDefaults] objectForKey:XMPPUSERCOUNTRYCODE];
                        tmpPhoneIndex=[NSString stringWithFormat:@"%@%@",countrycode,tmpPhoneIndex];
                    }
                    
                    if (![tmpPhoneIndex isEqualToString:myphone]) { //过滤掉自己的电话号码
                        [[XMPPDao sharedXMPPManager] XMPPAddFriendSubscribe:tmpPhoneIndex]; //不管是不是openfire的用户得发送邀请
                        [IMReasonableDao saveUserLocalNick:tmpPhoneIndex image:fullname addid:[NSString stringWithFormat:@"%ld",(long)personID]  isImrea:flag phonetitle:personPhoneLabel];// 保存到本地数据库
                    }
                    
                    
                    
                }
                
                
                
            }
            
            
            
            
        }
        
        CFRelease(results);
        CFRelease(tmpAddressBook);
        
        [AnimationHelper removeHUD];
    
        [self GetAllRegUser];
        
    });
    
    


}

- (void)GetAllRegUser{
    NSMutableArray * alluser=[IMReasonableDao getAllUser];
    [[XMPPDao sharedXMPPManager] checkUser:alluser];
}

//判断电话号码是否不是openfire账户;true  是  fase 不是
- (BOOL)isRegToOpenfire:(NSString *) phone
{
    NSURL *url = [NSURL URLWithString:  [Tool Append:IMReasonableAPP witnstring:@"UserIsReg"]];
    NSString * Apikey= IMReasonableAPPKey;
    NSString * tempphone=phone;
    NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:Apikey, @"apikey",tempphone,@"phone",nil];
    NSDictionary *sendsmsD = [[NSDictionary alloc] initWithObjectsAndKeys:data, @"isreg", nil];
    if ([NSJSONSerialization isValidJSONObject:sendsmsD])
    {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendsmsD options:NSJSONWritingPrettyPrinted error: &error];
        NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
        [request addRequestHeader:@"Accept" value:@"application/json"];
        [request setRequestMethod:@"POST"];
        [request setPostBody:tempJsonData];
        [request startSynchronous ];
        error =[request error];
        if (error == nil ) {
            NSData *responsedata=[request responseData];
            NSDictionary * dict=[Tool jsontodate:responsedata];
    
            NSString *code=[dict objectForKey:@"UserIsRegResult"];
            BOOL flag=false;
            [code isEqualToString:@"1"]?(flag=true):(flag=false);
            return flag;

        } else {
            
            return false;
        }
        
    }else{
        
        return false;
    
    }
}

- (IBAction)btn:(id)sender { //选择图片
    
    //[Tool alert:@"host"];
    [self imagefromwhere];
}

#pragma mark-图片源函数
- (void) imagefromwhere
{
    UIActionSheet * action;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        action  =  [[UIActionSheet alloc]initWithTitle:nil delegate:(id)self cancelButtonTitle:NSLocalizedString(@"lbTCancle", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"lbTPhonto", nil),NSLocalizedString(@"lbTShoot", nil), nil];
    }
    else
    {
        
        action =  [[UIActionSheet alloc]initWithTitle:nil delegate:(id)self cancelButtonTitle:NSLocalizedString(@"lbTCancle", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"lbTPhonto", nil), nil];
    }
    
    action.tag = 255;
    action.actionSheetStyle=UIActionSheetStyleAutomatic;
    [action showInView:self.view];
}

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 255)
    {
        NSUInteger sourceType = 0;
        // 判断是否支持相机
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            switch (buttonIndex)
            {
                case 0:
                    //相册
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    break;
                case 1:
                    // 相机
                    sourceType = UIImagePickerControllerSourceTypeCamera;
                    break;
                case 2:
                    // 取消
                    return;
            }
        }
        else
        {
            if (buttonIndex == 0)
            {
                sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            } else
            {
                return;
            }
        }
        
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = (id)self;
        imagePickerController.allowsEditing = YES;
        imagePickerController.sourceType = sourceType;
        [self presentViewController:imagePickerController animated:YES completion:^{}];
    }

    
}
#pragma mark -图片设置到控件
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    self.img.image=image;
    isneedchange=YES;
    

    /* 此处info 有六个值
     * UIImagePickerControllerMediaType; // an NSString UTTypeImage)
     * UIImagePickerControllerOriginalImage;  // a UIImage 原始图片
     * UIImagePickerControllerEditedImage;    // a UIImage 裁剪后图片
     * UIImagePickerControllerCropRect;       // an NSValue (CGRect)
     * UIImagePickerControllerMediaURL;       // an NSURL
     * UIImagePickerControllerReferenceURL    // an NSURL that references an asset in the AssetsLibrary framework
     * UIImagePickerControllerMediaMetadata    // an NSDictionary containing metadata from a captured photo
     */
    // 保存图片至本地，方法见下文
    
    
}
//获取总代理
- (AppDelegate *)appDelegate
{
    AppDelegate *delegate =  (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return delegate;
}

- (IBAction)doDone:(id)sender {
    
    NSString *localname=self.txtName.text;
    if (localname&&localname.length>0) {
        NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
        [defaults setValue:self.txtName.text forKey:MyLOCALNICKNAME];
        [defaults setObject:@"0" forKey:CHATWALLPAPER];
        [defaults setBool:true forKey:@"FIRSTLOGIN"];
        
        NSString *inputemail=self.email.text;
        if (inputemail&&[Tool isValidateEmail:inputemail]) {
              [defaults setValue:inputemail forKey:MyEmail];
            
            
            NSURL *url = [NSURL URLWithString:  [Tool Append:IMReasonableAPP witnstring:@"EmailAction"]];
            NSString * Apikey= IMReasonableAPPKey;
            NSString * phone=[[[[NSUserDefaults standardUserDefaults] stringForKey:XMPPREASONABLEJID] componentsSeparatedByString:@"@"] objectAtIndex:0];
            NSArray * emailarr=[[NSArray alloc] initWithObjects:inputemail, nil];
          
            NSDictionary *sendsms = [[NSDictionary alloc] initWithObjectsAndKeys:Apikey, @"apikey",phone,@"username",@"1",@"action",emailarr,@"email", nil];
            NSDictionary *sendsmsD = [[NSDictionary alloc] initWithObjectsAndKeys:sendsms, @"emaildata", nil];
            if ([NSJSONSerialization isValidJSONObject:sendsmsD])
            {
                NSError *error;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendsmsD options:NSJSONWritingPrettyPrinted error: &error];
                NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
                ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
                [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
                [request addRequestHeader:@"Accept" value:@"application/json"];
                [request setRequestMethod:@"POST"];
                [request setPostBody:tempJsonData];
//                [request setDelegate:self];
//                [request setDidFinishSelector:@selector(sendSmsSuc:)];
//                [request setDidFailSelector:@selector(sendSmsFaied:)];
//                [request startAsynchronous];
                [request startSynchronous];
                 error = [request error];
                if (!error) {
                    NSData *responsedata=[request responseData];
                    NSDictionary * dict=[Tool jsontodate:responsedata];
                    if (dict && ![[[dict objectForKey:@"EmailActionResult"] objectForKey:@"state"] isEqualToString:@"1"]) {
                        [self tipsMsg:@"lbTunknowerror" time:2];
                        return;
                    }
                    
                }else{
                    [self tipsMsg:@"lbTunknowerror" time:2];
                    return;
                }
            }

            
        }else{
            [self tipsMsg:@"邮箱格式不对" time:1];
            return;
        }
      
        
        
        
        if (isneedchange) {
            UIImage * img=self.img.image;
            if (img) {//选择了图片的情况下给用户设置头像
                
                if (![XMPPDao sharedXMPPManager].xmppStream.isConnected) {//判断是否连接到openfire服务器
                    [[XMPPDao sharedXMPPManager] connect];
                }
                
                NSString * filejidstrname=[[[defaults objectForKey:XMPPREASONABLEJID] componentsSeparatedByString:@"@"] objectAtIndex:0];
                [Tool saveFileToDoc:filejidstrname fileData:UIImagePNGRepresentation(img)];
                [[NSUserDefaults standardUserDefaults] setObject:[filejidstrname stringByAppendingString:@".png"] forKey:XMPPMYFACE];
                
                
                UIImage* tempimg=[Tool imageCompressForSize:img targetSize:CGSizeMake(300, 300)];
                NSData *imageData = UIImagePNGRepresentation(tempimg);
                NSString * base64data=[Tool NSdatatoBSString:imageData];
                NSString * jidstr=[defaults objectForKey:XMPPREASONABLEJID];
                [[XMPPDao sharedXMPPManager] SetUserPhoto:jidstr photo:base64data];
                
                
            }
            
        }
        
        [defaults synchronize];
        [self goNext];

    }else{
        
        [self tipsMsg:@"lbTusername" time:1];
    }
}

- (void)tipsMsg:(NSString *)msg time:(int)time{
  
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.removeFromSuperViewOnHide =YES;
    hud.mode = MBProgressHUDModeText;
    hud.labelText =NSLocalizedString(msg, msg);
    hud.minSize = CGSizeMake(132.f, 108.0f);
    [hud hide:YES afterDelay:time];
}



- (void)goNext
{
   // [AnimationHelper removeHUD];
  self.navigationItem.title=NSLocalizedString(@"lbTStile", nil);
    if (!self.isSetting) {
        MainViewController * mainview=[[MainViewController alloc] init];
        [self presentViewController:mainview animated:YES completion:nil];
    }

}


@end
