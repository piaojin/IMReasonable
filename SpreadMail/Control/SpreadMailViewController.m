//
//  SpreadMailViewController.m
//  IMReasonable
//
//  Created by apple on 15/9/10.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import "SpreadMailViewController.h"
#import "MailTableViewCell.h"
#import "IMReasonableDao.h"
#import "WeChatTableViewCell.h"
#import "Tool.h"
#import "DesHelper.h"
#import "MJRefresh.h"

@interface SpreadMailViewController ()
{
    UITableView * _tableview;
     long pagenumber;
    NSMutableArray *messageList;
}

@end

@implementation SpreadMailViewController

#pragma mark--页面生命周期
- (void)viewDidLoad {
    [super viewDidLoad];

  
    [self initViewControl];
    [self initNavTitle];
      pagenumber=1;
    [self initData:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
#pragma mark-一些初始化操作

- (void)initNavTitle{

    self.navigationItem.title=NSLocalizedString(@"lbtspreadname",nil);//lbtspreadname@"Spread邮件提醒";
}

//初始化页面吧控件
- (void)initViewControl{
    _tableview =[[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _tableview.delegate=self;
    _tableview.dataSource=self;

    UINib * nib=[UINib  nibWithNibName:@"MailTableViewCell" bundle:nil ];
    [_tableview registerNib:nib forCellReuseIdentifier:@"SpreadMail"];
    _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableview.backgroundColor=[UIColor colorWithRed:193 green:193 blue:193 alpha:1];
    
    
    __block __weak typeof(self) tmpSelf = self;
    [_tableview addLegendHeaderWithRefreshingBlock:^(){
        [ tmpSelf initData:NO];
    }];
    
    // 设置文字
    [_tableview.header setTitle:@"Pull down to refresh" forState:MJRefreshHeaderStateIdle];
    [_tableview.header setTitle:@"Release to refresh" forState:MJRefreshHeaderStatePulling];
    [_tableview.header setTitle:@"Loading ..." forState:MJRefreshHeaderStateRefreshing];
    _tableview.header.updatedTimeHidden = YES;
    
    // 设置字体
    _tableview.header.font = [UIFont systemFontOfSize:15];
    
    // 设置颜色
    _tableview.header.textColor = [UIColor grayColor];
    
    [self.view addSubview:_tableview];
}



#pragma mark--获取数据
- (void)initData:(BOOL)isgo{
    
    if (!isgo) {
        pagenumber+=1;
    }
    
    NSString * fromjidstr=self.from.jidstr;
    NSString * tojidstr=[[NSUserDefaults standardUserDefaults] stringForKey:XMPPREASONABLEJID];
    if (!fromjidstr) {
        fromjidstr=self.from.messagebody.from;
        if([fromjidstr isEqualToString:tojidstr]){
            fromjidstr=self.from.messagebody.to;
        }
    }
    
    
    
    NSString * rowcount=[NSString stringWithFormat:@"%ld",pagenumber*15];
    messageList=nil;
    if ([self.from.isRoom isEqualToString:@"0"]) {
        messageList=[IMReasonableDao getMessageByFormAndToJidstr2:fromjidstr Tojidstr:tojidstr withRowCount:rowcount];
    }
    if (isgo) {
        //[self tableviewReload];
    }else{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableview reloadData];
        });
    }
    
     [_tableview.header endRefreshing];
}
#pragma mark--表格代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [messageList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static  NSString * Idetify=@"WECHATCELL";
    MessageModel * mode=[messageList objectAtIndex:[indexPath row]];
    
    if (mode.type==MessageTypeTime) {
        WeChatTableViewCell * cell = [_tableview dequeueReusableCellWithIdentifier:Idetify];
        if (!cell) {
            
            cell = [[WeChatTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Idetify];
            cell.delegate=(id)self;
        }else{
            for (UIView *subView in cell.contentView.subviews){
                [subView removeFromSuperview];
            }
        }
        
        [cell setMessagemode:mode isNeedName:NO];
        
        return cell;
    }else{
       
        static NSString * IdetifyMail=@"SpreadMail";
        MailTableViewCell *mailcell = [tableView dequeueReusableCellWithIdentifier:IdetifyMail];
        mailcell.selectionStyle=UITableViewCellSelectionStyleNone;
        NSError* error1;
        NSDictionary * dict=[NSJSONSerialization JSONObjectWithData:[Tool getDataFromGBKString:mode.content] options:NSJSONReadingMutableLeaves error:&error1];
        if (!error1) {
            mailcell.mailsendername.text=[dict objectForKey:@"title"];
            mailcell.mailtitle.text=[dict objectForKey:@"url"];
            mailcell.mailcontent.text=mode.content;
        }
        return mailcell;
    
    }
    
   
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    MessageModel * mode=[messageList objectAtIndex:[indexPath row]];
    if (mode.type==MessageTypeTime) {
        CGFloat height=[WeChatTableViewCell getCellHeight:[messageList objectAtIndex:[indexPath row]] isNeedName:NO];
        return height;
    }else{
       return 103;
    }
   
   
}



@end
