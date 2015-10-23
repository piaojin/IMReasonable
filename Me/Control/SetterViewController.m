//
//  SetterViewController.m
//  IMReasonable
//
//  Created by apple on 15/6/17.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import "SetterViewController.h"
#import "XMPPDao.h"
#import "ThirdViewController.h"
#import "WallPaperViewController.h"
#import "UIColor+Hex.h"
#import "FirstViewController.h"

#define FOOTERVIEW_HEIGTH 44

@interface SetterViewController ()
{
    
    UITableView * _tableview;
    
    NSMutableArray *_datalist;
    NSString * _docSize;

}

@end

@implementation SetterViewController

- (void)viewDidLoad {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadtableview)
                                                 name:@"NETCHANGE"
                                               object:nil];
    

    _docSize =[Tool getDocSize];
   
    [super viewDidLoad];
    [self initViewControl];
    [self initNav];
    [self initData];
  
}

- (void)reloadtableview{
    [_tableview reloadData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_tableview reloadData];
    // [XMPPDao sharedXMPPManager].internetConnectDelegate=self;
}

- (void)initNav{
  self.navigationItem.title=NSLocalizedString(@"lbsetter",nil);
}


- (void)initData{
 
    NSArray * section1=[[NSArray alloc] initWithObjects:@"lbsabout", nil];
    NSArray * section2=[[NSArray alloc] initWithObjects:@"lbsprofile", @"lbwallpaper",nil];
    NSArray * section3=[[NSArray alloc] initWithObjects:@"lbsnetstate", nil];
    NSArray * section4=[[NSArray alloc] initWithObjects:@"lbsusage", nil];
    _datalist=[[NSMutableArray alloc] initWithObjects:section1,section2,section3,section4, nil];

}

- (void)initViewControl{

    self.edgesForExtendedLayout = UIRectEdgeNone ;
    _tableview =[[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENWIHEIGHT-49-64)];
    _tableview.delegate=self;
    _tableview.dataSource=self;
    //退出按钮
    UIButton *footerButton=[[UIButton alloc] init];
    footerButton.titleLabel.font=[UIFont systemFontOfSize:20.0];
    [footerButton setTitle:NSLocalizedString(@"SIGN_OUT", nil) forState:UIControlStateNormal];
    footerButton.frame=CGRectMake(0, 0, 0, FOOTERVIEW_HEIGTH);
    [footerButton addTarget:self action:@selector(logout:) forControlEvents:UIControlEventTouchDown];
    [footerButton setBackgroundImage:[UIImage imageNamed:@"red_1"] forState:UIControlStateNormal];
    [footerButton setBackgroundImage:[UIImage imageNamed:@"red_2"] forState:UIControlStateHighlighted];
    _tableview.tableFooterView = footerButton;
//    _tableview.tableFooterView = [[UIView alloc]init];//设置不要显示多余的行;
    
    [self.view addSubview:_tableview];
}

//退出登录
-(void)logout:(UIButton *)button{
    //清除用户数据
    NSUserDefaults* userDefaults=[NSUserDefaults standardUserDefaults];
    //设置退出登录为真
    [userDefaults setBool:true forKey:ISSIGN_OUT];
    //清除手机号码和密码
    [userDefaults removeObjectForKey:XMPPREASONABLEJID];
    [userDefaults removeObjectForKey:XMPPREASONABLEPWD];
    [userDefaults setBool:false forKey:@"FIRSTLOGIN"];
    [userDefaults synchronize];
    FirstViewController* firstViewController=[[FirstViewController alloc] init];
    [self presentViewController:firstViewController animated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _datalist.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[_datalist objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString * Idetify=@"asd";
    
    NSArray * data=[_datalist objectAtIndex:[indexPath section]];
    
    UITableViewCell *cell;
    NSInteger section=[indexPath section];
    if (section<2) {
        cell= [tableView dequeueReusableCellWithIdentifier:Idetify];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Idetify];
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        }
    }else if(section==2){
        cell= [tableView dequeueReusableCellWithIdentifier:@"NETWORK"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"NETWORK"];
           // cell.selectionStyle=UITableViewCellAccessoryNone;
        }
        if ([XMPPDao sharedXMPPManager].isConnectInternet) {
            cell.detailTextLabel.text=NSLocalizedString(@"lbsnetstateconnect",nil);
             cell.detailTextLabel.textColor=[UIColor greenColor];
        }else{
           cell.detailTextLabel.text=NSLocalizedString(@"lbsnetstatedisconnect",nil);
           cell.detailTextLabel.textColor=[UIColor redColor];
        }
    }else{
        
        cell= [tableView dequeueReusableCellWithIdentifier:@"NETWORK"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"NETWORK"];
           // cell.selectionStyle=UITableViewCellAccessoryNone;
        }
        
        cell.detailTextLabel.text=_docSize;
        
        
    
    }
   
     cell.selectionStyle=UITableViewCellAccessoryNone;
    cell.textLabel.text=NSLocalizedString([data objectAtIndex:[indexPath row]],nil);
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    NSInteger section=[indexPath section];
    if (section==0) {
        
        NSString * ver=[NSString stringWithFormat:@"V %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
        [Tool alert:ver];
        
    } else if (section==1){
        
        if (indexPath.row==0) {
            ThirdViewController *firstview = [[ThirdViewController alloc]initWithNibName:@"ThirdViewController" bundle:nil];
            firstview.isSetting=true;
            [self.navigationController pushViewController:firstview animated:YES];
        }else {
            WallPaperViewController * wallpaper=[[WallPaperViewController alloc] init];
               wallpaper.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:wallpaper animated:YES];
        }
       
    }
    
}


//#pragma mark-网络代理
//
////- (void)isConnectToInternet:(BOOL)isConnet{
////    [_tableview reloadData];
////}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NETCHANGE" object:nil];
}
@end
