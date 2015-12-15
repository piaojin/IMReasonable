//
//  PJImageBrowserController.m
//  IMReasonable
//
//  Created by 翁金闪 on 15/12/10.
//  Copyright © 2015年 Reasonable. All rights reserved.
//

#import "PJImageBrowserController.h"

@interface PJImageBrowserController ()<UIScrollViewDelegate>

@property(nonatomic,weak)UIScrollView *scrollView;
//图片索引指示器
@property(nonatomic,copy)NSString *indexStr;

@end

@implementation PJImageBrowserController

+(instancetype)getInstanceWithImageArray:(NSMutableArray *)imageArray AndCurrentIndex:(int)currentIndex{
    PJImageBrowserController *pjImageBrowserController=[[PJImageBrowserController alloc] init];
    pjImageBrowserController.imageArray=imageArray;
    pjImageBrowserController.currentIndex=currentIndex;
    return pjImageBrowserController;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self initController];
    [self setupScrollView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initController{
    UIBarButtonItem *rightButton=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deletePhoto)];
    self.navigationItem.rightBarButtonItem=rightButton;
    [self updateTitle];
}

-(void)updateTitle{
    self.indexStr=[NSString stringWithFormat:@"%d/%lu",self.currentIndex+1,(unsigned long)self.imageArray.count];
    self.navigationItem.title=self.indexStr;
}

-(void)deletePhoto{
    
}

- (void)setupScrollView
{
    [UIView animateWithDuration:1.0 animations:^{
        self.navigationController.hidesBarsOnTap=YES;
    }];
    // 1.添加UISrollView
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.frame = self.view.bounds;
    scrollView.delegate = self;
    [self.view addSubview:scrollView];
    self.scrollView=scrollView;
    
    // 2.添加图片
    CGFloat imageW=scrollView.frame.size.width;
    CGFloat imageH=scrollView.frame.size.height;
    for (int i = 0; i<self.imageArray.count; i++) {
        // 创建UIImageView
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = self.imageArray[i];
        [scrollView addSubview:imageView];
        NSLog(@"%f",imageView.image.size.height);
        
        // 设置frame
        imageView.frame=CGRectMake(i * imageW, 0, imageW, imageH);
    }
    
    // 3.设置其他属性
    scrollView.contentSize = CGSizeMake(self.imageArray.count * imageW, 0);
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
}

- (void)updateCurrentIndex
{
    self.currentIndex = self.scrollView.contentOffset.x / self.scrollView.frame.size.width;
    NSLog(@"%d",self.currentIndex);
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateCurrentIndex];
    [self updateTitle];
}

@end
