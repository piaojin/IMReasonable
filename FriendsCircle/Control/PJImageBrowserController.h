//
//  PJImageBrowserController.h
//  IMReasonable
//
//  Created by 翁金闪 on 15/12/10.
//  Copyright © 2015年 Reasonable. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PJImageBrowserController : UIViewController

//当前图片的索引
@property(nonatomic,assign)int currentIndex;
//存放所有要显示的图片
@property(nonatomic,strong)NSMutableArray *imageArray;
//存放删除后剩余的图片
@property(nonatomic,strong)NSMutableArray *returnImageArray;
//构造函数
+(instancetype)getInstanceWithImageArray:(NSMutableArray *)imageArray AndCurrentIndex:(int)index;

@end
