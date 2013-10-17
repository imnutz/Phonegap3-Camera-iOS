//
//  CameraPlugin.m
//  CameraPlugin
//
//  Created by jim on 10/14/13.
//
//

#import "CameraPlugin.h"
#import <AssetsLibrary/AssetsLibrary.h>

typedef enum
{
    DATA = 1,
    FILE_URL
}IBDestinationType;

#define kIBCP_TOPOVERLAY_HEIGHT 64
#define kIBCP_BOTTOMOVERLAY_HEIGHT 100

#define kIBCP_CROP_WIDTH 320
#define kIBCP_CROP_HEIGHT 320

@interface BackgroundColorLayer: NSObject
+ (CAGradientLayer*)bgLayer;
@end
@implementation BackgroundColorLayer

+ (CAGradientLayer*)bgLayer
{
    UIColor *colorOne = [UIColor colorWithRed:(47/255.0)  green:(139/255.0)  blue:(203/255.0)  alpha:1.0];
    UIColor *colorTwo = [UIColor colorWithRed:(33/255.0) green:(58/255.0) blue:(121/255.0) alpha:1.0];
    
    NSArray *colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, colorTwo.CGColor, nil];
    NSNumber *stopOne = [NSNumber numberWithFloat:0.0];
    NSNumber *stopTwo = [NSNumber numberWithFloat:1.0];
    
    NSArray *locations = [NSArray arrayWithObjects:stopOne, stopTwo, nil];
    
    CAGradientLayer *background = [CAGradientLayer layer];
    background.colors = colors;
    background.locations = locations;
    
    return background;
}
@end

@interface ImageHelper
+ (NSString*)applicationDocumentsDirectory;
+ (void)saveImage:(UIImage*)img withName:(NSString*)name;
+ (NSString*)imagePath:(NSString*)name;
@end
@implementation ImageHelper
+ (NSString *)applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}
+ (void)saveImage:(UIImage *)image withName:(NSString *)name {
    NSData *data = UIImagePNGRepresentation(image);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *fullPath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:name];
    [fileManager createFileAtPath:fullPath contents:data attributes:nil];
}
+ (NSString*)imagePath:(NSString *)name
{
    NSString *fullPath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:name];
    
    return fullPath;
}
@end

@interface CameraPlugin()
{
    BOOL shouldSaveOriginalImage;
    NSString *callbackId;
    IBDestinationType destinationType;
}
@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic) CameraTopOverlayView *topOverlay;
@property (nonatomic) CameraBottomOverlayView *bottomOverlay;
@end

@implementation CameraPlugin
@synthesize imagePickerController = _imagePickerController;
@synthesize topOverlay = _topOverlay;
@synthesize bottomOverlay = _bottomOverlay;

- (void)getPicture:(CDVInvokedUrlCommand *)command
{
//    CDVPluginResult *pluginResult = NULL;
    NSArray *params = command.arguments;
    
    callbackId = command.callbackId;
    
    NSNumber *shouldSaveFlag = [params objectAtIndex:0];
    shouldSaveOriginalImage = [shouldSaveFlag boolValue];
    
    NSNumber *destType = [params objectAtIndex:1];
    if ([destType intValue] == DATA) {
        destinationType = DATA;
    } else {
        destinationType = FILE_URL;
    }
    
    [self showPickerForSourceType:UIImagePickerControllerSourceTypeCamera];
    
//    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)showPickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    self.imagePickerController.delegate = self;
    self.imagePickerController.sourceType = sourceType;
    
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        self.imagePickerController.showsCameraControls = NO;
        
        // Create overlays
        CGRect pickerFrame = self.imagePickerController.view.frame;
        CGRect topFrame = CGRectMake(0.0, 0.0, pickerFrame.size.width, kIBCP_TOPOVERLAY_HEIGHT);
        
        self.topOverlay = [[CameraTopOverlayView alloc] initWithFrame:topFrame];
        CAGradientLayer *topBgLayer = [BackgroundColorLayer bgLayer];
        topBgLayer.frame = self.topOverlay.bounds;
        
        [self.topOverlay.layer insertSublayer:topBgLayer atIndex:0];
        self.topOverlay.delegate = self;
        if (![UIImagePickerController isFlashAvailableForCameraDevice:UIImagePickerControllerCameraDeviceRear]) {
            [self.topOverlay setFlashOn:NO];
        }
        if (![UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
            [self.topOverlay switchSwitcherOff];
        }
        [self.imagePickerController.cameraOverlayView addSubview:self.topOverlay];
        
        CGRect bottomFrame = CGRectMake(0.0, pickerFrame.size.height - kIBCP_BOTTOMOVERLAY_HEIGHT, pickerFrame.size.width, kIBCP_BOTTOMOVERLAY_HEIGHT);
        self.bottomOverlay = [[CameraBottomOverlayView alloc] initWithFrame:bottomFrame];
        CAGradientLayer *bottomBgLayer = [BackgroundColorLayer bgLayer];
        bottomBgLayer.frame = [self.bottomOverlay bounds];
        
        [self.bottomOverlay.layer insertSublayer:bottomBgLayer atIndex:0];
        self.bottomOverlay.delegate = self;
        [self.imagePickerController.cameraOverlayView addSubview:self.bottomOverlay];
    }
    [self.viewController presentModalViewController:self.imagePickerController animated:YES];
}

- (void)processImage:(UIImage*)image withInfo:(NSDictionary *)info
{
    CDVPluginResult *pluginResult = nil;
    
    if (image) {
        if (destinationType == DATA) {
            NSData *data = UIImagePNGRepresentation(image);
            if (data) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[data base64Encoding]];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Cannot extract image's information"];
            }
        } else if(destinationType == FILE_URL) {
            NSString *fileName = [NSString stringWithFormat:@"%d.%s", (int)CACurrentMediaTime(), "png"];
//            NSString *nativeUrl =[(NSURL*)[info objectForKey:UIImage]]
            [ImageHelper saveImage:image withName:fileName];
            
            NSMutableDictionary *returnDict = [[NSMutableDictionary alloc] init];
            [returnDict setValue:fileName forKey:@"file_name"];
            [returnDict setValue:[ImageHelper imagePath:fileName] forKey:@"image_url"];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:returnDict];
        }
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Image hasn't been taken!"];
    }
    
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

#pragma mark - Top overlay delegate
- (void)overlayView:(CameraTopOverlayView *)ov changedFlashState:(BOOL)flag
{

}
- (void)overlayView:(CameraTopOverlayView *)ov switchedToCameraDevice:(IBCameraDevice)device
{
    if (self.imagePickerController) {
        if (device == CAMERA_REAR) {
            self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        } else if(device == CAMERA_FRONT) {
            self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
    }
}
#pragma mark - Bottom overlay delegate
- (void)overlayViewDidTapTakePicture:(CameraBottomOverlayView *)ov
{
    if (self.imagePickerController) {
        [self.imagePickerController takePicture];
    }
}
- (void)overlayViewDidTapGallery:(CameraBottomOverlayView *)ov
{
    if (self.imagePickerController) {
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
}
- (void)overlayViewDidCancel:(CameraBottomOverlayView *)ov
{
    [self dismissPicker];
}
#pragma mark - UIImagePickerController delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *takenImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    UIImage *finalImage = nil;
    
    if (self.imagePickerController.sourceType == UIImagePickerControllerSourceTypeCamera) {
        if (shouldSaveOriginalImage) {
            ALAssetsLibrary *library = [ALAssetsLibrary new];
            [library writeImageToSavedPhotosAlbum:[takenImage CGImage] orientation:(ALAssetOrientation)([takenImage imageOrientation]) completionBlock:NULL];
        }
        CGSize cropSize = CGSizeMake(kIBCP_CROP_WIDTH, kIBCP_CROP_HEIGHT);
        UIImage *cropImage = [self imageByScalingAndCroppingForSize:takenImage toSize:cropSize];
        if (cropImage) {
            finalImage = cropImage;
            [self.bottomOverlay setPreview:cropImage];
        }
    }
    if (finalImage) {
        [self processImage:finalImage withInfo:info];
    } else {
        [self processImage:takenImage withInfo:info];
    }
    
    [self dismissPicker];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissPicker];
}

- (void)dismissPicker
{
    if (self.imagePickerController) {
        [self.imagePickerController dismissModalViewControllerAnimated:YES];
    }
    [self.topOverlay removeObserver];
    self.topOverlay = nil;
    self.bottomOverlay = nil;
    self.imagePickerController = nil;
}

- (UIImage*)imageByScalingAndCroppingForSize:(UIImage*)anImage toSize:(CGSize)targetSize
{
    UIImage* sourceImage = anImage;
    UIImage* newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor) {
            scaleFactor = widthFactor; // scale to fit height
        } else {
            scaleFactor = heightFactor; // scale to fit width
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        } else if (widthFactor < heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if (newImage == nil) {
        NSLog(@"could not scale image");
    }
    
    // pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}
@end
