//
//  CameraBottomOverlayView.h
//  CameraPlugin
//
//  Created by jim on 10/14/13.
//
//

#import <UIKit/UIKit.h>

@class CameraBottomOverlayView;

@protocol CameraBottomOverlayDelegate <NSObject>
@optional
- (void)overlayViewDidTapTakePicture:(CameraBottomOverlayView*)ov;
- (void)overlayViewDidTapGallery: (CameraBottomOverlayView*)ov;
- (void)overlayViewDidCancel:(CameraBottomOverlayView*)ov;

@end

@interface CameraBottomOverlayView : UIView
@property (nonatomic) id<CameraBottomOverlayDelegate> delegate;


- (void)setPreview:(UIImage*)previewImage;
@end
