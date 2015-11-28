//
//  ChatListViewController.m
//  IMReasonable
//
//  Created by apple on 14/11/21.
//  Copyright (c) 2014年 Reasonable. All rights reserved.
//

#import "MailTableViewCell.h"
#import "SpreadMailModel.h"
#import "InviteAllFriendsController.h"
#import "PJNetWorkHelper.h"
#import "MJExtension.h"
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
#import "AnimationHelper.h"
#import "ContactsTool.h"

@interface ChatListViewController () {
    UITableView* tableview;

    //用户数据
    UIImageView* userinterface;

    //    NSMutableArray * chatuserlist;
    BOOL isConnectInternet;
    //进度旋转轮
    UIActivityIndicatorView* at;

    NSMutableArray* filterData;
    //搜索框
    UISearchDisplayController* searchDisplayController;
}

//邮箱
@property(nonatomic,strong)MailTableViewCell *eMailCell;
//邀请按钮
@property (nonatomic, strong) UIButton* inviteButton;
//提示语
@property (nonatomic, strong) UILabel* backImageView;
@property (nonatomic, strong) NSMutableArray* chatuserlist;

@end

@implementation ChatListViewController

-(MailTableViewCell *)eMailCell{
    if(_eMailCell==nil){
        
        _eMailCell=[MailTableViewCell MailCell];
    }
    return _eMailCell;
}

- (UIButton*)inviteButton
{
    if (_inviteButton == nil) {

        NSString* inviteText = NSLocalizedString(@"INVITE_FOR_FREE", nil);
        CGSize titleSize = [inviteText sizeWithFont:[UIFont systemFontOfSize:18.0] constrainedToSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
        _inviteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_inviteButton.layer setMasksToBounds:YES];
        [_inviteButton.layer setCornerRadius:10.0];
        [_inviteButton setTitle:inviteText forState:UIControlStateNormal];
        CGRect inviteButtonRect = CGRectMake(0, 0, titleSize.width + 16.0, titleSize.height + 10);
        _inviteButton.frame = inviteButtonRect;
        [_inviteButton setBackgroundImage:[Tool imageWithColor:[UIColor blueColor]] forState:UIControlStateNormal];
        [_inviteButton setBackgroundImage:[Tool imageWithColor:[UIColor orangeColor]] forState:UIControlStateHighlighted];
        [_inviteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _inviteButton.frame = inviteButtonRect;
        _inviteButton.center = CGPointMake(self.backImageView.center.x, self.backImageView.center.y + 46);
        [_inviteButton addTarget:self action:@selector(Invite) forControlEvents:UIControlEventTouchUpInside];
    }
    return _inviteButton;
}

- (UILabel*)backImageView
{
    if (_backImageView == nil) {

        CGRect rect = CGRectMake(SCREENWIDTH * 0.1, 0, SCREENWIDTH * 0.8, SCREENWIHEIGHT - 49 - 64);
        _backImageView = [[UILabel alloc] initWithFrame:rect];
        _backImageView.contentMode = UIViewContentModeScaleAspectFit;
        _backImageView.tag = 9999;
        _backImageView.text = NSLocalizedString(@"lbclvNoMan", nil);
        _backImageView.textAlignment = NSTextAlignmentCenter;
        _backImageView.textColor = [UIColor grayColor];
        _backImageView.lineBreakMode = NSLineBreakByWordWrapping;
        _backImageView.numberOfLines = 0;
        _backImageView.hidden = YES;
        _backImageView.userInteractionEnabled = NO;
    }
    return _backImageView;
}

- (NSMutableArray*)chatuserlist
{
    if (_chatuserlist == nil) {

        _chatuserlist = [IMReasonableDao getChatlistModle];
    }
    return _chatuserlist;
}

//收到清除数据后的通知
- (void)reloadData:(NSNotification*)notification
{
    for (IMChatListModle* model in self.chatuserlist) {

        [IMReasonableDao updateNotShow:model.jidstr];
    }
    [_chatuserlist removeAllObjects];
    [tableview reloadData];
    [Tool removeVoiceAndImg];
    [[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_CACHE object:nil];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [self.view addSubview:self.backImageView];
    [self.view addSubview:self.inviteButton];
    NSLog(@"reloadData");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //添加聊天代理
    [XMPPDao sharedXMPPManager].chatHelerpDelegate = self;
    [self initNavbutton];
    [self initData];
    [self initControl];

    if ([self respondsToSelector:@selector(reloadData:)]) {

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reloadData:)
                                                     name:RELOAD_CHETLIST
                                                   object:nil];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeItem)
                                                 name:@"CHANGEITEM"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(localUserChange:)
                                                 name:@"CONNECTSCHANGE"
                                               object:nil];
}

- (void)localUserChange:(NSNotification*)nt
{
    NSDictionary* dict = nt.userInfo;
    if ([[dict objectForKey:@"action"] isEqualToString:@"1"]) { // 开启联系人扫描动画

        dispatch_async(dispatch_get_main_queue(), ^{
            [at startAnimating];
            userinterface.hidden = YES;
            self.navigationItem.title = NSLocalizedString(@"lblookforfriend", nil);
        });
    }
    else if ([[dict objectForKey:@"action"] isEqualToString:@"2"]) { //停止动画 刷新数据

        dispatch_async(dispatch_get_main_queue(), ^{
            [at stopAnimating];
            userinterface.hidden = NO;
            self.navigationItem.title = NSLocalizedString(@"lbchats", nil);
        });
    }
}

- (void)changeItem
{
    [self initData];
}

- (void)initData
{
    dispatch_async(dispatch_get_global_queue(2, 0), ^{

        self.chatuserlist = [IMReasonableDao getChatlistModle];
        [self getfilterData];

        dispatch_async(dispatch_get_main_queue(), ^{
            UIView* tempview = [self.view viewWithTag:9999];
            if (self.chatuserlist.count) {

                tempview.hidden = YES;
            }
            else {
                tempview.hidden = NO;
            }
            [tableview reloadData];
        });

    });
    UIView* tempview = [self.view viewWithTag:9999];
    if (self.chatuserlist.count) {

        tempview.hidden = YES;
    }
    else {
        tempview.hidden = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [XMPPDao sharedXMPPManager].chatHelerpDelegate = self;
    [self initNavbutton];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self initData];
}
//联系人点击
- (void)userinterface:(UIButton*)btn
{
    NSLog(@"用户头像被点击");

    [[XMPPDao sharedXMPPManager] getAllMyRoom];

    NSString* jidstr = [[[[NSUserDefaults standardUserDefaults] stringForKey:XMPPREASONABLEJID] componentsSeparatedByString:@"@"] objectAtIndex:0];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"lbclvuser", nil) message:jidstr delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"lbclvok", nil), nil];
    [alert show];
}

#pragma mark -创建导航栏上得按钮
- (void)initNavbutton
{

    self.navigationItem.title = NSLocalizedString(@"lbchats", nil);
    ;
    NSString* imagename = [[NSUserDefaults standardUserDefaults] objectForKey:XMPPMYFACE];
    UIView* btnview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    UIImage* tempimg = [UIImage imageWithContentsOfFile:[Tool getFilePathFromDoc:imagename]];
    userinterface = [[UIImageView alloc] initWithImage:tempimg ? tempimg : [UIImage imageNamed:@"default"]];
    userinterface.frame = CGRectMake(0, 0, 32, 32);
    //隐藏圆角半径以外的内容
    userinterface.layer.masksToBounds = YES;
    //设置圆角半径
    userinterface.layer.cornerRadius = 16;
    at = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    at.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    //用户头像按钮
    UIButton* leftbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftbtn.frame = CGRectMake(0, 0, 32, 32);
    leftbtn.backgroundColor = [UIColor clearColor];
    [leftbtn addTarget:self action:@selector(userinterface:) forControlEvents:UIControlEventTouchUpInside];
    [btnview addSubview:userinterface];
    [btnview addSubview:at];
    [btnview addSubview:leftbtn];
    UIBarButtonItem* leftitem = [[UIBarButtonItem alloc] initWithCustomView:btnview];
    self.navigationItem.leftBarButtonItem = leftitem;
    //右侧按钮，选择联系人
    UIBarButtonItem* right = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(Selectfriend:)];
    self.navigationItem.rightBarButtonItem = right;
}

- (void)Selectfriend:(UIBarButtonItem*)btn
{
    NSLog(@"Selectfriend");
    SelectUserViewController* selectview = [[SelectUserViewController alloc] initWithNibName:@"SelectUserViewController" bundle:nil];
    selectview.flag = false;
    UINavigationController* nvisecond = [[UINavigationController alloc] init];
    [nvisecond addChildViewController:selectview];
    [self presentViewController:nvisecond animated:YES completion:nil];
}

#pragma mark -初始化Control
- (void)initControl
{

    self.edgesForExtendedLayout = UIRectEdgeNone;
    tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENWIHEIGHT - 49 - 64)];
    tableview.delegate = self;
    tableview.dataSource = self;
    // 添加搜索栏
    UISearchBar* searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    searchBar.barTintColor = [UIColor whiteColor];
    searchBar.placeholder = NSLocalizedString(@"lbfsearch", nil);
    searchBar.delegate = self;
    tableview.tableHeaderView = searchBar;
    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    searchDisplayController.delegate = self;
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;
    UIRefreshControl* ref = [[UIRefreshControl alloc] init];
    ref.tintColor = [UIColor grayColor];
    ref.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"msgRef", nil)];
    [ref addTarget:self action:@selector(RefreshViewControlEventValueChanged:) forControlEvents:UIControlEventValueChanged];
    [tableview addSubview:ref];

    tableview.tableFooterView = [[UIView alloc] init]; //设置不要显示多余的行;

    [self.view addSubview:tableview];
    [self initPrompt];
}

- (void)initPrompt
{
    if (self.chatuserlist.count <= 0) {

        [self.view addSubview:self.backImageView];
        [self.view addSubview:self.inviteButton];
        tableview.backgroundColor = [UIColor clearColor];
    }
    else {
        [self.inviteButton removeFromSuperview];
        [self.backImageView removeFromSuperview];
    }
}

/**
 *  邀请开始
 *
 *  @param ref <#ref description#>
 */

//免费邀请好友按钮点击事件
- (void)Invite
{
    UIActionSheet* inviteSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"INVITE_FRIENDS", nil)
                                                             delegate:(id)self
                                                    cancelButtonTitle:NSLocalizedString(@"lbsuvcancel", nil)
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"INVITE_MANY_PEOPLE", nil), NSLocalizedString(@"INVITE_ALL_PEOPLE", nil),
                                                    nil];
    [inviteSheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)InvitationFriendsForHeightSys
{
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"lbinvitation", nil)
                                                                             message:NSLocalizedString(@"lbissureinvitation", nil)
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"lbTCancle", nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction* _Nonnull action){

                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"btnDone", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction* _Nonnull action) {
                                                          //确定群邀

                                                          [self didInvitationAllFriends];
                                                      }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)InvitationFriends
{
    UIAlertView* myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"lbinvitation", nil) message:NSLocalizedString(@"lbissureinvitation", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"btnDone", nil) otherButtonTitles:NSLocalizedString(@"lbTCancle", nil), nil];
    [myAlertView show];
}

#pragma mark -uialertview代理
- (void)alertView:(UIAlertView*)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    //确定群邀
    if (buttonIndex == INVITE) {

        [self didInvitationAllFriends];
    }
}

//发送群邀
- (void)didInvitationAllFriends
{
    [AnimationHelper show:NSLocalizedString(@"START_INVITE", nil) InView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
    [ContactsTool DidInviteAllFriends:[ContactsTool AllPhoneAndEmail]];
}

- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //邀请sheet
    switch (buttonIndex) {
    case INVITE_MANY_PEOPLE: {
        if (![PJNetWorkHelper isNetWorkAvailable]) {

            [PJNetWorkHelper NoNetWork];
        }
        else {

            [AnimationHelper showHUD:LOADING];
            InviteAllFriendsController* inviteAllFriendsController = [[InviteAllFriendsController alloc] init];
            UINavigationController* nvisecond = [[UINavigationController alloc] init];
            [nvisecond addChildViewController:inviteAllFriendsController];
            [self presentViewController:nvisecond animated:YES completion:nil];
        }
    } break;
    case INVITE_ALL:
        if (![PJNetWorkHelper isNetWorkAvailable]) {

            [PJNetWorkHelper NoNetWork];
        }
        else {

            if (iOS(8)) {

                [self InvitationFriendsForHeightSys];
            }
            else {

                [self InvitationFriends];
            }
        }
        break;
    }
}

/**
 *  邀请结束
 *
 *  @param ref <#ref description#>
 */

- (void)RefreshViewControlEventValueChanged:(UIRefreshControl*)ref
{
    if (ref.refreshing) {
        ref.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"msgRefing", nil)];
        [self initData];
        [self performSelector:@selector(RefTableview:) withObject:ref afterDelay:1];
    }
}

- (void)RefTableview:(UIRefreshControl*)ref
{
    [ref endRefreshing];
    ref.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"msgRef", nil)];
    [tableview reloadData];
}

//#pragma mark-收到新消息
//#pragma mark-登陆成功
- (void)isSuccLogin:(BOOL)flag
{
    NSLog(@"登陆成功");
}

#pragma mark - 表格代理是需要实现的方法

- (void)tableView:(UITableView*)tableView didEndDisplayingCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
    [self initPrompt];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.chatuserlist.count;
}
- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    IMChatListModle* temp = [self.chatuserlist objectAtIndex:[indexPath row]];
    static NSString* CellIdentifier = @"ChatListCell";

    if([temp.messagebody.type isEqualToString:EMAIL]){
        
        self.eMailCell.chatListModle=temp;
        _eMailCell.tag=MessageTypeEmail;
        return _eMailCell;
    }else{
        
        //从缓存中获取
        ChatListTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        //如果还未缓存过
        if (cell == nil) {
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
        cell.backgroundColor = [UIColor clearColor];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImage* tempimg = [UIImage imageWithContentsOfFile:[Tool getFilePathFromDoc:temp.faceurl]];
        
        NSString* path = [Tool Append:IMReasonableAPPImagePath witnstring:temp.faceurl];
        NSString* defaultphoto = @"default";
        if ([temp.isRoom isEqualToString:@"1"]) {
            defaultphoto = @"GroupChatRound";
        }
        else {
            cell.messagecount.backgroundColor = [UIColor colorWithRed:0 green:0.47 blue:1 alpha:1];
        }
        
        [cell.userphoto sd_setImageWithURL:[NSURL URLWithString:path] placeholderImage:tempimg ? tempimg : [UIImage imageNamed:defaultphoto]]; //@"default"]];
        
        cell.username.text = temp.localname ? temp.localname : [[temp.jidstr componentsSeparatedByString:@"@"] objectAtIndex:0];
        NSString* msg = temp.messagebody.body;
        if ([temp.messagebody.type isEqualToString:@"img"] || [temp.messagebody.type isEqualToString:@"locimg"]) {
            msg = @"[image]";
        }
        if ([temp.messagebody.type isEqualToString:@"voice"] || [temp.messagebody.type isEqualToString:@"locimg"]) {
            msg = @"[voice]";
        }
        cell.message.text = msg;
        cell.messagetime.text = NSLocalizedString(temp.messagebody.date, temp.messagebody.date);
        //是否显示消息条数
        if ([temp.messageCount integerValue] > 0) {
            cell.messagecount.hidden = NO;
            if ([temp.isRoom isEqualToString:@"1"] && [temp.isNeedTip isEqualToString:@"0"]) {
                cell.messagecount.backgroundColor = [UIColor lightGrayColor];
            }
            cell.messagecount.text = [temp.messageCount integerValue] < 99 ? temp.messageCount : @"99+";
        }
        else {
            cell.messagecount.hidden = YES;
        }
        if (_inviteButton != nil) {
            
            [_inviteButton removeFromSuperview];
            [_backImageView removeFromSuperview];
        }
        return cell;
    }
}



- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{

    IMChatListModle* temp = [_chatuserlist objectAtIndex:[indexPath row]];

    if([tableView cellForRowAtIndexPath:indexPath].tag==MessageTypeEmail){
        
        SpreadMailViewController *spreadMailViewControl=[[SpreadMailViewController alloc] init];
        spreadMailViewControl.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:spreadMailViewControl animated:YES];
    }
//    if ([temp.accouttype isEqualToString:@"9999"]) {
//        SpreadMailViewController* spmail = [[SpreadMailViewController alloc] init];
//        spmail.from = temp;
//        spmail.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:spmail animated:NO];
//    }
    else {

        [searchDisplayController.searchBar resignFirstResponder];
        ChatViewController* Cannotview = [[ChatViewController alloc] init];
        self.tempmsg = temp.jidstr;
        Cannotview.from = temp;
        temp.messageCount = @"0";
        [_chatuserlist replaceObjectAtIndex:[indexPath row] withObject:temp];
        Cannotview.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:Cannotview animated:NO];
    }
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return 63;
}

//表格删除按钮的实现
- (UITableViewCellEditingStyle)tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
    return TRUE;
}
//修改删除按钮的标题
- (NSString*)tableView:(UITableView*)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return NSLocalizedString(@"lbclvdelete", nil);
}
- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{

    if (editingStyle == UITableViewCellEditingStyleDelete) { //如果编辑样式为删除样式
        if (indexPath.row < [_chatuserlist count]) {

            IMChatListModle* temp = [_chatuserlist objectAtIndex:[indexPath row]];

            if ([temp.isRoom isEqualToString:@"1"] && [temp.isimrea isEqualToString:@"1"]) { //是群且不是群成员的时候删除就是清除数据
                //真实的删除本地数据库数据
                if ([IMReasonableDao deleteUser:temp.jidstr]) { //删除成员并删除消息
                    [_chatuserlist removeObjectAtIndex:indexPath.row]; //移除数据源的数据
                    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft]; //移除tableView中的数据
                }
            }
            else {
                //删除普通聊天
                if ([IMReasonableDao updateNotShow:temp.jidstr]) {
                    [_chatuserlist removeObjectAtIndex:indexPath.row]; //移除数据源的数据
                    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft]; //移除tableView中的数据
                }
            }
        }
    }
}

#pragma mark -ChatHelperdelegate
- (void)receiveNewMessage:(IMMessage*)message isFwd:(BOOL)isfwd
{
    NSLog(@"message:%@",message);
    NSLog(@"messageType:%@",message.type);
    [self initData];
    dispatch_async(dispatch_get_main_queue(), ^{
        [tableview reloadData];
        if (_inviteButton != nil) {

            [_inviteButton removeFromSuperview];
            [_backImageView removeFromSuperview];
        }
    });
}
- (void)isSuccSendMessage:(IMMessage*)msg issuc:(BOOL)flag;
{
}
- (void)userStatusChange:(XMPPPresence*)presence
{

    if (presence == nil) {
        [self initData];
    }
}

#pragma mark - searchdelegate

- (BOOL)searchDisplayController:(UISearchDisplayController*)controller shouldReloadTableForSearchString:(NSString*)searchString
{
    [self getfilterData];
    return YES;
}

- (void)getfilterData
{

    [filterData removeAllObjects];

    NSString* search = searchDisplayController.searchBar.text;
    if (search.length > 0) {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"localname contains[c] %@ or phonenumber contains[c] %@ ", search, search]; //用于过滤
        _chatuserlist = [NSMutableArray arrayWithArray:[_chatuserlist filteredArrayUsingPredicate:predicate]];
    }
    else {
        _chatuserlist = [IMReasonableDao getChatlistModle];
        [tableview reloadData];
    }
}

- (BOOL)searchDisplayController:(UISearchDisplayController*)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    //当scope改变时调用
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar*)searchBar
{

    _chatuserlist = [IMReasonableDao getChatlistModle];
    [tableview reloadData];
}

#pragma mark -didReceiveMemoryWarning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    //去除分割线左边出现的空格
    if ([tableview respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableview setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }

    if ([tableview respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableview setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RELOAD_CACHE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RELOAD_CHETLIST object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CHANGEITEM" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CONNECTSCHANGE" object:nil];
}

@end
