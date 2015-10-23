//
//  SelectUserViewController.m
//  IMReasonable
//
//  Created by apple on 15/2/2.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import "SelectUserViewController.h"
#import "AppDelegate.h"
#import "Tool.h"
#import "ChatViewController.h"
#import "GroupAddUserUIViewController.h"
#import "XMPPRoomDao.h"

@interface SelectUserViewController (){
    
    
   // UITableView *tableview;
    NSMutableArray * chatuserlist;
    
    
}

@end

@implementation SelectUserViewController
- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"SelectUserViewController");
    [super viewWillAppear:NO];
    if (self.flag) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.isGroup=YES;
    if (self.isGroup) {
        self.tableview.allowsMultipleSelectionDuringEditing=YES;
        self.tableview.editing=YES;
    }
    
    self.tableview.tableFooterView=[[UIView alloc]init];
    

  //  [self.view setBackgroundColor:[UIColor redColor]];
    [self initNavbutton];
   // chatuserlist=[[NSMutableArray alloc] init];
    [self initData];
    [self initControl];
    // Do any additional setup after loading the view.
}

- (void) initData
{
    
     // [chatuserlist removeAllObjects];
    chatuserlist=[IMReasonableDao getAllactiveUser];

    [self.tableview reloadData];


    
}
- (void) initNavbutton
{
    self.navigationItem.title=NSLocalizedString(@"lbSUTitle", nil);
    UIBarButtonItem * left=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(undo)];
    self.navigationItem.leftBarButtonItem=left;
    
   
    
    if (self.isGroup) {
        UIBarButtonItem * right=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(selectUser:)];
        self.navigationItem.rightBarButtonItem=right;
        
        self.navigationItem.rightBarButtonItem.enabled=NO;
        
        
    }
    
    
    
}

- (AppDelegate *)appDelegate
{
    AppDelegate *delegate =  (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //   delegate.chatHelerpDelegate = self;
    //    delegate.authloginDelegate=self;
    //     delegate.internetConnectDelegate=self;
    return delegate;
}
- (void)initControl
{
   // self.tableview  =[[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENWIHEIGHT)];
    self.tableview .delegate=self;
    self.tableview .dataSource=self;
   // [self.view addSubview:self.tableview ];
    
}

#pragma mark-表格的代理函数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return chatuserlist.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ChatListCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:CellIdentifier];
        
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
        }
        
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
        }
    }
    
    
    IMChatListModle *temp=[chatuserlist objectAtIndex:[indexPath row]];
    if (!self.isGroup) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
   
    
    UIImage * tempimg=[UIImage imageWithContentsOfFile:[Tool getFilePathFromDoc:temp.faceurl]];
    tempimg=tempimg?tempimg:[UIImage imageNamed:@"default"];
    cell.imageView.image=[Tool imageCompressForSize:tempimg targetSize:CGSizeMake(40, 40)];//[UIImage imageNamed:temp.faceurl];
    cell.imageView.layer.masksToBounds = YES;
    cell.imageView.layer.cornerRadius = 20;

    cell.textLabel.text=[[temp.jidstr componentsSeparatedByString:@"@"] objectAtIndex:0];
    
    cell.detailTextLabel.text=temp.localname;
    return cell;
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    
    
    if (!self.isGroup) {
        
        if (self.isAddGroupUser) {
            
            UIActionSheet * sheet;
//            "lbsuvaddtitle"="加群";
//            "lbsuvadd"="添加";
//            "lbsuvcancel"="取消";
            sheet=[[UIActionSheet alloc] initWithTitle: NSLocalizedString(@"lbsuvaddtitle",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"lbsuvcancel",nil) destructiveButtonTitle:NSLocalizedString(@"lbsuvadd",nil) otherButtonTitles:nil];
            sheet.tag=[indexPath row];
            sheet.actionSheetStyle=UIActionSheetStyleDefault;
            [sheet showInView:self.view];

            
        }else{
        
        IMChatListModle * temp=[chatuserlist objectAtIndex:[indexPath row]];
            
        ChatViewController *Cannotview=[[ChatViewController alloc] init];
        Cannotview.from=temp;
        Cannotview.isforward=self.isforward;
        Cannotview.forwardmssage=self.forwardmessage;
            
        temp.unreadcount=@"0";
        [chatuserlist replaceObjectAtIndex:[indexPath row] withObject:temp];
        Cannotview.hidesBottomBarWhenPushed=YES;
        self.flag=true;
        
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
        backItem.title = NSLocalizedString(@"lbchats",nil);
        self.navigationItem.backBarButtonItem = backItem;
        [self.navigationController pushViewController:Cannotview animated:NO];
            
        }
        
    }else{
         self.navigationItem.rightBarButtonItem.enabled=YES;
    
    }
    
    
    
    
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
           // [Tool alert:@"添加成功"];
            
            IMChatListModle * temp=[chatuserlist objectAtIndex:actionSheet.tag];
           // [[XMPPRoomDao sharedXMPPManager] InviteUser:temp.jidstr subject:self.from.localname];//邀请好友加入群里
            [[XMPPDao sharedXMPPManager] addUserToRoom:self.from.jidstr userjidstr:temp.jidstr roomname:self.from.localname];
            [IMReasonableDao addRoomUser:self.from.jidstr userjidstr:temp.jidstr role:@"0"];//把人员添加到数据库
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AddGroupUser"
                                                                object:self];

            [self dismissViewControllerAnimated:NO completion:nil];
            
            
        }break;
            
        default:
            break;
            
            
    }
    
    
}

- ( void )tableView:( UITableView *)tableView didDeselectRowAtIndexPath:( NSIndexPath *)indexPath
{
    
    if (![[tableView indexPathsForSelectedRows] count]) {
          self.navigationItem.rightBarButtonItem.enabled=NO;
    }
   // NSLog(@"dsa");
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)undo {
    
    [self dismissViewControllerAnimated:NO completion:nil];
}
- (void)selectUser:(UIBarButtonItem*) btn{
    
    NSMutableArray * selectUser=[[NSMutableArray alloc]init];
    
    NSArray *selectRow=[self.tableview indexPathsForSelectedRows];
    for (NSIndexPath *index in selectRow) {
        
          IMChatListModle * temp=[chatuserlist objectAtIndex:[index row]];
        [selectUser addObject:temp];
        
    }
    //把数据回传到页面
    [self.selectUserdelegate SelectUserData:selectUser withsubject:self.tempsubject];
    
    [self dismissViewControllerAnimated:NO completion:nil];
  
}

@end

