//
//  PictureContent.m
//  KeyBoard
//
//  Created by apple on 15/6/10.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//



#import "PictureContent.h"
#import "StateView.h"
#import "UUImageAvatarBrowser.h"
#import "UIImageView+WebCache.h"


@implementation PictureContent
{
    UIImageView * _imageview;
    UILabel *_username;//用于显示对方的姓名的
    UILabel * _line;  //用于设置分割线，
    StateView * _stateview; //状态视图
}


-(instancetype)init{
    self=[super init];
    
    if (self) {
        self.backgroundImage=[[UIImageView alloc] init];
        [self addSubview:self.backgroundImage];
        _imageview=[[UIImageView alloc] init];
        _imageview.layer.masksToBounds = YES;
        _imageview.layer.cornerRadius = 5;
        _imageview.tag=200;
        
        
        [self addSubview:_imageview];
        
        _username=[[UILabel alloc] init];
        _username.textColor=[UIColor colorWithRed:0.1 green:0.5 blue:0.2 alpha:1];;//[UIColor colorWithRed:0.3 green:0.2 blue:0.6 alpha:1];
        [_username setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
        [self addSubview:_username];
      
        
        
        _stateview=[[StateView alloc]init];
        [self addSubview:_stateview];
        
        
        
    }
    
    return self;
}



- (void)setMessagemode:(MessageModel *)messagemode isNeedName:(BOOL)isName
{
    _messagemode=messagemode;
    _username.text=messagemode.username;
    
    [_stateview setStateviewData:messagemode];
    
   
  
    _imageview.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fangda:)];
    [_imageview addGestureRecognizer:singleTap];
    
    
    CGRect rect=CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.backgroundImage.frame=rect;
    if (messagemode.isFromMe) {
        
        UIImage * tempimg=[UIImage imageWithContentsOfFile:[Tool getFilePathFromDoc:messagemode.content]];
        _imageview.image=tempimg;
        
        UIImage *bubble =[UIImage imageNamed:@"BubbleOutgoing"] ;
        CGFloat top =10; // 顶端盖高度
        CGFloat left = bubble.size.width/2 ; // 底端盖高度
        CGFloat bottom = bubble.size.height - top + 1; // 左端盖宽度
        CGFloat right = bubble.size.width - left - 1; // 右端盖宽度
        UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
        self.backgroundImage.image=[bubble resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
        
        _imageview.frame=CGRectMake(2.5, 1, self.frame.size.width-15, self.frame.size.height-2);
        _stateview.frame=CGRectMake(_imageview.frame.size.width-45, _imageview.frame.size.height-10, 45, 10);
        
        
        
    }else{
        
        //设置背景气泡
        UIImage *bubble =[UIImage imageNamed:@"BubbleIncoming"];
        CGFloat top =10; // 顶端盖高度
        CGFloat left = bubble.size.width/2 ; // 底端盖高度
        CGFloat bottom = bubble.size.height - top + 1; // 左端盖宽度
        CGFloat right = bubble.size.width - left - 1; // 右端盖宽度
        UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
        self.backgroundImage.image=[bubble resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
        
        CGFloat offset=0;
        if (isName) {
            offset=20;
            _username.hidden=NO;
        }else{
            _username.hidden=YES;
            offset=2;
         
        }

        //设置聊天的内容
        _imageview.frame=CGRectMake(13, offset, 140-2, 140-2);//设置图片的尺寸
        _username.frame=CGRectMake(15, 0, self.frame.size.width-15, offset); //设置显示用户的名字
        
        NSString *path=[Tool Append:IMReasonableAPPImagePath witnstring:messagemode.content];
          [_imageview sd_setImageWithURL:[NSURL URLWithString:path] placeholderImage:[UIImage imageNamed:@"loading.png"]];
        _stateview.frame=CGRectMake(self.frame.size.width-30, self.frame.size.height-15, 25, 10);
        
        
        
        
    }
    
    
    
    
    
}

- (void)fangda:(id)sender{
    
   // [UUImageAvatarBrowser showImage:_imageview data:_messagemode];
    [self.delegate touchPictureContent:_imageview MessageModle:_messagemode];

}
@end
