//
//  ChatListViewController.m
//  IMReasonable
//
//  Created by apple on 14/11/21.
//  Copyright (c) 2014年 Reasonable. All rights reserved.
//

#import "ChatListViewController.h"
#import "ChatListTableViewCell.h"
#import "ImageHelp.h"
#import "ChatViewController.h"
#import "Tool.h"
#import "MessageModel.h"
#import "TitleView.h"
#import "SelectUserViewController.h"
#import "XMPPRoomDao.h"
#import "UIImageView+WebCache.h"
#import "SpreadMailViewController.h"

@interface ChatListViewController ()
{
    UITableView *tableview;
    
    //用户数据
    UIImageView * userinterface;
    
    NSMutableArray * chatuserlist;
    BOOL isConnectInternet;
    //进度旋转轮
    UIActivityIndicatorView * at;
    
    NSMutableArray *filterData;
    //搜索框
    UISearchDisplayController *searchDisplayController;
    
}

@end

@implementation ChatListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //添加聊天代理
    [XMPPDao sharedXMPPManager].chatHelerpDelegate=self;
    [self initNavbutton];
    [self initData];
    [self initControl];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeItem)
                                                 name:@"CHANGEITEM"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(localUserChange:)
                                                 name:@"CONNECTSCHANGE"
                                               object:nil];
    
}

-(void)localUserChange:(NSNotification *)nt{
    NSDictionary * dict=nt.userInfo;
    if ([[dict objectForKey:@"action"] isEqualToString:@"1"]) {// 开启联系人扫描动画
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [at startAnimating];
            userinterface.hidden=YES;
            self.navigationItem.title=NSLocalizedString(@"lblookforfriend",nil);
        });
        
        
        
    }else if([[dict objectForKey:@"action"] isEqualToString:@"2"]){ //停止动画 刷新数据
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [at stopAnimating];
            userinterface.hidden=NO;
            self.navigationItem.title=NSLocalizedString(@"lbchats",nil);
        });
        
    }
    
}

- (void)changeItem
{
    [self initData];
}

- (void) initData
{
    dispatch_async(dispatch_get_global_queue(2, 0), ^{
        
        
        chatuserlist=[IMReasonableDao getChatlistModle];
        [self getfilterData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIView * tempview=[self.view viewWithTag:9999];
            if (chatuserlist.count) {
                
                tempview.hidden=YES;
            }else{
                tempview.hidden=NO;
            }
            [tableview reloadData];
        });
        
        
    });
    UIView * tempview=[self.view viewWithTag:9999];
    if (chatuserlist.count) {
        
        tempview.hidden=YES;
    }else{
        tempview.hidden=NO;
    }
    
    
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [XMPPDao sharedXMPPManager].chatHelerpDelegate=self;
    [self initNavbutton];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self initData];
}
//联系人点击
- (void) userinterface:(UIButton *) btn
{
    NSLog(@"用户头像被点击");
    
    [[XMPPDao sharedXMPPManager] getAllMyRoom];
    
    
    
    NSString *jidstr = [[[[NSUserDefaults standardUserDefaults] stringForKey:XMPPREASONABLEJID] componentsSeparatedByString:@"@"] objectAtIndex:0] ;
    UIAlertView * alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"lbclvuser",nil) message:jidstr delegate:self cancelButtonTitle:nil    otherButtonTitles:NSLocalizedString(@"lbclvok",nil), nil];
    [alert show];
}

#pragma mark-创建导航栏上得按钮
- (void) initNavbutton
{
    
    self.navigationItem.title=NSLocalizedString(@"lbchats",nil);;
    NSString * imagename=[[NSUserDefaults standardUserDefaults] objectForKey:XMPPMYFACE];
    UIView * btnview=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    UIImage * tempimg=[UIImage imageWithContentsOfFile:[Tool getFilePathFromDoc:imagename]];
    userinterface = [[UIImageView alloc] initWithImage:tempimg?tempimg:[UIImage imageNamed:@"default"]];
    userinterface.frame = CGRectMake(0, 0, 32, 32);
    //隐藏圆角半径以外的内容
    userinterface.layer.masksToBounds = YES;
    //设置圆角半径
    userinterface.layer.cornerRadius = 16;
    
    
    at=[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    at.activityIndicatorViewStyle= UIActivityIndicatorViewStyleGray;
    
    //用户头像按钮
    UIButton *leftbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftbtn.frame =CGRectMake(0, 0, 32, 32);
    leftbtn.backgroundColor=[UIColor clearColor];
    [leftbtn addTarget: self action: @selector(userinterface:) forControlEvents: UIControlEventTouchUpInside];
    [btnview addSubview:userinterface];
    [btnview addSubview:at];
    [btnview addSubview:leftbtn];
    UIBarButtonItem* leftitem=[[UIBarButtonItem alloc]initWithCustomView:btnview];
    self.navigationItem.leftBarButtonItem=leftitem;
    //右侧按钮，选择联系人
    UIBarButtonItem * right=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(Selectfriend:)];
    self.navigationItem.rightBarButtonItem=right;
}

- (void) Selectfriend:(UIBarButtonItem *) btn
{
    NSLog(@"Selectfriend");
    SelectUserViewController *selectview = [[SelectUserViewController alloc]initWithNibName:@"SelectUserViewController" bundle:nil];
    selectview.flag=false;
    UINavigationController * nvisecond=[[UINavigationController alloc] init];
    [nvisecond addChildViewController:selectview];
    [self presentViewController:nvisecond animated:YES completion:nil];
}

#pragma mark-初始化Control
- (void)initControl
{
    
    self.edgesForExtendedLayout = UIRectEdgeNone ;
    tableview =[[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENWIHEIGHT-49-64)];
    tableview.delegate=self;
    tableview.dataSource=self;
    
    
    // 添加搜索栏
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width
                                                                           , 44)];
    searchBar.barTintColor=[UIColor whiteColor];
    searchBar.placeholder =NSLocalizedString(@"lbfsearch",nil);    searchBar.delegate=self;
    tableview.tableHeaderView = searchBar;
    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    searchDisplayController.delegate=self;
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;
    
    
    
    UIRefreshControl * ref=[[UIRefreshControl alloc] init];
    ref.tintColor = [UIColor grayColor];
    ref.attributedTitle = [[NSAttributedString alloc]initWithString:NSLocalizedString(@"msgRef",nil)];
    [ref addTarget:self action:@selector(RefreshViewControlEventValueChanged:) forControlEvents:UIControlEventValueChanged];
    [tableview addSubview:ref];
    
    tableview.tableFooterView = [[UIView alloc]init];//设置不要显示多余的行;
    
    if (![chatuserlist count]) {
        
        CGRect rect=CGRectMake(SCREENWIDTH*0.1, 0, SCREENWIDTH*0.8, SCREENWIHEIGHT-49-64);
        UILabel *backImageView=[[UILabel alloc]initWithFrame:rect];
        backImageView.contentMode=UIViewContentModeScaleAspectFit;
        backImageView.tag=9999;
        backImageView.text= NSLocalizedString(@"lbclvNoMan",nil);//@"No man is an island.You are alone at TalkKing, invite your friends to connect at TalkKing? ";
        backImageView.textAlignment=NSTextAlignmentCenter;
        backImageView.textColor=[UIColor grayColor];
        backImageView.lineBreakMode = NSLineBreakByWordWrapping;
        backImageView.numberOfLines = 0;
        backImageView.hidden=YES;
        [self.view addSubview:backImageView];
        tableview.backgroundColor=[UIColor clearColor];
        
    }
    [self.view addSubview:tableview];
    
}



-(void)RefreshViewControlEventValueChanged:(UIRefreshControl *)ref
{
    if (ref.refreshing) {
        ref.attributedTitle = [[NSAttributedString alloc]initWithString:NSLocalizedString(@"msgRefing",nil)];
        [self initData];
        [self performSelector:@selector(RefTableview:) withObject:ref afterDelay:1];
    }
}

- (void) RefTableview:(UIRefreshControl *)ref
{
    [ref endRefreshing];
    ref.attributedTitle = [[NSAttributedString alloc]initWithString:NSLocalizedString(@"msgRef",nil)];
    [tableview reloadData];
}




//
//#pragma mark-收到新消息
//#pragma mark-登陆成功
- (void)isSuccLogin:(BOOL)flag
{
    NSLog(@"登陆成功");
}

#pragma mark- 表格代理是需要实现的方法

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  chatuserlist.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ChatListCell";
    
    //从缓存中获取
    ChatListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    //如果还未缓存过
    if (cell == nil)
    {
        cell = [[ChatListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                            reuseIdentifier:CellIdentifier];
        
        //去除分割线左边出现的空格
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
        
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
    }
    cell.backgroundColor=[UIColor clearColor];
    
    IMChatListModle *temp=[chatuserlist objectAtIndex:[indexPath row]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIImage * tempimg=[UIImage imageWithContentsOfFile:[Tool getFilePathFromDoc:temp.faceurl]];
    
    NSString *path=[Tool Append:IMReasonableAPPImagePath witnstring:temp.faceurl];
    NSString * defaultphoto=@"default";
    if ([temp.isRoom isEqualToString:@"1"]) {
        defaultphoto=@"GroupChatRound";
    }else{
        cell.messagecount.backgroundColor=[UIColor colorWithRed:0 green:0.47 blue:1 alpha:1];
    }
    
    [cell.userphoto sd_setImageWithURL:[NSURL URLWithString:path] placeholderImage:tempimg?tempimg:[UIImage imageNamed:defaultphoto]];//@"default"]];
    
    cell.username.text=temp.localname?temp.localname:[[temp.jidstr componentsSeparatedByString:@"@"] objectAtIndex:0];
    NSString *msg=temp.messagebody.body;
    if ([temp.messagebody.type isEqualToString:@"img"]||[temp.messagebody.type isEqualToString:@"locimg"]) {
        msg=@"[image]";
    }
    if ([temp.messagebody.type isEqualToString:@"voice"]||[temp.messagebody.type isEqualToString:@"locimg"]) {
        msg=@"[voice]";
    }
    cell.message.text=msg;
    cell.messagetime.text=NSLocalizedString(temp.messagebody.date,temp.messagebody.date);
    //是否显示消息条数
    if ([temp.messageCount integerValue]>0) {
        cell.messagecount.hidden=NO;
        if ([temp.isRoom isEqualToString:@"1"] && [temp.isNeedTip isEqualToString:@"0"]) {
            cell.messagecount.backgroundColor=[UIColor lightGrayColor];
        }
        cell.messagecount.text=[temp.messageCount integerValue]<99?temp.messageCount:@"99+";
    }else
    {
        cell.messagecount.hidden=YES;
        
    }
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    IMChatListModle * temp=[chatuserlist objectAtIndex:[indexPath row]];
    
    if ([temp.accouttype isEqualToString:@"9999"]) {
        SpreadMailViewController * spmail=[[SpreadMailViewController alloc] init];
        spmail.from=temp;
        spmail.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:spmail animated:NO];
    }else{
        
        [searchDisplayController.searchBar resignFirstResponder];
        ChatViewController *Cannotview=[[ChatViewController alloc] init] ;
        self.tempmsg=temp.jidstr;
        Cannotview.from=temp;
        temp.messageCount=@"0";
        [chatuserlist replaceObjectAtIndex:[indexPath row] withObject:temp];
        Cannotview.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:Cannotview animated:NO];
        
    }
    
    
    
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 63;
    
}


//表格删除按钮的实现
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  UITableViewCellEditingStyleDelete;
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TRUE;
}
//修改删除按钮的标题
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NSLocalizedString(@"lbclvdelete",nil);
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle ==UITableViewCellEditingStyleDelete) {//如果编辑样式为删除样式
        if (indexPath.row<[chatuserlist count]) {
            
            IMChatListModle *temp=[chatuserlist objectAtIndex:[indexPath row]];
            
            if ([temp.isRoom isEqualToString:@"1"]&&[temp.isimrea isEqualToString:@"1"]) {//是群且不是群成员的时候删除就是清除数据
                //真实的删除本地数据库数据
                if ([IMReasonableDao deleteUser:temp.jidstr]) {//删除成员并删除消息
                    [chatuserlist removeObjectAtIndex:indexPath.row];//移除数据源的数据
                    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];//移除tableView中的数据
                }
                
            }else{
                if ([IMReasonableDao updateNotShow:temp.jidstr]) {
                    [chatuserlist removeObjectAtIndex:indexPath.row];//移除数据源的数据
                    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];//移除tableView中的数据
                }
            }
            
            
            
        }
    }
    
}

#pragma mark-ChatHelperdelegate
-(void)receiveNewMessage:(IMMessage *)message isFwd:(BOOL) isfwd
{
    [self initData];
    dispatch_async(dispatch_get_main_queue(), ^{
        [tableview reloadData];
    });
    
    
    
}
- (void) isSuccSendMessage:(IMMessage *)msg issuc:(BOOL) flag;
{
    
}
- (void) userStatusChange:(XMPPPresence *)presence
{
    
    
    if (presence==nil) {
        [self initData];
    }
}

#pragma mark - searchdelegate

- (BOOL) searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self getfilterData];
    return  YES;
}

- (void)getfilterData{
    
    [filterData removeAllObjects];
    
    NSString * search=searchDisplayController.searchBar.text;
    if (search.length>0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"localname contains[c] %@ or phonenumber contains[c] %@ ",search,search];//用于过滤
        chatuserlist = [NSMutableArray arrayWithArray:[chatuserlist filteredArrayUsingPredicate:predicate]];
    }
    else{
        chatuserlist=[IMReasonableDao getChatlistModle];
        [tableview reloadData];
    }
    
    
}

- (BOOL) searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    //当scope改变时调用
    return YES;
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    
    chatuserlist=[IMReasonableDao getChatlistModle];
    [tableview reloadData];
}

#pragma mark-didReceiveMemoryWarning
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLayoutSubviews
{
    //去除分割线左边出现的空格
    if ([tableview respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableview setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([tableview respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableview setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CHANGEITEM" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CONNECTSCHANGE" object:nil];
    
}

@end
