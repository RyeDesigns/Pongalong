//
//  SettingsViewController.h
//  PongVille
//
//  Created by Alex Sheridan on 4/29/11.
//  Copyright 2011 Ohio University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsViewController.h"

@protocol SettingsViewControllerDelegate;
@interface SettingsViewController : UIViewController {
    IBOutlet NSInteger computerPaddleSpeed;
    IBOutlet UISlider *computerPaddleSpeedSlider;
    id <SettingsViewControllerDelegate> delegate;
}


@property (assign) NSInteger computerPaddleSpeed;
@property (assign) IBOutlet UISlider *computerPaddleSpeedSlider;
@property (assign) id <SettingsViewControllerDelegate> delegate;

-(IBAction)done;
-(IBAction)computerPaddleSliderChanged:(UISlider *)computerPaddleSpeedSlider;

@end

@protocol SettingsViewControllerDelegate 
-(void)settingsViewController:(SettingsViewController *)_settingsViewController 
      withComputerPaddleSpeed:(NSInteger)_computerPaddleSpeed;
                 


@end
