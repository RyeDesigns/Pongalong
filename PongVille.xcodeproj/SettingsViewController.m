//
//  SettingsViewController.m
//  PongVille
//
//  Created by Alex Sheridan on 4/29/11.
//  Copyright 2011 Ohio University. All rights reserved.
//

#import "SettingsViewController.h"

@implementation SettingsViewController
@synthesize delegate;
@synthesize motionScaleSlider,computerPaddleSpeedSlider,ballSpeedXSlider,ballSpeedYSlider,scoreToWin;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(IBAction)motionScaleSliderChanged:(UISlider *)_motionScaleSlider{   
    [[NSUserDefaults standardUserDefaults] setFloat:_motionScaleSlider.value forKey:MOTION_SCALE];
}
-(IBAction)computerPaddleSliderChanged:(UISlider *)_computerPaddleSpeedSlider{   
    [[NSUserDefaults standardUserDefaults] setFloat:_computerPaddleSpeedSlider.value forKey:COMPUTER_PADDLE_SPEED];
}
-(IBAction)ballSpeedXSliderChanged:(UISlider *)_ballSpeedXSlider{   
    [[NSUserDefaults standardUserDefaults] setFloat:_ballSpeedXSlider.value forKey:BALL_SPEED_X];
}
-(IBAction)ballSpeedYSliderChanged:(UISlider *)_ballSpeedYSlider{   
    [[NSUserDefaults standardUserDefaults] setFloat:_ballSpeedYSlider.value forKey:BALL_SPEED_Y];
}
-(IBAction)scoreToWinChanged:(UISlider *)_scoreToWin{   
    [[NSUserDefaults standardUserDefaults] setFloat:_scoreToWin.value forKey:SCORE_TO_WIN];
}

-(void)viewWillAppear:(BOOL)animated{
    self.motionScaleSlider.value 
        = [[NSUserDefaults standardUserDefaults] floatForKey:MOTION_SCALE];
    self.computerPaddleSpeedSlider.value 
        = [[NSUserDefaults standardUserDefaults] floatForKey:COMPUTER_PADDLE_SPEED];
    self.ballSpeedXSlider.value 
        = [[NSUserDefaults standardUserDefaults] floatForKey:BALL_SPEED_X];
    self.ballSpeedYSlider.value 
        = [[NSUserDefaults standardUserDefaults] floatForKey:BALL_SPEED_Y];
    self.scoreToWin.value 
        = [[NSUserDefaults standardUserDefaults] floatForKey:SCORE_TO_WIN];
    
    [super viewWillAppear:animated];
}

- (void)dealloc
{
    [super dealloc];
    //[computerPaddleSpeedSlider release];
}

-(IBAction)done{    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.computerPaddleSpeedSlider = nil;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
