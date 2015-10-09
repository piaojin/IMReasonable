//
//  WeChatKeyBoard.m
//  KeyBoard
//
//  Created by apple on 15/5/26.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//

#import "WeChatKeyBoard.h"
#import "DetailKeyBoard.h"
#import "MBProgressHUD.h"
#import "LVRecordTool.h"

#define _ScreenWidth  [[UIScreen mainScreen] bounds].size.width
#define _ScreenHeight  [[UIScreen mainScreen] bounds].size.height
#define _lineKeyboardHeight 49
#define _WeChatKeyBoardHeight 280
#define _DetailKeyBoardHeight 200


//定义各个操作的tag
#define TXTORVOICE  11100
#define VOICE       11101
#define FASE        11110
#define MORE        11111


@implementation WeChatKeyBoard{
    
    UIView * _linekeyboard; //不触发任何效果时的键盘效果
//    UITextField * _txt;  //文本输入框
    UITextView *  _txt;
    UIButton * _txtorvoice; //点击切换输入语音和文字的
    UIButton * _voice;  //按住开始输入语音
    UIButton * _face;   //表情
    UIButton * _more;   //更多
    
    //辅助变量
    BOOL _isFaceAndMore;
 //  CGFloat _alloffset;
    
    //弹出的详细键盘 实现更多功能
    DetailKeyBoard * _detailkeyboard;
    
    //用于录音的时候显示动画提示效果
    MBProgressHUD *  _hud ;
    
    
    BOOL _isbeginVoiceRecord;
    Mp3Recorder *_MP3;
    NSInteger _playTime;
    NSTimer *_playTimer;
    
    
//    ///父视图
//    UIViewController* _superview;
    
    

   
}

- (id)init:(UIViewController *) viewcontrol{
    self = [super initWithFrame:CGRectMake(0, _ScreenHeight-_lineKeyboardHeight, _ScreenWidth, _lineKeyboardHeight)];
    if (self) {
       
        
        
        _isFaceAndMore=false;
         _MP3 = [[Mp3Recorder alloc]initWithDelegate:self];
        
        self.backgroundColor=[UIColor clearColor];
        
        [viewcontrol.view bringSubviewToFront:self];
        [self becomeFirstResponder];
       

        [LVRecordTool sharedRecordTool].delegate=self;
        
     //   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
        
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
        
        _isFaceAndMore=false;
        _linekeyboard=[[UIView alloc] initWithFrame:CGRectMake(0,0, _ScreenWidth, _lineKeyboardHeight)];
        _linekeyboard.backgroundColor=[UIColor whiteColor];
        [self addSubview:_linekeyboard];
        
        UIView * line =[[UIView alloc] initWithFrame:CGRectMake(0,0,_ScreenWidth ,1)];
        line.backgroundColor=[UIColor lightGrayColor];
        [_linekeyboard addSubview:line];
        
        
             CGFloat spacewidth=_ScreenWidth/10;//把输入工具栏10等分咯
        
        
            _txtorvoice=[[UIButton alloc ]initWithFrame:CGRectMake(10, 7, spacewidth, 35)];
            [_txtorvoice setImage:[UIImage imageNamed:@"ToolViewInputVoice.png"] forState:UIControlStateNormal];
            [_txtorvoice setImage:[UIImage imageNamed:@"ToolViewInputText.png"] forState:UIControlStateSelected];
            [_txtorvoice addTarget:self action:@selector(btnSelect:) forControlEvents:UIControlEventTouchUpInside];
            _txtorvoice.selected=NO;
            _txtorvoice.tag=TXTORVOICE;
        
            _voice=[[UIButton alloc ]initWithFrame:CGRectMake(20+spacewidth, 7, spacewidth*6, 35)];
            _voice.layer.cornerRadius = 4.5;
            _voice.layer.borderWidth = 1.5;

           UIColor * cl=[UIColor colorWithRed:0.2 green:0.3 blue:0.4 alpha:0.5];
            [_voice.layer setBorderColor:cl.CGColor];
        
        
            [_voice setTitle:@"按住 说话" forState:UIControlStateNormal];
            [_voice setTitle:@"按住 说话" forState:UIControlStateSelected];
            [_voice setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [_voice setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
        
//            [_voice addTarget:self action:@selector(handleSwipeToUp:) forControlEvents:UIControlEventTouchDragExit];
//           [_voice addTarget:self action:@selector(handleSwipeTouchDown:) forControlEvents:UIControlEventTouchDown];
//           [_voice addTarget:self action:@selector(handleSwipeTouchupinside:) forControlEvents:UIControlEventTouchUpInside];
        
        [_voice addTarget:self action:@selector(beginRecordVoice:) forControlEvents:UIControlEventTouchDown];
        [_voice  addTarget:self action:@selector(endRecordVoice:) forControlEvents:UIControlEventTouchUpInside];
        [_voice addTarget:self action:@selector(cancelRecordVoice:) forControlEvents:UIControlEventTouchUpOutside | UIControlEventTouchCancel];
        [_voice addTarget:self action:@selector(RemindDragExit:) forControlEvents:UIControlEventTouchDragExit];
        [_voice addTarget:self action:@selector(RemindDragEnter:) forControlEvents:UIControlEventTouchDragEnter];

            _voice.hidden=YES;
        
        
        _txt= [[UITextView alloc] initWithFrame:CGRectMake(20+spacewidth, 7, spacewidth*6, 35)];
        _txt.layer.borderColor = [UIColor grayColor].CGColor;
        _txt.layer.borderWidth =1.0;
        _txt.layer.cornerRadius =5.0;
        
        _txt.font=[UIFont systemFontOfSize:18];
        _txt.returnKeyType=UIReturnKeySend;
        _txt.textColor=[UIColor  blackColor];
        _txt.delegate=self;

//            _txt=[[UITextField alloc] initWithFrame:CGRectMake(20+spacewidth, 7, spacewidth*6, 35)];
//            _txt.borderStyle=UITextBorderStyleRoundedRect;
//            _txt.font=[UIFont systemFontOfSize:11];
//            _txt.returnKeyType=UIReturnKeySend;
//            _txt.textColor=[UIColor  blackColor];
//            _txt.delegate=self;
        
        _face=[[UIButton alloc ]initWithFrame:CGRectMake(20+spacewidth*7, 7, spacewidth, 35)];
        [_face setImage:[UIImage imageNamed:@"ToolViewEmotion.png"] forState:UIControlStateNormal];
        [_face setImage:[UIImage imageNamed:@"ToolViewEmotion.png"] forState:UIControlStateSelected];
        [_face addTarget:self action:@selector(btnSelect:) forControlEvents:UIControlEventTouchUpInside];
        _face.tag=FASE;
        
        
        _more=[[UIButton alloc ]initWithFrame:CGRectMake(20+spacewidth*8, 7, _ScreenWidth-20-spacewidth*8, 35)];
        UIEdgeInsets insets = UIEdgeInsetsMake(0 , (_more.frame.size.width-spacewidth)/2-5, 0, (_more.frame.size.width-spacewidth)/2+5);
        [_more setImage:[UIImage imageNamed:@"TypeSelectorBtn_Black.png"] forState:UIControlStateNormal];
        [_more setImage:[UIImage imageNamed:@"TypeSelectorBtn_Black.png"] forState:UIControlStateSelected];
        [_more setImageEdgeInsets:insets];
        [_more addTarget:self action:@selector(btnSelect:) forControlEvents:UIControlEventTouchUpInside];
        _more.tag=MORE;
       
       
        
        _detailkeyboard=[[DetailKeyBoard alloc] initWithFrame:CGRectMake(0,49, _ScreenWidth, _DetailKeyBoardHeight)];
        _detailkeyboard.hidden=YES;
        [_detailkeyboard ChoiceViewShow:0];
        _detailkeyboard.detailKeyBoardDelegate=self;
        
        
        [_linekeyboard addSubview:_txtorvoice];
        [_linekeyboard addSubview:_voice];
         [_linekeyboard addSubview:_txt];
        [_linekeyboard addSubview:_face];
        [_linekeyboard addSubview:_more];
        

        [self addSubview:_detailkeyboard];
        [self bringSubviewToFront:_detailkeyboard];
        
        
        
        
        
      
        
        
    }
    
  
    return self;

}


- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    
    if (point.y>0) {
        return YES;
    }
  return NO;
}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
//    CGPoint btnPointInA = [_txtorvoice convertPoint:point fromView:self];
//    if ([_txtorvoice pointInside:btnPointInA withEvent:event]) {
//        return _txtorvoice;
//    }
//    
//    CGPoint btnPointInB = [_txt convertPoint:point fromView:self];
//    if ([_txt pointInside:btnPointInB withEvent:event]) {
//        return _txt;
//    }
//    
//    CGPoint btnPointInC = [_face convertPoint:point fromView:self];
//    if ([_face pointInside:btnPointInC withEvent:event]) {
//        return _face;
//    }
//    
//    CGPoint btnPointInD = [_more convertPoint:point fromView:self];
//    if ([_more pointInside:btnPointInD withEvent:event]) {
//        return _more;
//    }
//    
//    CGPoint btnPointInE = [_voice convertPoint:point fromView:self];
//    if ([_voice pointInside:btnPointInE withEvent:event]) {
//        return _voice;
//    }
//    CGPoint btnPointInF = [_detailkeyboard convertPoint:point fromView:self];
//    if ([_detailkeyboard pointInside:btnPointInF withEvent:event]) {
//        return _detailkeyboard;
//    }
//    
////    CGPoint btnPointInE = [_voice convertPoint:point fromView:self];
////    if ([_voice pointInside:btnPointInE withEvent:event]) {
////        return _voice;
////    }
//    
//   

   return [super hitTest:point withEvent:event];
    //return nil;
    
}
- (void)btnSelect:(UIButton *) btn
{
    switch (btn.tag)
    {
        case TXTORVOICE:
        {
            
            
            if (btn.selected) {
               
                btn.selected=NO;
                _voice.hidden=YES;
                _txt.hidden=NO;
                [_txt becomeFirstResponder];
            }else{
                
                
                //[_txt resignFirstResponder];
                [self hideKeyboard];
                
                btn.selected=YES;
                _voice.hidden=NO;
                _txt.hidden=YES;
            }
            
            
        }break;
            
        case VOICE:
        {
            NSLog(@"发送声音");
        }break;
            
        case FASE:
        {
            NSLog(@"点击了表情");
            
            btn.selected=NO;
            _voice.hidden=YES;
            _txt.hidden=NO;
          
              [_detailkeyboard ChoiceViewShow:0];
            
            if (_isFaceAndMore) {//已经是表情或者跟多的情况下拉 就直接切换显示的内容
              
            }else{
                [_txt resignFirstResponder];
                _detailkeyboard.hidden=NO;
              [self scroll:-_DetailKeyBoardHeight];
            }
            _isFaceAndMore=true;
            
            
            
        }break;
            
        case MORE:
        {
            
            btn.selected=NO;
            _voice.hidden=YES;
            _txt.hidden=NO;
            
              NSLog(@"点击了更多");
             [_detailkeyboard ChoiceViewShow:1];
            _detailkeyboard.backgroundColor=[UIColor yellowColor];
            
            if (_isFaceAndMore) {
            }else{
                [_txt resignFirstResponder];
                _detailkeyboard.hidden=NO;
                [self scroll:-_DetailKeyBoardHeight];
            }
            _isFaceAndMore=true;
            
            
        }break;
            
        default:
            break;
    }
}

- (void)beginRecordVoice:(UIButton *)button
{
     _voice.backgroundColor=[UIColor lightGrayColor];
    [_MP3 startRecord];
    _playTime = 0;
    _playTimer = [NSTimer scheduledTimerWithTimeInterval:0.6 target:self selector:@selector(countVoiceTime) userInfo:nil repeats:YES];
    [UUProgressHUD show];
}

- (void)endRecordVoice:(UIButton *)button
{
    if (_playTimer) {
        [_MP3 stopRecord];
        [_playTimer invalidate];
        _playTimer = nil;
    }
}

- (void)cancelRecordVoice:(UIButton *)button
{
    if (_playTimer) {
        [_MP3 cancelRecord];
        [_playTimer invalidate];
        _playTimer = nil;
    }
    _voice.backgroundColor=[UIColor whiteColor];
    [UUProgressHUD dismissWithError:@"Cancel"];
}

- (void)RemindDragExit:(UIButton *)button
{
    [UUProgressHUD changeSubTitle:@"Release to cancel"];
}

- (void)RemindDragEnter:(UIButton *)button
{
    [UUProgressHUD changeSubTitle:@"Slide up to cancel"];
}

- (void)countVoiceTime
{
    _playTime ++;
    if (_playTime>=80) {
        [self endRecordVoice:nil];
    }
}


#pragma mark - Mp3RecorderDelegate

//回调录音资料
- (void)endConvertWithData:(NSData *)voiceData filepath:(NSString *)path time:(double)ct
{
    [self.delegate sendVoiceContent:path voicedata:voiceData voicelenth:ct];
    [UUProgressHUD dismissWithSuccess:@"Success"];
     _voice.backgroundColor=[UIColor whiteColor];
    //缓冲消失时间 (最好有block回调消失完成)
    _voice.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _voice.enabled = YES;
    });
}

- (void)failRecord
{
    [UUProgressHUD dismissWithSuccess:@"Too short"];
     _voice.backgroundColor=[UIColor whiteColor];
   
    _voice.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _voice.enabled = YES;
    });
}
- (void)beginConvert
{

}

//- (void)handleSwipeToUp:(UIButton*)btn{
// 
//    NSLog(@"录音取消");
//   
//    _voice.backgroundColor=[UIColor whiteColor];
//    _hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"KeyBord/mic_0"]];
//      _hud.labelText = @"已取消录音";
//    
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        
//        [[LVRecordTool sharedRecordTool] stopRecording];
//        [[LVRecordTool sharedRecordTool] destructionRecordingFile];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [_hud hide:YES afterDelay:0];
//             _hud.labelText = @"手指上划，取消发送";
//            
//        });
//    });
//}
//
//- (void)handleSwipeTouchDown:(UIButton *)btn{
//  
//    [self performSelector:@selector(delayMethod) withObject:nil afterDelay:0.5f];
//}
//
//- (void)handleSwipeTouchupinside:(UIButton *)btn{
//    NSLog(@"录音结束");
//    
// 
//    _voice.backgroundColor=[UIColor whiteColor];
//    _hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"KeyBord/mic_0"]];
//    
//    double currentTime = [LVRecordTool sharedRecordTool].recorder.currentTime;
//    NSLog(@"%lf", currentTime);
//    if (currentTime < 2) {
//        
//        
//          _hud.labelText = @"说话时间太短";
//           [_hud hide:YES afterDelay:1.5];
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            
//            [[LVRecordTool sharedRecordTool] stopRecording];
//            [[LVRecordTool sharedRecordTool] destructionRecordingFile];
//        });
//    } else {
//        
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            
//            [[LVRecordTool sharedRecordTool] stopRecording];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                _hud.labelText = @"手指上划，取消发送";
//                [_hud hide:YES];
//            });
//        });
//        
//        // 已成功录音
//        NSLog(@"已成功录音");
//    }
//
//    
//}
//- (void)delayMethod{
//    NSLog(@"录音开始");
//    _voice.backgroundColor=[UIColor lightGrayColor]; //更改按住说话时的控件外观
//    
//    [[LVRecordTool sharedRecordTool] startRecording]; //开始录音
//    
//    //设置提示的显示样式并显示出来
//    _hud = [[MBProgressHUD alloc] initWithView:self.window];
//    [self.window addSubview:_hud];
//    _hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"KeyBord/mic_0"]];
//    _hud.mode = MBProgressHUDModeCustomView;
//    _hud.delegate = self;
//    _hud.labelText = @"手指上划，取消发送";
//    _hud.labelFont=[UIFont systemFontOfSize:10];
//    [_hud show:YES];
//    
//}
//
//#pragma mark-录音的代理方法
//- (void)recordTool:(LVRecordTool *)recordTool didstartRecoring:(int)no {
//    
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//         NSString *imageName = [NSString stringWithFormat:@"mic_%d", no];
//        _hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"KeyBord/%@",imageName]]];
//        _hud.labelText = @"手指上划，取消发送";
//        
//    });
//  
//}
//
//- (void)recordToolSendVoicePath:(NSString *)voicepath voiceLenth:(double)time
//{
//    [self.delegate sendVoiceContent:voicepath voicelenth:time];
//    
//}



- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    
    NSDictionary *info = [notification userInfo];
    CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect beginKeyboardRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect endKeyboardRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    if (endKeyboardRect.origin.y<beginKeyboardRect.origin.y) {
        if (endKeyboardRect.origin.y<self.frame.origin.y+_lineKeyboardHeight) {
            
            
            CGFloat yOffset = endKeyboardRect.origin.y - beginKeyboardRect.origin.y;
            
            
            CGRect inputFieldRect = self.frame;
            
            if (_isFaceAndMore) {
                yOffset+=_DetailKeyBoardHeight;
                _detailkeyboard.hidden=YES;
                _isFaceAndMore=false;
                
            }
            inputFieldRect.origin.y += yOffset;
            [UIView animateWithDuration:duration animations:^{
                self.frame = inputFieldRect;
                [self.delegate WeChatKeyBoardY:inputFieldRect.origin.y];
                
            }];
            
            
        }
        

    }else{
        CGFloat yOffset = endKeyboardRect.origin.y - beginKeyboardRect.origin.y;
        CGRect inputFieldRect = self.frame;
        if (_isFaceAndMore) {
            yOffset+=_DetailKeyBoardHeight;
            _detailkeyboard.hidden=YES;
            _isFaceAndMore=false;
            
        }
        
        inputFieldRect.origin.y += yOffset;
        NSLog(@"K----%f",inputFieldRect.origin.y);
        
        [UIView animateWithDuration:duration animations:^{
            self.frame = inputFieldRect;
            
            
            [self.delegate WeChatKeyBoardY:inputFieldRect.origin.y];
            
        }];

    
    }
  
    
    

    
    
    
    
}

-(void)scroll:(CGFloat)offset
{
    CGRect inputFieldRect = self.frame;
    inputFieldRect.origin.y += offset;
  
     NSLog(@"F----%f",inputFieldRect.origin.y);
    [UIView animateWithDuration:0.6 animations:^{
        self.frame = inputFieldRect;
          [self.delegate WeChatKeyBoardY:inputFieldRect.origin.y];
    }];
}



//- (BOOL)textFieldShouldReturn:(UITextField *)textField
//{
//
//    [self.delegate sendTextContent:textField.text];
//    [textField resignFirstResponder];
//    textField.text=@"";
//    return YES;
//}




-(void)hideKeyboard{ //做键盘取消的操作
    [_txt resignFirstResponder];
    if (_isFaceAndMore) {
        _detailkeyboard.hidden=NO;
        [self scroll:_DetailKeyBoardHeight];
        
    }
    _isFaceAndMore=false;
}

-(void)setText:(NSString *)txt{
    _txt.text=txt;
}
-(NSString *)getText{
    return  [[NSString alloc] initWithString:_txt.text];
}


#pragma mark-零时文本框代理
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    
    
    if ([text isEqualToString:@"\n"]) {
        
        NSString * str=textView.text;
        
        [textView setText:nil];
        [textView resignFirstResponder];
       
        
    
        
         [textView resignFirstResponder];
         textView.text=@"";
        
        [self.delegate sendTextContent:str];
        
        CGFloat spacewidth=_ScreenWidth/10;//把输入工具栏10等分咯
        CGRect tempA=CGRectMake(0,0, _ScreenWidth, _lineKeyboardHeight);
        CGRect tempB=CGRectMake(20+spacewidth, 7, spacewidth*6, 35);
        _linekeyboard.frame=tempA;
        _txt.frame=tempB;

        
        
        
        return NO;
    }
    
    
    return YES;
    
    
    
    
}

- (void)textViewDidChange:(UITextView *)textView
{
    
    
    UIFont *font = [UIFont systemFontOfSize:15];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    CGSize size = [textView.text boundingRectWithSize:CGSizeMake(textView.frame.size.width, 999) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    float hight=size.height-32;
    
    if (_linekeyboard.frame.size.height<70&&hight>0) {
        
        CGRect tempA=CGRectMake(_linekeyboard.frame.origin.x , (size.height-_linekeyboard.frame.size.height>0?_linekeyboard.frame.origin.y-hight:_linekeyboard.frame.origin.y),_linekeyboard.frame.size.width,49+(hight>0?hight:0));
        CGRect tempB=CGRectMake(textView.frame.origin.x , textView.frame.origin.y ,textView.frame.size.width,size.height >32?size.height:32);
        

        _linekeyboard.frame=tempA;
        _txt.frame=tempB;
        
    }
    
    

    
}


#pragma mark-详细键盘代理事件
- (void) EmojiImageClick:(NSString *)emgname
{
    _txt.text=[NSString stringWithFormat:@"%@%@",_txt.text,emgname];
}

- (void) MoreFunctionChoice:(NSUInteger) funid
{
   [self.delegate choiceFuction:funid];
}
-(void)dealloc{
     [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
   [self.nextResponder touchesBegan:touches withEvent:event];
}


@end
