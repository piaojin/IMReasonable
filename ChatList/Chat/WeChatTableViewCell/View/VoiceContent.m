//
//  VoiceContent.m
//  KeyBoard
//
//  Created by apple on 15/6/8.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import "VoiceContent.h"
#import "UUAVAudioPlayer.h"
#import "StateView.h"

@implementation VoiceContent
{
    
    UILabel * _voicetime;
    UIImageView * _voiceAm;
    UIActivityIndicatorView *_voiceload;
    
     BOOL contentVoiceIsPlaying;
    UUAVAudioPlayer *audio;
    StateView * _stateview; //状态视图


}
-(instancetype)init{
    self=[super init];
    
    if (self) {
        self.backgroundImage=[[UIImageView alloc] init];
        [self addSubview:self.backgroundImage];
        _voicetime = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, 70, 30)];
        _voicetime.textAlignment = NSTextAlignmentCenter;
        _voicetime.font = [UIFont systemFontOfSize:12];
        _voiceAm = [[UIImageView alloc]initWithFrame:CGRectMake(80, 5, 20, 20)];
        _voiceAm.image = [UIImage imageNamed:@"chat_animation_white3"];
        _voiceAm.animationImages = [NSArray arrayWithObjects:
                                      [UIImage imageNamed:@"chat_animation_white1"],
                                      [UIImage imageNamed:@"chat_animation_white2"],
                                      [UIImage imageNamed:@"chat_animation_white3"],nil];
        _voiceAm.animationDuration = 1;
        _voiceAm.animationRepeatCount = 0;
        _voiceload = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _voiceload.center=CGPointMake(80, 15);
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stopvoice)
                                                     name:@"STOPVOICE"
                                                   object:nil];
        
        UITapGestureRecognizer *singleFingerOne = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(voiceClick:)];
        singleFingerOne.numberOfTouchesRequired = 1; //手指数
        singleFingerOne.numberOfTapsRequired = 1; //tap次数
        
        [self addGestureRecognizer:singleFingerOne];
        
        _stateview=[[StateView alloc]init];
        [self addSubview:_stateview];
    
       
        [self addSubview:_voicetime];
        [self addSubview:_voiceAm];
        [self addSubview:_voiceload];
    

        _voicetime.userInteractionEnabled = NO;
        _voiceAm.userInteractionEnabled = YES;
        
       _voiceAm.backgroundColor = [UIColor clearColor];
        _voicetime.backgroundColor = [UIColor clearColor];
        _voiceload.backgroundColor = [UIColor clearColor];

        
    }
    
    return self;
}

- (void)voiceClick:(UITapGestureRecognizer *)tap{
    
    audio = [UUAVAudioPlayer sharedInstance];
    audio.delegate =self;

    
    if(!audio.player.isPlaying){
        NSLog(@"-----%@",audio.player.isPlaying?@"yes":@"no");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"VoicePlayHasInterrupt" object:nil];
        [audio playSongWithUrl:self.messagemode.voicepath];
    }else{
        [self UUAVAudioPlayerDidFinishPlay];
    }

    NSLog(@"ada");
}

- (void)UUAVAudioPlayerBeiginLoadVoice
{
    _voiceAm.hidden = YES;
    [_voiceload startAnimating];
}
- (void)UUAVAudioPlayerBeiginPlay
{
    //开启红外线感应
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    _voiceAm.hidden = NO;
    [_voiceload stopAnimating];
    [_voiceAm startAnimating];
}
- (void)UUAVAudioPlayerDidFinishPlay
{
    //关闭红外线感应
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
  //  contentVoiceIsPlaying = NO;
     [_voiceAm stopAnimating];
    [[UUAVAudioPlayer sharedInstance]stopSound];
}

- (void)stopvoice{
    //关闭红外线感应
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    //  contentVoiceIsPlaying = NO;
    [_voiceAm stopAnimating];
    [[UUAVAudioPlayer sharedInstance]stopSound];
}




- (void)setMessagemode:(MessageModel *)messagemode isNeedName:(BOOL)isName{
    
    _messagemode=messagemode;
    CGRect rect=CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
      [_stateview setStateviewData:messagemode];
    
    self.backgroundImage.frame=rect;
    
    if (messagemode.isFromMe) {
        _voicetime.textColor = [UIColor grayColor];
//        UIImage *bubble = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"chatto_bg_normal" ofType:@"png"]];
//        self.backgroundImage.image=[bubble resizableImageWithCapInsets:UIEdgeInsetsMake(49, 97, 57, 118) resizingMode:UIImageResizingModeStretch];
        
        UIImage *bubble =[UIImage imageNamed:@"BubbleOutgoing"] ;
        CGFloat top =10; // 顶端盖高度
        CGFloat left = bubble.size.width/2 ; // 底端盖高度
        CGFloat bottom = bubble.size.height - top + 1; // 左端盖宽度
        CGFloat right = bubble.size.width - left - 1; // 右端盖宽度
        UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
        self.backgroundImage.image=[bubble resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
        
         _stateview.frame=CGRectMake(120-50, 40-15, 45, 10);
    }else{
        
         _voicetime.textColor = [UIColor grayColor];
        _voicetime.frame=CGRectMake(15, 5, 70, 30);
        _voiceAm.frame=CGRectMake(95, 10, 20, 20);
//        //设置背景气泡
//        UIImage *bubble = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"chatfrom_bg_normal" ofType:@"png"]];
//        self.backgroundImage.image=[bubble resizableImageWithCapInsets:UIEdgeInsetsMake(40,42,69,60)
//                                                          resizingMode:UIImageResizingModeStretch];
        
        //设置背景气泡
        UIImage *bubble =[UIImage imageNamed:@"BubbleIncoming"];
        CGFloat top =10; // 顶端盖高度
        CGFloat left = bubble.size.width/2 ; // 底端盖高度
        CGFloat bottom = bubble.size.height - top + 1; // 左端盖宽度
        CGFloat right = bubble.size.width - left - 1; // 右端盖宽度
        UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
        self.backgroundImage.image=[bubble resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
        

       _stateview.frame=CGRectMake(120-30, 40-15, 25, 10);
    
    }
    
    _voicetime.text=[NSString stringWithFormat:@"%@ 's Voice",messagemode.content];
    

}

-(void)dealloc{
     
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"STOPVOICE" object:nil];
}

@end
