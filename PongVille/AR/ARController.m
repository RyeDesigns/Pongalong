//
//  ARController.m
//
//  BASED ON:
//      Alasdair Allan on 07/04/2010.
//      Babilim Light Industries
//      Zac White and Niels Hansen, 2009
//

#import "ARController.h"
#import "ARCoordinate.h"

@implementation ARController

@synthesize currentOrientation;
@synthesize currentLocation;
@synthesize currentHeading;
@synthesize currentCoordinate;

@synthesize viewRange;
@synthesize viewAngle;

@synthesize rootController;
@synthesize overlayView;

@synthesize locationManager;
@synthesize accelerometer;

- (id)initWithViewController:(UIViewController *)theView {

	coordinates	= [[NSMutableArray alloc] init];
	
	// Initialise the root and overlay views
	self.rootController = theView;
	CGRect screenBounds = [[UIScreen mainScreen] bounds];
	self.overlayView = [[UIView alloc] initWithFrame: screenBounds];
	self.currentOrientation = UIDeviceOrientationPortrait;
	self.viewRange = self.overlayView.bounds.size.width / 12;
	self.rootController.view = overlayView;
	
	// Initialise the CLLocationManager
	self.locationManager = [[CLLocationManager alloc] init];
	self.locationManager.headingFilter = kCLHeadingFilterNone;
	self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	self.locationManager.delegate = self;
	[self.locationManager startUpdatingHeading];
	[self.locationManager startUpdatingLocation];
	
	self.currentLocation = [[CLLocation alloc] initWithLatitude:37.33231 longitude:-122.03118];	 
	 
	// Initalise the UIAccelerometer
	self.accelerometer = [UIAccelerometer sharedAccelerometer];
	self.accelerometer.updateInterval = 0.25;
	self.accelerometer.delegate = self;
	
	// Listen for changes in device orientation
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object:nil];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];	
	
	// Initialise the central ARCoordiante
	self.currentCoordinate = [[ARCoordinate alloc] initWithRadialDistance:1.0 andInclination:0 andAzimuth:0];
	
	return self;
}

#pragma mark CLLocationManager Delegate Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
	if (newHeading.headingAccuracy > 0) {
		self.currentHeading = newHeading;
		[self updateCurrentCoordinate];
	}
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
	return YES;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	if (newLocation != oldLocation) {
		[self updateCurrentLocation:newLocation];
	}

}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	//NSLog(@"Received Core Location error %@", error);
	[self.locationManager stopUpdatingLocation];
}

#pragma mark UIAccelerometer Delegate Methods
							   
- (void)accelerometer:(UIAccelerometer *)meter didAccelerate:(UIAcceleration *)acceleration {
	
	switch (currentOrientation) {
		case UIDeviceOrientationLandscapeLeft:
			self.viewAngle = atan2(acceleration.x, acceleration.z);
			break;
		case UIDeviceOrientationLandscapeRight:
			self.viewAngle = atan2(-acceleration.x, acceleration.z);
			break;
		case UIDeviceOrientationPortrait:
			self.viewAngle = atan2(acceleration.y, acceleration.z);
			break;
		case UIDeviceOrientationPortraitUpsideDown:
			self.viewAngle = atan2(-acceleration.y, acceleration.z);
			break;	
		default:
			break;
	}
	
	[self updateCurrentCoordinate];
}							  							   
							   
#pragma mark UIDeviceOrientation Notifications

- (void)deviceOrientationDidChange:(NSNotification *)notification {
	
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	
	if ( orientation != UIDeviceOrientationUnknown && 
		 orientation != UIDeviceOrientationFaceUp && 
		 orientation != UIDeviceOrientationFaceDown) {
		
		CGAffineTransform transform = CGAffineTransformMakeRotation(degreesToRadians(0));
		CGRect bounds = [[UIScreen mainScreen] bounds];
		
		if (orientation == UIDeviceOrientationLandscapeLeft) {
			transform		   = CGAffineTransformMakeRotation(degreesToRadians(90));
			bounds.size.width  = [[UIScreen mainScreen] bounds].size.height;
			bounds.size.height = [[UIScreen mainScreen] bounds].size.width;
		} else if (orientation == UIDeviceOrientationLandscapeRight) {
			transform		   = CGAffineTransformMakeRotation(degreesToRadians(-90));
			bounds.size.width  = [[UIScreen mainScreen] bounds].size.height;
			bounds.size.height = [[UIScreen mainScreen] bounds].size.width;
		} else if (orientation == UIDeviceOrientationPortraitUpsideDown) {
			transform = CGAffineTransformMakeRotation(degreesToRadians(180));
		}
		self.overlayView.transform = transform;
		self.overlayView.bounds = bounds;
		self.viewRange = self.overlayView.bounds.size.width / 12;

		//NSLog( @"deviceOrientationDidChange: %@", bounds);
	}
	self.currentOrientation = orientation;
}

#pragma mark Add and Remove ARCoordinates

- (void)addCoordinate:(ARCoordinate *)coordinate animated:(BOOL)animated {	
	//NSLog( @"addCoord: Adding coordinate to self.coordinates");
	[coordinates addObject:coordinate];
}

- (void)removeCoordinate:(ARCoordinate *)coordinate animated:(BOOL)animated {
	//NSLog( @"removeCoord: Removing coordinate to self.coordinates");
	[coordinates removeObject:coordinate];
}

#pragma mark Update the AR Overlay View

- (void)updateCurrentLocation:(CLLocation *)newLocation {
	self.currentLocation = newLocation;
	
	//NSLog(@"updateCurrentLocation: self.currentLocation = %@", self.currentLocation );
	
}

- (void)updateCurrentCoordinate {
	
	double adjustment = 0;
	if (self.currentOrientation == UIDeviceOrientationLandscapeLeft)
		adjustment = degreesToRadians(270); 
	else if (currentOrientation == UIDeviceOrientationLandscapeRight)
		adjustment = degreesToRadians(90);
	else if (currentOrientation == UIDeviceOrientationPortraitUpsideDown)
		adjustment = degreesToRadians(180);

	//NSLog(@"updateCurrentCoordinate: (1) adjustment = %.3f, currentCoordinate.azimuth = %.3f", radiansToDegrees(adjustment), radiansToDegrees( self.currentCoordinate.coordinateAzimuth ) );
	
	self.currentCoordinate.coordinateAzimuth =  
	     degreesToRadians(self.currentHeading.magneticHeading) - adjustment;

	//NSLog(@"updateCurrentCoordinate: (2) adjustment = %.3f, currentCoordinate.azimuth = %.3f, magneticHeading = %3.f", radiansToDegrees(adjustment), radiansToDegrees( self.currentCoordinate.coordinateAzimuth ), self.currentHeading.magneticHeading );
}

- (BOOL)viewportContainsCoordinate:(ARCoordinate *)coordinate {
				
	double deltaAzimuth = [self deltaAzimuthForCoordinate:coordinate];
	BOOL result	= NO;
	if (deltaAzimuth <= degreesToRadians(self.viewRange)) {
		result = YES;
	}
	//NSLog(@"viewPortContainsView: location = %@, viewRange %.3f, deltaAzimuth %.3f", coordinate.coordinateTitle, self.viewRange, radiansToDegrees(deltaAzimuth));
	
	return result;
}

- (double)deltaAzimuthForCoordinate:(ARCoordinate *)coordinate {
	
	double currentAzimuth = self.currentCoordinate.coordinateAzimuth;
	double pointAzimuth	  = coordinate.coordinateAzimuth;
	
	//NSLog( @"deltaAzimuthForCoordinate: currentAzimuth = %.3f, pointAzimuth = %.3f", 
	//	  radiansToDegrees(currentAzimuth), radiansToDegrees(pointAzimuth));

	double deltaAzimith = ABS( pointAzimuth - currentAzimuth);
	
	// If values are on either side of the Azimuth of North we need to 
	// adjust it. Only check the degree range.
	if (currentAzimuth < degreesToRadians(self.viewRange) && 
		pointAzimuth > degreesToRadians(360-self.viewRange)) {
		deltaAzimith	= (currentAzimuth + ((M_PI * 2.0) - pointAzimuth));
	} else if (pointAzimuth < degreesToRadians(self.viewRange) && 
			   currentAzimuth > degreesToRadians(360-self.viewRange)) {
		deltaAzimith	= (pointAzimuth + ((M_PI * 2.0) - currentAzimuth));
	}
	
	//NSLog(@"deltaAzimuthForCoordinate: deltaAzimuth = %.3f", deltaAzimith);
	return deltaAzimith;
}

-(BOOL)isNorthForCoordinate:(ARCoordinate *)coordinate {
	
	BOOL isBetweenNorth = NO;
	double currentAzimuth = self.currentCoordinate.coordinateAzimuth;
	double pointAzimuth	= coordinate.coordinateAzimuth;	

	// If values are on either side of the Azimuth of North we 
	// need to adjust it.  Only check the degree range
	if ( currentAzimuth < degreesToRadians(self.viewRange) && 
		  pointAzimuth > degreesToRadians(360-self.viewRange) ) {
		isBetweenNorth = YES;
	} else if ( pointAzimuth < degreesToRadians(self.viewRange) && 
				currentAzimuth > degreesToRadians(360-self.viewRange)) {
		isBetweenNorth = YES;
	}
	return isBetweenNorth;
	
}

- (CGPoint)pointForCoordinate:(ARCoordinate *)coordinate {

	CGPoint point;
	CGRect viewBounds = self.overlayView.bounds;
	//NSLog(@"pointForCoordinate:	viewBounds.size.width = %.3f, height = %.3f", viewBounds.size.width, viewBounds.size.height );
	
	double currentAzimuth = self.currentCoordinate.coordinateAzimuth;
	double pointAzimuth	= coordinate.coordinateAzimuth;
	double pointInclination	= coordinate.coordinateInclination;
	
	//NSLog(@"pointForCoordinate: location = %@, pointAzimuth = %.3f, pointInclination = %.3f, currentAzimuth = %.3f", coordinate.coordinateTitle, point.x, point.y, radiansToDegrees(pointAzimuth), radiansToDegrees(currentAzimuth), radiansToDegrees(pointInclination) );
		
	double deltaAzimuth = [self deltaAzimuthForCoordinate:coordinate];
	BOOL isBetweenNorth	= [self isNorthForCoordinate:coordinate];
	
	//NSLog(@"pointForCoordinate: (1) currentAzimuth = %.3f, pointAzimuth = %.3f, isNorth = %d", radiansToDegrees(currentAzimuth), radiansToDegrees(pointAzimuth), isBetweenNorth );
	
	//NSLog(@"pointForCoordinate: deltaAzimuth = %.3f", radiansToDegrees(deltaAzimuth));
	//NSLog(@"pointForCoordinate: (2) currentAzimuth = %.3f, pointAzimuth = %.3f, isNorth = %d", radiansToDegrees(currentAzimuth), radiansToDegrees(pointAzimuth), isBetweenNorth );
	
	if ((pointAzimuth > currentAzimuth && !isBetweenNorth) || 
		(currentAzimuth > degreesToRadians(360-self.viewRange) && 
		 pointAzimuth < degreesToRadians(self.viewRange))) {
			
		// Right side of Azimuth			
		point.x = (viewBounds.size.width / 2) + ((deltaAzimuth / degreesToRadians(1)) * 12);  
	} else {
			
		// Left side of Azimuth
		point.x = (viewBounds.size.width / 2) - ((deltaAzimuth / degreesToRadians(1)) * 12);	
	}	
	point.y = (viewBounds.size.height / 2) 
	          + (radiansToDegrees(M_PI_2 + self.viewAngle)  * 2.0)
	          + ((pointInclination / degreesToRadians(1)) * 12);
	
	//NSLog(@"pointForCoordinate: location = %@, point.x = %.3f, point.y = %.3f, pointAzimuth = %.3f, currentAzimyth = %.3f, viewAngle = %.3f, deltaAzimuth = %.3f, viewBounds.size( width = %.3f, height = %.3f )", coordinate.coordinateTitle, point.x, point.y, radiansToDegrees(pointAzimuth), radiansToDegrees(currentAzimuth), self.viewAngle, deltaAzimuth, viewBounds.size.width, viewBounds.size.height );
	
	return point;
	
	
}

#pragma mark Deallocation

- (void)dealloc {
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
	[currentLocation release];
	[currentHeading release];
	[currentCoordinate release];
	[rootController release];
	[overlayView release];
	[locationManager release];
	[accelerometer release];
	[coordinates release];
   [super dealloc];
}




@end
