//
//  DirectionsView.h
//  MapDirectionsViewExample
//
//  Created by Kamil Pyć on 11-12-05.
//  Copyright (c) 2011 Kamil Pyć. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@protocol DirectionsViewDelegate;


@interface DirectionsView : UIView
{
    id <DirectionsViewDelegate> delegate;
    UIButton *previousStepButton;
    UIButton *nextStepButton;
}
@property (nonatomic ,assign) id delegate;
@property (nonatomic ,retain) NSArray *steps;
@property (nonatomic, retain) UILabel *directionsLabel;
@property (nonatomic, retain) UILabel *stepNumberLabel;
@property (nonatomic, assign) NSInteger currentStep;

-(NSString *) stringByStrippingHTML : (NSString*)string;
-(void)previousStep;
-(void)nextStep;
@end

@protocol DirectionsViewDelegate <NSObject>

-(void)moveToPoint:(CLLocationCoordinate2D)location;


@end