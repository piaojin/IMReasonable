
#import "AppDelegate.h"
#import "Reachability.h"
#import "MBProgressHUD.h"
#import "MainViewController.h"
#import "DeviceHard.h"
#import "XMPPMessageCarbons.h"
#import "AnimationHelper.h"
#import "FirstViewController.h"
#import "SendViewController.h"
#import "ThirdViewController.h"
#import "Tool.h"
#import "IMReasonableDao.h"
#import "ThirdViewController.h"
#import "DesHelper.h"



#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@implementation AppDelegate

@synthesize window;






- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    NSLog(@"%@",launchOptions);
    
   
    
    
    UIApplication *app = [UIApplication sharedApplication];
     NSString *docpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    [[NSFileManager  defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@/%@",docpath,@"voice"] withIntermediateDirectories:YES attributes:nil error:nil];



    
    if ([app respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {//ios8
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge
                                                                                             |UIRemoteNotificationTypeSound
                                                                                             |UIRemoteNotificationTypeAlert)
                                                                                 categories:nil];
        [app registerUserNotificationSettings:settings];
        //[app registerForRemoteNotifications];
    } else {//ios7
        [app registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge
                                                         |UIRemoteNotificationTypeSound
                                                         |UIRemoteNotificationTypeAlert)];
    }
    
 
    self.userdata=[[loginUserData alloc]init];
    xmppManager=[XMPPDao sharedXMPPManager];

  
    
    NSBundle * budle=[NSBundle mainBundle];
    NSString * path =[budle pathForResource:@"CountryList" ofType:@"plist"];
    NSMutableArray* allcountrycode=[[NSMutableArray alloc] initWithContentsOfFile:path];
    NSLocale *currentLocale = [NSLocale currentLocale];
    NSString * countrycode=[currentLocale objectForKey:NSLocaleCountryCode];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"Code == %@", countrycode];
    NSArray *filteredArray = [allcountrycode filteredArrayUsingPredicate:predicate];
    
    if (filteredArray.count>0) {
        NSDictionary * dict=[filteredArray objectAtIndex:0];
        self.userdata.countryname=NSLocalizedString([dict objectForKey:@"Key"],nil);
        NSString *vaule=[dict objectForKey:@"Vaule"];
         self.userdata.countrycode=vaule;
        self.userdata.countrySX=countrycode;
    }

  
  
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    

    
    

    

    
    

   
    
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    bool isFirst=[defaults boolForKey:@"FIRSTLOGIN"];
    NSString *myJID = [defaults stringForKey:XMPPREASONABLEJID];
    NSString *myPassword = [defaults stringForKey:XMPPREASONABLEPWD];
    
//     ThirdViewController *firstview = [[ThirdViewController alloc]initWithNibName:@"ThirdViewController" bundle:nil];
//     self.window.rootViewController=firstview;
//     [self.window setBackgroundColor:[UIColor whiteColor]];
    
    if (isFirst||(myJID.length>0&&myPassword.length>0)) {
       //ThirdViewController *firstview = [[ThirdViewController alloc]initWithNibName:@"ThirdViewController" bundle:nil];
       [IMReasonableDao initIMReasonableTable];
        MainViewController *firstview = [[MainViewController alloc]init];
        self.window.rootViewController=firstview;
    }else{
        FirstViewController * first=[[FirstViewController alloc] init];
        self.window.rootViewController=first;
    }
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}


-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"执行拉函数");
    
    NSString* token = [NSString stringWithFormat:@"%@",deviceToken];
    token= [token substringFromIndex:1];
    token=[token substringToIndex:token.length-1];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    [defaults setValue:token forKey:@"DeviceToken"];
    [defaults synchronize];
    
}
///Token值获取失败的时候走的是这个方法
-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    
    NSLog(@"%@",error);
}
///应用程序处在打开状态，且服务器有推送消息过来时，以及通过推送打开应用程序，走的是这个方法
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{

    
    NSLog(@"%@",userInfo);
  
    
    if ([[userInfo objectForKey:@"aps"] objectForKey:@"alert"]!=NULL)
    {
        
        //NSString * message=[userInfo objectForKey:@"msg"];
       // DDXMLElement *dd=[[DDXMLElement alloc]initWithXMLString:message error:nil];
//        XMPPMessage *msg=[[XMPPMessage alloc] initWithXMLString:message error:nil];
//        [[XMPPDao sharedXMPPManager] doMessage:msg];
        [[XMPPDao sharedXMPPManager] setapplicationIconBadgeNumber];
       
      //  NSLog(@"%@-%@",msg,msg.body);
        
    }

}




- (void)dealloc
{
  
    
    
    
}





////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UIApplicationDelegate-进入后台
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
    
    [[XMPPDao sharedXMPPManager] disconnect];
    [[XMPPDao sharedXMPPManager] setapplicationIconBadgeNumber];
    
//    if ([application respondsToSelector:@selector(setKeepAliveTimeout:handler:)])
//    {
//        [application setKeepAliveTimeout:600 handler:^{
//            
//            NSLog(@"ad--");
//        }];
//    }

    
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"applicationWillEnterForeground");
    //[self disconnect];
   // [self connect];
  //  [self goOnline];
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    NSLog(@"applicationWillTerminate");
   // [self goOffline];
   // [self teardownStream];
}






@end
