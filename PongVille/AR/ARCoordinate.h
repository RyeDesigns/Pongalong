//
//  ARController.m
//
//  BASED ON:
//      Alasdair Allan on 07/04/2010.
//      Babilim Light Industries
//      Zac White and Niels Hansen, 2009
//

#import <Foundation/Foundation.h>

@interface ARCoordinate : NSObject {
	double coordinateDistance;
	double coordinateInclination;
	double coordinateAzimuth;
	NSString *coordinateTitle;
	NSString *coordinateSubTitle;
}

- (id)initWithRadialDistance:(double)distance andInclination:(double)inclination andAzimuth:(double)azimuth;

@property (nonatomic, retain) NSString *coordinateTitle;
@property (nonatomic, retain) NSString *coordinateSubTitle;
@property (nonatomic) double coordinateDistance;
@property (nonatomic) double coordinateInclination;	
@property (nonatomic) double coordinateAzimuth;

@end
