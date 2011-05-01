//
//  PongVilleViewController.h
//  PongVille
//
//  Created by Derek Zoolander on 4/21/11......
//  Copyright 2011 Rye Designs. All rights reserved.
//  Oogabooga
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "SettingsViewController.h"

@class ARController;

@interface PongVilleViewController : UIViewController <SettingsViewControllerDelegate>{
    ARController *arController;
    
    IBOutlet UIImageView *puck;
    
    IBOutlet UIImageView *computerPaddle;
    IBOutlet UIImageView *userPaddle;
    
    IBOutlet UILabel *instructionMessageLabel;    
    
    IBOutlet UILabel *scoreBoardLabel;
    
    NSInteger userScoreValue;
    NSInteger computerScoreValue;
    
    CGPoint puckVelocity;
    NSInteger gameState;
    CGFloat motionScale;
    CGFloat ballSpeedX;
    CGFloat ballSpeedY;
    CGFloat computerPaddleSpeed;
    NSInteger scoreToWin;
    
    Boolean justHitUserPadle;
    Boolean justHitCompPadle;
    
    NSTimer *scoreBoardMarquee;
}

@property (nonatomic, retain) ARController *arController;

@property(nonatomic,retain) IBOutlet UIImageView *puck;
@property(nonatomic,retain) IBOutlet UIImageView *computerPaddle;
@property(nonatomic,retain) IBOutlet UIImageView *userPaddle;

@property(nonatomic,retain) IBOutlet UILabel *instructionMessageLabel;

@property(nonatomic,retain) IBOutlet UILabel *scoreBoardLabel;

@property(nonatomic) CGPoint puckVelocity;
@property(nonatomic) NSInteger gameState,scoreToWin;
@property(nonatomic) CGFloat motionScale,ballSpeedX,ballSpeedY,computerPaddleSpeed;


@end
