//
//  CameraTopOverlayView.h
//  CameraPlugin
//
//  Created by jim on 10/14/13.
//
//

#import <UIKit/UIKit.h>
typedef enum
{
    CAMERA_REAR = 0,
    CAMERA_FRONT
} IBCameraDevice;

@class CameraTopOverlayView;

@protocol CameraTopOverlayDelegate <NSObject>
@optional
- (void)overlayView:(CameraTopOverlayView*)ov changedFlashState:(BOOL)flag;
- (void)overlayView:(CameraTopOverlayView*)ov switchedToCameraDevice:(IBCameraDevice)device;
@end

@interface CameraTopOverlayView : UIView
@property (nonatomic, assign) BOOL  flashOn;
@property (nonatomic) id<CameraTopOverlayDelegate> delegate;

- (void)switchSwitcherOff;
- (void)removeObserver;
@end
