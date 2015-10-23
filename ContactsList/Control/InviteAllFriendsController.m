//
//  InviteAllFriendsController.m
//  IMReasonable
//
//  Created by 翁金闪 on 15/10/20.
//  Copyright © 2015年 Reasonable. All rights reserved.
//

#import "Person.h"
#import "ContactsTool.h"
#import "InviteAllFriendsController.h"
#import "AnimationHelper.h"

#define INVITECELL @"UITableViewCell"

@interface InviteAllFriendsController ()
//所有非talkking用户
@property(nonatomic,copy)NSArray* personArray;
@end

@implementation InviteAllFriendsController

//懒加载所有非talkking用户
-(NSArray *)personArray{
    if(!_personArray){
        
        dispatch_sync(dispatch_get_global_queue(0, 0), ^{
             _personArray=[ContactsTool AllPerson];
        });
    }
    return _personArray;
}

- (void)viewDidLoad
{

    [super viewDidLoad];
    [self initTableView];
    [self initNav];
}

-(void)viewWillAppear:(BOOL)animated{
    [AnimationHelper removeHUD];
    NSLog(@"viewWillAppear");
}

- (void)initTableView
{
    //去除空行
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    //显示左边的checkbox
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.tableView.editing = YES;
}

- (void)initNav
{
    self.navigationItem.title = NSLocalizedString(@"lbSUTitle", nil);
    UIBarButtonItem* left = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = left;
    UIBarButtonItem* right = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(invite)];
    self.navigationItem.rightBarButtonItem = right;

    self.navigationItem.rightBarButtonItem.enabled = NO;
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    //判断完成按钮是否可以被点击
    if([self.tableView indexPathsForSelectedRows]!=nil){
        
        self.navigationItem.rightBarButtonItem.enabled=YES;
    }else{
        
        self.navigationItem.rightBarButtonItem.enabled=NO;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //设置完成按钮可以被点击
    self.navigationItem.rightBarButtonItem.enabled=YES;
}

- (void)invite
{
    [AnimationHelper show:NSLocalizedString(@"START_INVITE",nil) InView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
    //群邀
    NSArray* selectedPersonIndexArray=[self.tableView indexPathsForSelectedRows];
    //存放所有待邀请手机号码
    NSMutableArray* allPhoneArray=[NSMutableArray array];
    //存放所有待邀邮箱
    NSMutableArray* allemailArray=[NSMutableArray array];
    NSMutableArray* phoneAndemailArray=[NSMutableArray array];
    for(int i=0;i<selectedPersonIndexArray.count;i++){
        
        Person* per=self.personArray[((NSIndexPath *)selectedPersonIndexArray[i]).row];
        //有些用户只有手机号码或只有邮箱(手机号码和邮箱都可以是多个的，手机号码或邮箱为空就没必要添加)
        NSArray* phone=per.phoneArray;
        NSArray* email=per.emailArray;
        if(phone.count>0){
            
            [allPhoneArray addObjectsFromArray:phone];
        }
        if(email.count>0){
            
            [allemailArray addObjectsFromArray:email];
        }
    }
    [phoneAndemailArray addObject:allPhoneArray];
    [phoneAndemailArray addObject:allemailArray];
    [ContactsTool DidInviteAllFriends:phoneAndemailArray];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"didEndDisplayingCell");
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete implementation, return the number of rows
    return self.personArray.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell=[tableView dequeueReusableCellWithIdentifier:INVITECELL];
    if(cell==nil){
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:INVITECELL];
    }
    Person* per=self.personArray[indexPath.row];
    //用户可能只有手机号码或邮箱或者两个都没有
    if(per.phoneArray.count>0){
        
        //有多个电话号码也只是显示第一个号码
        NSString *phone=per.phoneArray[0];
        cell.detailTextLabel.text=[ContactsTool DidCutPhoneArea:phone];
    }else if(per.emailArray.count>0){
        
        //有多个邮箱也只显示第一个邮箱
        cell.detailTextLabel.text=per.emailArray[0];
    }
    cell.textLabel.text = per.name;
    return cell;
}

@end
