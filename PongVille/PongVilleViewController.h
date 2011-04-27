//
//  PongVilleViewController.h
//  PongVille
//
//  Created by Derek Zoolander on 4/21/11......
//  Copyright 2011 Ohio University. All rights reserved.
//  Oogabooga
//

#import <UIKit/UIKit.h>

@interface PongVilleViewController : UIViewController {
    IBOutlet UIImageView *puck;
    
    IBOutlet UIImageView *computerPaddle;
    IBOutlet UIImageView *userPaddle;
    
    IBOutlet UILabel *instructionMessageLabel;    
    
    IBOutlet UILabel *scoreBoardLabel;
    
    NSInteger userScoreValue;
    NSInteger computerScoreValue;
    
    CGPoint puckVelocity;
    NSInteger gameState;
    
    NSTimer *scoreBoardMarquee;
}

@property(nonatomic,retain) IBOutlet UIImageView *puck;
@property(nonatomic,retain) IBOutlet UIImageView *computerPaddle;
@property(nonatomic,retain) IBOutlet UIImageView *userPaddle;

@property(nonatomic,retain) IBOutlet UILabel *instructionMessageLabel;

@property(nonatomic,retain) IBOutlet UILabel *scoreBoardLabel;

@property(nonatomic) CGPoint puckVelocity;
@property(nonatomic) NSInteger gameState;


@end
