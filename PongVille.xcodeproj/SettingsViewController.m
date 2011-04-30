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
@synthesize computerPaddleSpeed;
@synthesize computerPaddleSpeedSlider;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(IBAction)computerPaddleSliderChanged:(UISlider *)_computerPaddleSpeedSlider{   
    self.computerPaddleSpeed = _computerPaddleSpeedSlider.value;    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.computerPaddleSpeedSlider.value = computerPaddleSpeed;
}

- (void)dealloc
{
    [super dealloc];
    //[computerPaddleSpeedSlider release];
}

-(IBAction)done{    
    NSLog(@"WAS:SettingsViewController.m:done:A");
    [self.delegate settingsViewController:self 
                  withComputerPaddleSpeed:self.computerPaddleSpeedSlider.value];
    NSLog(@"WAS:SettingsViewController.m:done:Z");
    
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
