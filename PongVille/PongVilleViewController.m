//
//  PongVilleViewController.m
//  PongVille
//
//  Created by Derek Zoolander on The End of Days
//  Copyright 2011 Rye Designs. All rights reserved.
//

#import "PongVilleViewController.h"
#import <CoreMotion/CoreMotion.h>
#import "ARController.h"
#import "SettingsViewController.h"

// Define a bunch of constants
#define GAME_STATE_RUNNING 1
#define GAME_STATE_PAUSED 2
#define DEFAULT_MOTION_SCALE 20.0
#define DEFAULT_BALL_SPEED_X 6.0
#define DEFAULT_BALL_SPEED_Y 9.0
#define DEFAULT_COMPUTER_PADDLE_SPEED 30.0
#define DEFAULT_SCORE_TO_WIN 3

@implementation PongVilleViewController

@synthesize arController;

@synthesize puck;
@synthesize computerPaddle;
@synthesize userPaddle;
@synthesize instructionMessageLabel;
@synthesize scoreBoardLabel;
@synthesize puckVelocity;
@synthesize gameState,scoreToWin;
@synthesize motionScale,ballSpeedX,ballSpeedY,computerPaddleSpeed;

UIDeviceOrientation orientation;

- (void)loadView {
    self.arController = [[ARController alloc] initWithViewController:self];
    
    justHitUserPadle = FALSE;
    justHitCompPadle = FALSE;
    
    [super loadView];
}

-(void)updateDeviceOrientation{
    NSLog(@"WAS:PongVilleViewController.m:updateDeviceOrientation:A");
    UIDevice *device = [UIDevice currentDevice];    
    orientation = device.orientation;        
}

-(void)changeBackgroundColorToRandomColor{
    
    // Create float values for red, green, and blue
    float r = random() % 256 / 256.0;
    float g = random() % 256 / 256.0;
    float b = random() % 256 / 256.0;
    
    // Set the new background color
    self.view.backgroundColor = [UIColor colorWithRed:r green:g blue:b alpha:1];

}

-(void)changeBackgroundColorWithAccelerometerSeed:(CMAccelerometerData *)accelData{    
    
    // Define the Red/Green/Blue values
    // Each value has a range of 0 to 1
    // Values below 0 will be treated as 0
    // Values above 1 will be treated as 1
    float r = .6 - accelData.acceleration.x;
    float g = .6 - accelData.acceleration.y;
    float b = .6 - accelData.acceleration.z;

    
    //Logging the colors is really resource intensive. Don't do it!
    // NSLog(@"WAS:r=%f,g=%f,b=%f",r,g,b);
          
    // Set the new background color
    self.view.backgroundColor = [UIColor colorWithRed:r green:g blue:b alpha:1];                              
}

-(void)changePaddleColorsToOppositeOfBackground{
    
    int numComponents = CGColorGetNumberOfComponents(self.view.backgroundColor.CGColor);
    
    if (numComponents == 4){
        const CGFloat *components = CGColorGetComponents(self.view.backgroundColor.CGColor);
        CGFloat red = components[0];
        CGFloat green = components[1];
        CGFloat blue = components[2];
        CGFloat alpha = components[3];
        
        self.userPaddle.backgroundColor = [UIColor colorWithRed:1-red green:1-green blue:1-blue alpha:alpha];
        self.computerPaddle.backgroundColor = [UIColor colorWithRed:1-red green:1-green blue:1-blue alpha:alpha];
    }
}

-(void)changeBackgroundColorWithAR{
    ARCoordinate *item = [[self arController] currentCoordinate];
    
    CGPoint point = [[self arController] pointForCoordinate:item];
    
    float r = (long)(point.x) % 256 / 256.0;
    float g = (long)(point.y) % 256 / 256.0;
    float b = (long)((point.x*point.y)/2) % 256 / 256.0;
    
    //Logging the colors is really resource intensive. Don't do it!
    //NSLog(@"WAS:r=%f,g=%f,b=%f",r,g,b);
    
    // Set the new background color
    self.view.backgroundColor = [UIColor colorWithRed:r green:g blue:b alpha:1];                              
}

- (void)dealloc{
	[arController release];
    
    
    [puck release];
    [computerPaddle release];
    [userPaddle release];
    [instructionMessageLabel release];
    [scoreBoardLabel release];
    [scoreBoardMarquee release];
    
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
    
    // This is to constantly change the background color based on accelerometer data
    // Perhaps this should be an opt-in option. It may not resonate with all users.
    [self changeBackgroundColorWithAccelerometerSeed:accelData];
    
    // Change background color using augmented reality logic
    //[self changeBackgroundColorWithAR];
    
    // Change the paddle color
    // [self changePaddleColorsToOppositeOfBackground];
    
    // Set the buttonFrame x coordinate
        switch (orientation) {
        case UIDeviceOrientationPortrait:            
            imageFrameValue.origin.x += accelData.acceleration.x * motionScale;            
            break;            
        case UIDeviceOrientationPortraitUpsideDown:            
            imageFrameValue.origin.x += -accelData.acceleration.x * motionScale;            
            break;            
        case UIDeviceOrientationLandscapeLeft:            
            imageFrameValue.origin.x += -accelData.acceleration.y * 2 * motionScale;            
            break;            
        case UIDeviceOrientationLandscapeRight:            
            imageFrameValue.origin.x += accelData.acceleration.y * 2 * motionScale;            
            break;            
        default:
            [self updateDeviceOrientation];
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
             //imageFrame.origin.x += data.acceleration.x * motionScale;
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
        justHitUserPadle = FALSE;
        justHitCompPadle = FALSE;
    }
    
    // If the puck has hit a wall, reverse the puck velocity
    if(puck.center.y > self.view.bounds.size.height || puck.center.y < 0){
        puckVelocity.y = -puckVelocity.y;
        justHitUserPadle = FALSE;
        justHitCompPadle = FALSE;
    }
    
    // If the puck has hit the computer paddle, reverse the velocity
    if(CGRectIntersectsRect(puck.frame,userPaddle.frame) && !justHitUserPadle) {
        if(puck.center.y < userPaddle.center.y) {
            puckVelocity.y = -puckVelocity.y;
            justHitUserPadle = TRUE;
            justHitCompPadle = FALSE;
        }
    }
    
    // If the puck has hit the user paddle, reverse the velocity
    if(CGRectIntersectsRect(puck.frame,computerPaddle.frame) && !justHitCompPadle) {
        if(puck.center.y > computerPaddle.center.y) {
            puckVelocity.y = -puckVelocity.y;
            justHitUserPadle = FALSE;
            justHitCompPadle = TRUE;
        }
    }
}

-(void)performSmartAI{
    // Begin the super advanced artificial intelligence
    if(puck.center.y <= self.view.center.y){
        
        if(puck.center.x < computerPaddle.center.x){
            CGPoint compLocation = CGPointMake(computerPaddle.center.x - computerPaddleSpeed, computerPaddle.center.y);
            computerPaddle.center = compLocation;
        }
        
        if(puck.center.x > computerPaddle.center.x){
            CGPoint compLocation = CGPointMake(computerPaddle.center.x + computerPaddleSpeed, computerPaddle.center.y);
            computerPaddle.center = compLocation;
        }
    } 
}

-(void)performRandomAI{
    // Begin the AI that can make random mistakes
    if(puck.center.y <= self.view.center.y){
        
        if(puck.center.x < computerPaddle.center.x){
            CGPoint compLocation = CGPointMake(computerPaddle.center.x - computerPaddleSpeed, computerPaddle.center.y);
            computerPaddle.center = compLocation;
        }
        
        if(puck.center.x > computerPaddle.center.x){
            CGPoint compLocation = CGPointMake(computerPaddle.center.x + computerPaddleSpeed, computerPaddle.center.y);
            computerPaddle.center = compLocation;
        }
    } 
}

-(void)performTerribleAI{
    // Begin the dumb artificial intelligence
    if(puck.center.y <= (self.view.center.y *2/3)){
        
        if(puck.center.x < computerPaddle.center.x){
            CGPoint compLocation = CGPointMake(computerPaddle.center.x - computerPaddleSpeed, computerPaddle.center.y);
            computerPaddle.center = compLocation;
        }
        
        if(puck.center.x > computerPaddle.center.x){
            CGPoint compLocation = CGPointMake(computerPaddle.center.x + computerPaddleSpeed, computerPaddle.center.y);
            computerPaddle.center = compLocation;
        }
    } 
}


// This function calls the appropriate AI function
// TODO: make the difficulty level adjustable
-(void)performArtificialIntelligence
{
    //[self performSmartAI];
    //[self performTerribleAI];
    [self performRandomAI];
}

-(void)performScoringLogic
{
    // Begin Scoring Logic
    if(puck.center.y <= 0){
        userScoreValue = userScoreValue +1;
        NSLog(@"WAS:performScoringLogic:about to call reset:A");
        [self reset:(userScoreValue >= scoreToWin)];
    }else if(puck.center.y > self.view.bounds.size.height){
        computerScoreValue = computerScoreValue +1;
        NSLog(@"WAS:performScoringLogic:about to call reset:B");
        [self reset:(computerScoreValue >= scoreToWin)];
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
    
    computerPaddle = nil;
    userPaddle = nil;
    instructionMessageLabel = nil;
    scoreBoardLabel = nil;
    scoreBoardMarquee = nil;
    
    //[self.motionManager release];
    
    
    
}



-(void)swiperight{
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] init];
    settingsViewController.delegate = self;
    [self presentModalViewController:settingsViewController animated:YES];
    [settingsViewController release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self displayInitialPrompt];
    [NSTimer scheduledTimerWithTimeInterval:0.05 
                                     target:self 
                                   selector:@selector(flowCycle) 
                                   userInfo:nil 
                                    repeats:YES];

    // Add the "swipe right" gesture recognizer
    UISwipeGestureRecognizer *swipeRightGestureRecognizer =
    [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiperight)];
    swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRightGestureRecognizer];
    [swipeRightGestureRecognizer release];
}

-(void)viewWillAppear:(BOOL)animated{
    //Initilize settings:
    self.gameState = GAME_STATE_PAUSED;
    self.motionScale = 
        DEFAULT_MOTION_SCALE*[[NSUserDefaults standardUserDefaults] floatForKey:MOTION_SCALE];
    self.ballSpeedX = 
        DEFAULT_BALL_SPEED_X*[[NSUserDefaults standardUserDefaults] floatForKey:BALL_SPEED_X];
    self.ballSpeedY = 
        DEFAULT_BALL_SPEED_Y*[[NSUserDefaults standardUserDefaults] floatForKey:BALL_SPEED_Y];
    self.computerPaddleSpeed = 
        DEFAULT_COMPUTER_PADDLE_SPEED*[[NSUserDefaults standardUserDefaults] floatForKey:COMPUTER_PADDLE_SPEED];;
    self.scoreToWin = [[NSUserDefaults standardUserDefaults] floatForKey:SCORE_TO_WIN];
    
    self.motionScale = 
        (self.motionScale == 0 ? DEFAULT_MOTION_SCALE : self.motionScale);
    self.ballSpeedX = 
        (self.ballSpeedX == 0 ? DEFAULT_BALL_SPEED_X : self.ballSpeedX);
    self.ballSpeedY = 
        (self.ballSpeedY == 0 ? DEFAULT_BALL_SPEED_Y : self.ballSpeedY);
    self.computerPaddleSpeed = 
        (self.computerPaddleSpeed == 0 ? DEFAULT_COMPUTER_PADDLE_SPEED : self.computerPaddleSpeed);
    self.scoreToWin = 
        (self.scoreToWin == 0 ? DEFAULT_SCORE_TO_WIN : self.scoreToWin);
    
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    NSLog(@"WAS:PongVilleViewController.m:viewDidAppear:A");
    
    //    UITapGestureRecognizer *tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    //    [self.view addGestureRecognizer:tapgr];
    //    [tapgr release];
    
    //setting this here so that when the view switches from settings to game it will update these.
    puckVelocity = CGPointMake(ballSpeedX, ballSpeedY);
    
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

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    NSLog(@"Rotating!");
    [self pauseGame];
      
    
    // Update the device orientation
    [self updateDeviceOrientation];
    
    // Change the background color to a random color
    [ self changeBackgroundColorToRandomColor];
}




//-(IBAction)sliderChanged:(id)sender{
//    UISlider *slider = (UISlider *)sender;
//    computerPaddleSpeed = (int)((slider.value) * COMPUTER_PADDLE_SPEED);
//}



@end
