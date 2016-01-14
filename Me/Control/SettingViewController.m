//
//  SettingViewController.m
//  IMReasonable
//
//  Created by 翁金闪 on 16/1/11.
//  Copyright © 2016年 Reasonable. All rights reserved.
//

#import "SettingWithSwitchCell.h"
#import "SettingViewController.h"

#define CELL_H 56
#define SWITCH_BUTTON 0

typedef enum{
    CELL_WITH_SWITCH_BUTTON_LANDSCAPE, //带滑动开关的cell,其他类型的cell可在此处扩展(是否横屏)
    CELL_WITH_SWITCH_BUTTON_ANIMATION //是否开启动画
} cellType;

@interface SettingViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,copy)NSMutableArray *settersArray;

@end

@implementation SettingViewController

-(void)initData{
    _settersArray=[NSMutableArray array];
    [_settersArray addObject:NSLocalizedString(@"ALLOW_LANDSCAPE", nil)];
    [_settersArray addObject:NSLocalizedString(@"OPEN_ANIMATION", nil)];
}

-(void)initView{
    self.tableView=[[UITableView alloc] init];
    self.tableView.frame=CGRectMake(0,0,SCREENWIDTH,SCREENWIHEIGHT);
    [self.view addSubview:self.tableView];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.tableFooterView=[[UIView alloc] init];
    self.tableView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self initData];
    [self initView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID;
    switch(indexPath.row){
        case CELL_WITH_SWITCH_BUTTON_LANDSCAPE:
            ID=@"SETTINGS";
            return [self SettingWithSwitchCell:ID AndTableView:tableView RowAtIndexPath:indexPath WithType:SWITCH_ALLOW_LANDSCAPE];
            break;
        //其他类型的cell可在此处扩展
        case CELL_WITH_SWITCH_BUTTON_ANIMATION:
            ID=@"SETTINGS";
            return [self SettingWithSwitchCell:ID AndTableView:tableView RowAtIndexPath:indexPath WithType:SWITCH_OPEN_ANIMATION];
            break;
    }
    return nil;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.settersArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return CELL_H;
}

-(SettingWithSwitchCell *)SettingWithSwitchCell:(NSString *)ID AndTableView:(UITableView *)tableView RowAtIndexPath:(NSIndexPath *)indexPath WithType:(int)type{
    SettingWithSwitchCell *cell;
    cell= [tableView dequeueReusableCellWithIdentifier:ID];
    if(!cell){
        
        cell = [[SettingWithSwitchCell alloc] initWithType:type AndStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    cell.textLabel.text=self.settersArray[indexPath.row];
    return cell;
}

@end
