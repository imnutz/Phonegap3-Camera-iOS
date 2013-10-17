//
//  CameraTopOverlayView.m
//  CameraPlugin
//
//  Created by jim on 10/14/13.
//
//

#import "CameraTopOverlayView.h"
@interface CameraTopOverlayView()
@property (nonatomic, assign) IBCameraDevice currentDevice;
@property (nonatomic, strong) UIButton *btnFlash;
@property (nonatomic, strong) UIButton *btnCameraSwitcher;
@end

@implementation CameraTopOverlayView
@synthesize flashOn = _flashOn;
@synthesize currentDevice = _currentDevice;
@synthesize btnFlash = _btnFlash;
@synthesize btnCameraSwitcher = _btnCameraSwitcher;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.flashOn = NO;
        self.currentDevice = CAMERA_REAR;
        
        self.btnFlash = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.btnFlash setImage:[UIImage imageNamed:@"flash_off.png"] forState:UIControlStateNormal];
        [self.btnFlash setImage:[UIImage imageNamed:@"flash_on.png"] forState:UIControlStateSelected];
        [self.btnFlash setSelected:self.flashOn];
        [self.btnFlash sizeToFit];
        
        self.btnCameraSwitcher = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.btnCameraSwitcher setImage:[UIImage imageNamed:@"camera_switcher.png"] forState:UIControlStateNormal];
        [self.btnCameraSwitcher sizeToFit];
        [self.btnCameraSwitcher addTarget:self action:@selector(switcherHandler:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:self.btnFlash];
        [self addSubview:self.btnCameraSwitcher];
        
        [self addObserver:self forKeyPath:@"flashOn" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"flashOn"]) {
        BOOL newValue = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        if (!newValue) {
            [self disableFlash];
        } else {
            [self enableFlash];
        }
    }
}

- (void)layoutSubviews
{
    CGRect viewFrame = self.frame;
    
    CGRect flashFrame = self.btnFlash.frame;
    CGRect switcherFrame = self.btnCameraSwitcher.frame;
    
    float fx = 5.0f;
    float fy = (viewFrame.size.height - flashFrame.size.height) * 0.5f;
    flashFrame.origin.x = fx;
    flashFrame.origin.y = fy;
    
    float sx = (viewFrame.size.width - switcherFrame.size.width - 5.0f);
    float sy = (viewFrame.size.height - switcherFrame.size.height) * 0.5f;
    switcherFrame.origin.x = sx;
    switcherFrame.origin.y = sy;
    
    [self.btnFlash setFrame:flashFrame];
    [self.btnCameraSwitcher setFrame:switcherFrame];
}
- (void)switchSwitcherOff
{
    [self.btnCameraSwitcher setHidden:YES];
}
- (void)disableFlash
{
    [self.btnFlash setSelected:NO];
    [self.btnFlash setEnabled:NO];
}
- (void)enableFlash
{
    [self.btnFlash setSelected:YES];
    [self.btnFlash setEnabled:YES];
}
- (void)switcherHandler:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(overlayView:switchedToCameraDevice:)]) {
        IBCameraDevice device = CAMERA_REAR;
        
        if (self.currentDevice == CAMERA_REAR) {
            device = CAMERA_FRONT;
        }
        self.currentDevice = device;
        [self.delegate overlayView:self switchedToCameraDevice:device];
    }
}

- (void)removeObserver
{
    [self removeObserver:self forKeyPath:@"flashOn"];
}
@end
