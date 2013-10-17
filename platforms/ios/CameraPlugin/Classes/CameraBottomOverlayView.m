//
//  CameraBottomOverlayView.m
//  CameraPlugin
//
//  Created by jim on 10/14/13.
//
//

#import "CameraBottomOverlayView.h"

#define kIBCP_PREVIEW_WIDTH 50
#define kIBCP_PREVIEW_HEIGHT 50

@interface CameraBottomOverlayView()
@property (nonatomic) UIButton  *btnTakePicture;
@property (nonatomic) UIImageView *imgvPreview;
@property (nonatomic) UIButton *btnCancel;
@end

@implementation CameraBottomOverlayView
@synthesize btnTakePicture = _btnTakePicture;
@synthesize imgvPreview = _imgvPreview;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.btnTakePicture = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.btnTakePicture setImage:[UIImage imageNamed:@"take_picture.png"] forState:UIControlStateNormal];
        [self.btnTakePicture addTarget:self action:@selector(takePictureHandler:) forControlEvents:UIControlEventTouchUpInside];
        [self.btnTakePicture sizeToFit];
        
        self.btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.btnCancel setTitle:@"Cancel" forState:UIControlStateNormal];
        [self.btnCancel addTarget:self action:@selector(cancelHandler:) forControlEvents:UIControlEventTouchUpInside];
        [self.btnCancel sizeToFit];

        self.imgvPreview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gallery.png"]];
        self.imgvPreview.userInteractionEnabled = YES;
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapPreviewImage:)];
        [self.imgvPreview addGestureRecognizer:gesture];
        
        [self addSubview:self.btnTakePicture];
        [self addSubview:self.btnCancel];
        [self addSubview:self.imgvPreview];
    }
    return self;
}

- (void)setPreview:(UIImage *)previewImage
{
    [self.imgvPreview setImage:previewImage];
}

- (void)didTapPreviewImage:(UIGestureRecognizer*)sender
{
    if ([self.delegate respondsToSelector:@selector(overlayViewDidTapGallery:)]) {
        [self.delegate overlayViewDidTapGallery:self];
    }
}

- (void)takePictureHandler:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(overlayViewDidTapTakePicture:)]) {
        [self.delegate overlayViewDidTapTakePicture:self];
    }
}
- (void)cancelHandler:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(overlayViewDidCancel:)]) {
        [self.delegate overlayViewDidCancel:self];
    }
}
- (void)layoutSubviews
{
    CGRect viewFrame = self.frame;
    
    CGRect btnFrame = self.btnTakePicture.frame;
    CGRect cancelFrame = self.btnCancel.frame;
    CGRect imgvFrame = self.imgvPreview.frame;
    
    float btnX = (viewFrame.size.width - btnFrame.size.width) * 0.5f;
    float btnY = (viewFrame.size.height - btnFrame.size.height) * 0.5f;
    
    imgvFrame.origin.x = (viewFrame.size.width - kIBCP_PREVIEW_WIDTH - 5.0f);
    imgvFrame.origin.y = (viewFrame.size.height - kIBCP_PREVIEW_HEIGHT) * 0.5f;
    imgvFrame.size.width = kIBCP_PREVIEW_WIDTH;
    imgvFrame.size.height = kIBCP_PREVIEW_HEIGHT;
    [self.imgvPreview setFrame:imgvFrame];
    
    btnFrame.origin.x = btnX;
    btnFrame.origin.y = btnY;
    [self.btnTakePicture setFrame:btnFrame];
    
    cancelFrame.origin.x = 5.0f;
    cancelFrame.origin.y = (viewFrame.size.height - cancelFrame.size.height) * 0.5f;
    [self.btnCancel setFrame:cancelFrame];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
