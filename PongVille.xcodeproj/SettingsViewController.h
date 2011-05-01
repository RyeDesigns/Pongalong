//
//  SettingsViewController.h
//  PongVille
//
//  Created by Alex Sheridan on 4/29/11.
//  Copyright 2011 Ohio University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsViewController.h"

#define MOTION_SCALE @"motionScale"
#define BALL_SPEED_X @"ballSpeedX"
#define BALL_SPEED_Y @"ballSpeedY"
#define COMPUTER_PADDLE_SPEED @"computerPaddleSpeed"
#define SCORE_TO_WIN @"scoreToWin"

@protocol SettingsViewControllerDelegate;
@interface SettingsViewController : UIViewController {
    IBOutlet UISlider *motionScaleSlider;
    IBOutlet UISlider *computerPaddleSpeedSlider;
    IBOutlet UISlider *ballSpeedXSlider;
    IBOutlet UISlider *ballSpeedYSlider;
    IBOutlet UISlider *scoreToWin;
    id <SettingsViewControllerDelegate> delegate;
}

@property (assign) IBOutlet UISlider *motionScaleSlider;
@property (assign) IBOutlet UISlider *computerPaddleSpeedSlider;
@property (assign) IBOutlet UISlider *ballSpeedXSlider;
@property (assign) IBOutlet UISlider *ballSpeedYSlider;
@property (assign) IBOutlet UISlider *scoreToWin;
@property (assign) id <SettingsViewControllerDelegate> delegate;

-(IBAction)done;
-(IBAction)motionScaleSliderChanged:(UISlider *)motionScaleSlider;
-(IBAction)computerPaddleSliderChanged:(UISlider *)computerPaddleSpeedSlider;
-(IBAction)ballSpeedXSliderChanged:(UISlider *)ballSpeedXSlider;
-(IBAction)ballSpeedYSliderChanged:(UISlider *)ballSpeedYSlider;
-(IBAction)scoreToWinChanged:(UISlider *)scoreToWin;

@end
