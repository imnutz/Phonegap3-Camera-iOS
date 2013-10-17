//
//  CameraPlugin.h
//  CameraPlugin
//
//  Created by jim on 10/14/13.
//
//

#import <Cordova/CDVPlugin.h>
#import "CameraTopOverlayView.h"
#import "CameraBottomOverlayView.h"

@interface CameraPlugin : CDVPlugin<CameraTopOverlayDelegate, CameraBottomOverlayDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

- (void)getPicture:(CDVInvokedUrlCommand*)command;

@end
