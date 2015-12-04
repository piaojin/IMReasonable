//
//  PostTalkkingViewController.m
//  IMReasonable
//
//  Created by 翁金闪 on 15/12/1.
//  Copyright © 2015年 Reasonable. All rights reserved.
//

#import "PostTalkkingViewController.h"
#import "PJTextView.h"

#define MARGEN_X 8
#define MARGEN_Y 8
#define HEIGHT 128
#define ADDPHOTO_COUNT 3

@interface PostTalkkingViewController()

@property (weak, nonatomic)UIButton *addPhoto;
@property(weak,nonatomic) PJTextView *talkContent;
@property(nonatomic,assign)int index_x;
@property(nonatomic,assign)int index_y;
//当前未添加图片的按钮
@property(nonatomic,weak)UIButton *currentAddPhotoButton;
//存放有所有的按钮(即存放所有的图片)
@property(nonatomic,strong)NSMutableArray *addPhotoButtonArray;
//按钮的大小
@property(nonatomic,assign)int addPhotoWidth;
@property(nonatomic,assign)int maxYoftalkContent;
//按钮个数
@property(nonatomic,assign)int buttonCount;


@end

@implementation PostTalkkingViewController

-(NSMutableArray *)addPhotoButtonArray{
    if(_addPhotoButtonArray==nil){
        
        _addPhotoButtonArray=[NSMutableArray array];
    }
    return _addPhotoButtonArray;
}

-(void)viewDidLoad{
    
    [super viewDidLoad];
    [self initController];
    [self initView];
}

-(void)initController{
    UIBarButtonItem *leftButton=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    UIBarButtonItem *rightButton=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(send)];
    self.navigationItem.leftBarButtonItem=leftButton;
    self.navigationItem.rightBarButtonItem=rightButton;
}

-(void)initView{
    self.view.backgroundColor=[UIColor whiteColor];
    PJTextView *talkContent=[[PJTextView alloc] init];
    talkContent.placehoder=NSLocalizedString(@"IDEA", nil);
    talkContent.frame=CGRectMake(MARGEN_X, STATUSBAR_HEIGHT+MARGEN_Y, SCREENWIDTH-2*MARGEN_X, HEIGHT);
    [self.view addSubview:talkContent];
    self.talkContent=talkContent;
    talkContent.alwaysBounceVertical=YES;
    self.addPhotoWidth=(SCREENWIDTH-((1+ADDPHOTO_COUNT)*MARGEN_X))/ADDPHOTO_COUNT;
    self.maxYoftalkContent=CGRectGetMaxY(self.talkContent.frame);
    [self addButton];
//    for(int i=0;i<ADDPHOTO_COUNT;i++){
//        UIButton *addPhoto=[[UIButton alloc] init];
//        [addPhoto setImage:[UIImage imageNamed:@"addpic_unfocused"] forState:UIControlStateNormal];
//        [addPhoto setImage:[UIImage imageNamed:@"addpic_focused"] forState:UIControlStateHighlighted];
//        [self.view addSubview:addPhoto];
//        addPhoto.frame=CGRectMake(i*addPhotoWidth+(i+1)*MARGEN_X, y+MARGEN_Y, addPhotoWidth, addPhotoWidth);
//    }
}

-(void)addButton{
    UIButton *addPhoto=[[UIButton alloc] init];
    [addPhoto setImage:[UIImage imageNamed:@"addpic_unfocused"] forState:UIControlStateNormal];
    [addPhoto setImage:[UIImage imageNamed:@"addpic_focused"] forState:UIControlStateHighlighted];
    [self.view addSubview:addPhoto];
    addPhoto.frame=CGRectMake(self.index_x*self.addPhotoWidth+(self.index_x+1)*MARGEN_X, self.maxYoftalkContent+self.index_y*self.addPhotoWidth+(self.index_y+1)*MARGEN_Y, self.addPhotoWidth, self.addPhotoWidth);
    [addPhoto addTarget:self action:@selector(addPhoto:) forControlEvents:UIControlEventTouchUpInside];
    self.currentAddPhotoButton=addPhoto;
}

-(void)send{
    
}

-(void)cancel{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)addPhoto:(id)button{
    [self imagefromwhere];
}

#pragma mark -图片源函数
- (void)imagefromwhere
{
    UIActionSheet* action;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        action = [[UIActionSheet alloc] initWithTitle:nil delegate:(id)self cancelButtonTitle:NSLocalizedString(@"lbTCancle", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"lbTPhonto", nil), NSLocalizedString(@"lbTShoot", nil), nil];
    }
    else {
        
        action = [[UIActionSheet alloc] initWithTitle:nil delegate:(id)self cancelButtonTitle:NSLocalizedString(@"lbTCancle", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"lbTPhonto", nil), nil];
    }
    
    action.actionSheetStyle = UIActionSheetStyleAutomatic;
    [action showInView:self.view];
}

- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
        NSUInteger sourceType = 0;
        // 判断是否支持相机
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            switch (buttonIndex) {
                case 0:
                    //相册
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    break;
                case 1:
                    // 相机
                    sourceType = UIImagePickerControllerSourceTypeCamera;
                    break;
                case 2:
                    // 取消
                    return;
            }
        }
        else {
            if (buttonIndex == 0) {
                sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
            else {
                return;
            }
        }
        
        UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = (id)self;
        imagePickerController.allowsEditing = YES;
        imagePickerController.sourceType = sourceType;
        [self presentViewController:imagePickerController
                           animated:YES
                         completion:^{
                         }];
}
#pragma mark -图片设置到控件
- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
{
    [picker dismissViewControllerAnimated:YES
                               completion:^{
                               }];
    
    UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    [self.currentAddPhotoButton setImage:image forState:UIControlStateNormal];
    self.buttonCount++;
    if((self.index_x+1)==ADDPHOTO_COUNT){
        
        self.index_x=0;
        if(self.index_y==1){
            
            self.index_y=0;
        }else{
            
            self.index_y++;
        }
    }else{
        
        self.index_x++;
    }
    
    if((self.buttonCount+1)<=2*ADDPHOTO_COUNT){
        
        [self addButton];
    }
    /* 此处info 有六个值
     * UIImagePickerControllerMediaType; // an NSString UTTypeImage)
     * UIImagePickerControllerOriginalImage;  // a UIImage 原始图片
     * UIImagePickerControllerEditedImage;    // a UIImage 裁剪后图片
     * UIImagePickerControllerCropRect;       // an NSValue (CGRect)
     * UIImagePickerControllerMediaURL;       // an NSURL
     * UIImagePickerControllerReferenceURL    // an NSURL that references an asset in the AssetsLibrary framework
     * UIImagePickerControllerMediaMetadata    // an NSDictionary containing metadata from a captured photo
     */
    // 保存图片至本地，方法见下文
}

@end
