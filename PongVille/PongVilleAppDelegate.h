//
//  PongVilleAppDelegate.h
//  PongVille
//
//  Created by Alex Sheridan on 4/21/11.
//  Copyright 2011 Ohio University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

@class PongVilleViewController;

@interface PongVilleAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    PongVilleViewController *viewController;
    CMMotionManager *motionManager;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet PongVilleViewController *viewController;
@property (readonly) CMMotionManager *motionManager;

@end
