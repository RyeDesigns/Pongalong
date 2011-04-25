//
//  PongVilleViewController.m
//  PongVille
//
//  Created by Alex Sheridan on 4/21/11.
//  Copyright 2011 Ohio University. All rights reserved.
//

#import "PongVilleViewController.h"
#import <CoreMotion/CoreMotion.h>

// Define a bunch of constants
#define GAME_STATE_RUNNING 1
#define GAME_STATE_PAUSED 2
#define MOTION_SCALE 20.0
#define BALL_SPEED_X 6
#define BALL_SPEED_Y 9
#define COMPUTER_PADDLE_SPEED 15
#define SCORE_TO_WIN 3

@implementation PongVilleViewController
@synthesize puck;
@synthesize computerPaddle;
@synthesize userPaddle;
@synthesize instructionMessageLabel;
@synthesize scoreBoardLabel;
@synthesize puckVelocity;
@synthesize gameState;

- (void)dealloc{
    [super dealloc];
}

-(CMMotionManager *)motionManager{
    //NSLog(@"WAS:PongVilleViewController.m:motionManager:A");
    CMMotionManager *motionManager = nil;
    id appDelegate = [UIApplication sharedApplication].delegate;
    if ([appDelegate respondsToSelector:@selector(motionManager)]){
        motionManager = [appDelegate motionManager];
    }
    //NSLog(@"WAS:PongVilleViewController.m:motionManager:Z");
    return motionManager;
}

-(CGRect)calculateNewImageFramewithImageFrame:(CGRect)imageFrameValue withAccelerometer:(CMAccelerometerData *)accelData{
    UIDevice *device = [UIDevice currentDevice];
    
    // Set the buttonFrame x coordinate
        switch (device.orientation) {
        case UIDeviceOrientationPortrait:            
            imageFrameValue.origin.x += accelData.acceleration.x * MOTION_SCALE;            
            break;            
        case UIDeviceOrientationPortraitUpsideDown:            
            imageFrameValue.origin.x += -accelData.acceleration.x * MOTION_SCALE;            
            break;            
        case UIDeviceOrientationLandscapeLeft:            
            imageFrameValue.origin.x += -accelData.acceleration.y * 2 * MOTION_SCALE;            
            break;            
        case UIDeviceOrientationLandscapeRight:            
            imageFrameValue.origin.x += accelData.acceleration.y * 2 * MOTION_SCALE;            
            break;            
        default:
            break;
        }
    return imageFrameValue;
}

-(void)startPaddleDrifting:(UIImageView *)image{
    NSLog(@"WAS:PongVilleViewController.m:startPaddleDrifting:A");
    [self.motionManager 
     startAccelerometerUpdatesToQueue:[[[NSOperationQueue alloc] init] autorelease] 
     withHandler:^(CMAccelerometerData * data, NSError *error){        
         dispatch_async(dispatch_get_main_queue(), ^{
             // Declare the button frame
             CGRect imageFrame = image.frame;
             
             // Set the buttonFrame x coordinate
             //imageFrame.origin.x += data.acceleration.x * MOTION_SCALE;
             imageFrame = [self calculateNewImageFramewithImageFrame:imageFrame withAccelerometer:data];
             
             // If proposed coordinates are out of bounds, keep existing coordinates
             if(!CGRectContainsRect(self.view.bounds, imageFrame)) {
                 imageFrame.origin.x = image.frame.origin.x;
             }else{
                 //NSLog(@"WAS:startPaddleDrifting:x coordinate: in bounds");
             }
             
             // Set the button to the calculated value
             image.frame = imageFrame;
         });
     }];
    NSLog(@"WAS:PongVilleViewController.m:startPaddleDrifting:Z");
}



- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)setTheScoreLabels
{
    scoreBoardLabel.text = [NSString stringWithFormat:@"You:%d|%d:The Computer", userScoreValue,computerScoreValue];
}


// TODO: Rewrite me. 
-(void)reset:(BOOL) newGame{
    NSLog(@"WAS:PongVilleViewController.m:reset:A");
    
    // Put the game into a paused state
    self.gameState = GAME_STATE_PAUSED;
    
    // Center the puck
    CGRect screen = [[UIScreen mainScreen] bounds];
    float y = UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]) ? screen.size.width/2  : screen.size.height/2;    
    float x = UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]) ? screen.size.height/2 : screen.size.width/2;
    puck.center = CGPointMake(x, y);
    
    
    if(newGame){
        //NSLog(@"WAS:PongVilleViewController.m:reset:newGame == true");
        if(computerScoreValue > userScoreValue){
            instructionMessageLabel.text = @"You lost and shamed your family. Tap to begin again.";
        }else{
            instructionMessageLabel.text = @"You won, most likely by cheating. Tap to begin again.";
        }
        instructionMessageLabel.hidden = NO;
        computerScoreValue = 0;
        userScoreValue = 0;
    }else{
        //NSLog(@"WAS:PongVilleViewController.m:reset:newGame == false");
        instructionMessageLabel.text = @"Tap to resume";
        instructionMessageLabel.hidden = NO;
    }
    
    // Set the score labels
    [self setTheScoreLabels];    

    
    NSLog(@"WAS:PongVilleViewController.m:reset:Z");
}



-(void)performPuckLogic
{
    // Calculate the puck center
    puck.center = CGPointMake(puck.center.x + puckVelocity.x, puck.center.y + puckVelocity.y);
    
    // If the puck has hit a side wall, reverse the puck velocity
    if(puck.center.x > self.view.bounds.size.width || puck.center.x < 0){
        puckVelocity.x = -puckVelocity.x;
    }
    
    // If the puck has hit a wall, reverse the puck velocity
    if(puck.center.y > self.view.bounds.size.height || puck.center.y < 0){
        puckVelocity.y = -puckVelocity.y;
    }
    
    // If the puck has hit the computer paddle, reverse the velocity
    if(CGRectIntersectsRect(puck.frame,userPaddle.frame)) {
        if(puck.center.y < userPaddle.center.y) {
            puckVelocity.y = -puckVelocity.y;
        }
    }
    
    // If the puck has hit the user paddle, reverse the velocity
    if(CGRectIntersectsRect(puck.frame,computerPaddle.frame)) {
        if(puck.center.y > computerPaddle.center.y) {
            puckVelocity.y = -puckVelocity.y;
        }
    }
}

-(void)performSmartAI{
    // Begin the super advanced artificial intelligence
    if(puck.center.y <= self.view.center.y){
        
        if(puck.center.x < computerPaddle.center.x){
            CGPoint compLocation = CGPointMake(computerPaddle.center.x - COMPUTER_PADDLE_SPEED, computerPaddle.center.y);
            computerPaddle.center = compLocation;
        }
        
        if(puck.center.x > computerPaddle.center.x){
            CGPoint compLocation = CGPointMake(computerPaddle.center.x + COMPUTER_PADDLE_SPEED, computerPaddle.center.y);
            computerPaddle.center = compLocation;
        }
    } 
}

-(void)performTerribleAI{
    // Begin the dumb artificial intelligence
    if(puck.center.y <= (self.view.center.y *2/3)){
        
        if(puck.center.x < computerPaddle.center.x){
            CGPoint compLocation = CGPointMake(computerPaddle.center.x - COMPUTER_PADDLE_SPEED, computerPaddle.center.y);
            computerPaddle.center = compLocation;
        }
        
        if(puck.center.x > computerPaddle.center.x){
            CGPoint compLocation = CGPointMake(computerPaddle.center.x + COMPUTER_PADDLE_SPEED, computerPaddle.center.y);
            computerPaddle.center = compLocation;
        }
    } 
}


// This function calls the appropriate AI function
// TODO: make the difficulty level adjustable
-(void)performArtificialIntelligence
{
    //[self performSmartAI];
    [self performTerribleAI];
}

-(void)performScoringLogic
{
    // Begin Scoring Logic
    if(puck.center.y <= 0){
        userScoreValue = userScoreValue +1;
        NSLog(@"WAS:performScoringLogic:about to call reset:A");
        [self reset:(userScoreValue >= SCORE_TO_WIN)];
    }else if(puck.center.y > self.view.bounds.size.height){
        computerScoreValue = computerScoreValue +1;
        NSLog(@"WAS:performScoringLogic:about to call reset:B");
        [self reset:(computerScoreValue >= SCORE_TO_WIN)];
    }
}

-(void) flowCycle
{
    if(gameState == GAME_STATE_RUNNING){
        
        // Perform the puck logic
        [self performPuckLogic];
        
        // Perform the AI for the computer paddle
        [self performArtificialIntelligence];
        
        // Perform scoring logic
        [self performScoringLogic];
        
    }else if(gameState == GAME_STATE_PAUSED){
        // Do nothing 
    }else{
        NSLog(@"WAS:PongVilleViewController.m:flowCycle:how did you get here ?");
    }
    
}

-(void)pauseGame
{
    instructionMessageLabel.text = @"Tap to unpause";
    instructionMessageLabel.hidden = NO;
    gameState = GAME_STATE_PAUSED;
}

-(void)displayInitialPrompt
{
    instructionMessageLabel.text = @"Tap to begin";
    instructionMessageLabel.hidden = NO;
    gameState = GAME_STATE_PAUSED;
}

-(void)unPauseGame
{
    instructionMessageLabel.hidden = YES;
    gameState = GAME_STATE_RUNNING;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(gameState == GAME_STATE_PAUSED){
        [self unPauseGame];
    }else if(gameState == GAME_STATE_RUNNING){
        [self pauseGame];
    }
}





- (void)scoreBoardMarquee:(NSTimer *)timer{
    if(scoreBoardLabel.text.length >1){
        scoreBoardLabel.text = 
        [NSString stringWithFormat:@"%@%c", 
         [scoreBoardLabel.text substringFromIndex:1],
         [scoreBoardLabel.text characterAtIndex:0]];
    }
}


- (void)doScoreMarqueeMagic
{
    if (!scoreBoardMarquee) {
        scoreBoardMarquee = 
        [NSTimer scheduledTimerWithTimeInterval:0.35 
                                         target:self 
                                       selector:@selector(scoreBoardMarquee:) 
                                       userInfo:nil 
                                        repeats:YES];
    }
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self displayInitialPrompt];
    puckVelocity = CGPointMake(BALL_SPEED_X, BALL_SPEED_Y);
    [NSTimer scheduledTimerWithTimeInterval:0.05 
                                     target:self 
                                   selector:@selector(flowCycle) 
                                   userInfo:nil 
                                    repeats:YES];
    //[self doScoreMarqueeMagic];
}

-(void)viewDidAppear:(BOOL)animated
{
    NSLog(@"WAS:PongVilleViewController.m:viewDidAppear:A");
    
    //    UITapGestureRecognizer *tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    //    [self.view addGestureRecognizer:tapgr];
    //    [tapgr release];
    
    [super viewDidAppear:animated];
    [self startPaddleDrifting:userPaddle];
    
    // Set the score labels
    [self setTheScoreLabels];
    
    NSLog(@"WAS:PongVilleViewController.m:viewDidAppear:Z");
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}


// TODO: Fix the core motion such that it rotates along with the screen orientation
// TODO: The problem is that the screen will rotate just fine into other orientations,
// but the core motion sticks with its original settings!
-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    NSLog(@"Rotating!");
    [self pauseGame];
    
    // Put the next two calls into their own function
    // [self.motionManager stopAccelerometerUpdates];
    // [self startPaddleDrifting:userPaddle];    
}

@end
