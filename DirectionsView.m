//
//  DirectionsView.m
//  MapDirectionsViewExample
//
//  Created by Kamil Pyć on 11-12-05.
//  Copyright (c) 2011 Kamil Pyć. All rights reserved.
//

#import "DirectionsView.h"

@implementation DirectionsView
@synthesize delegate;
@synthesize steps = _steps;
@synthesize directionsLabel = _directionsLabel;
@synthesize stepNumberLabel = _stepNumberLabel;
@synthesize currentStep = _currentStep;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithRed:0.486 green:0.565 blue:0.671 alpha:0.8];
        //Shows step number
        _stepNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, frame.size.width, 20)] ;
        [self addSubview:self.stepNumberLabel];
        [self.stepNumberLabel setBackgroundColor:[UIColor clearColor]];
        self.stepNumberLabel.textAlignment = UITextAlignmentCenter;
        self.stepNumberLabel.textColor = [UIColor whiteColor];
        //previous direction button
        previousStepButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:previousStepButton];
        [previousStepButton addTarget:self action:@selector(previousStep) forControlEvents:UIControlEventTouchUpInside];
        previousStepButton.frame = CGRectMake(0, 20, 30, 30);
        [previousStepButton setImage:[UIImage imageNamed:@"arrow_left.png"] forState:UIControlStateNormal];
        //next direction button
        nextStepButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [nextStepButton setImage:[UIImage imageNamed:@"arrow_right.png"] forState:UIControlStateNormal];
        [self addSubview:nextStepButton];
        nextStepButton.frame = CGRectMake(frame.size.width - 30, 20, 30, 30);
        [nextStepButton addTarget:self action:@selector(nextStep) forControlEvents:UIControlEventTouchUpInside];
        _directionsLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, 20, frame.size.width - 60 , 50) ];
        
        self.directionsLabel.numberOfLines = 0;
        self.directionsLabel.textColor = [UIColor whiteColor];
        self.directionsLabel.backgroundColor = [UIColor clearColor];
        self.directionsLabel.textAlignment = UITextAlignmentCenter;
        [self addSubview:self.directionsLabel];

        //Autoresize masks
        self.stepNumberLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin;
        self.directionsLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin;
        nextStepButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin;
        
        self.steps = nil;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    CGGradientRef glossGradient;
    CGColorSpaceRef rgbColorspace;
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = { 1.0, 1.0, 1.0, 0.35,  // Start color
        1.0, 1.0, 1.0, 0.06 }; // End color
    
    rgbColorspace = CGColorSpaceCreateDeviceRGB();
    glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
    
    CGRect currentBounds = self.bounds;
    CGPoint topCenter = CGPointMake(CGRectGetMidX(currentBounds), 0.0f);
    CGPoint midCenter = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMidY(currentBounds));
    CGContextDrawLinearGradient(currentContext, glossGradient, topCenter, midCenter, 0);
    
    CGGradientRelease(glossGradient);
    CGColorSpaceRelease(rgbColorspace); 
    
}



-(void)moveToStep {
    self.stepNumberLabel.text = [NSString stringWithFormat:@"%d/%d",self.currentStep+1,[self.steps count]];
    NSDictionary *step = [self.steps objectAtIndex:self.currentStep];
    
    self.directionsLabel.text = [self stringByStrippingHTML:[step objectForKey:@"html_instructions"]];
    CLLocationCoordinate2D loc = CLLocationCoordinate2DMake([[[step objectForKey:@"start_location"] objectForKey:@"lat"] floatValue], [[[step objectForKey:@"start_location"] objectForKey:@"lng"] floatValue] );
    [delegate moveToPoint:loc];
}

-(void)nextStep{
        
    self.currentStep++;
    
    [self moveToStep];

    if(self.currentStep >= [self.steps count]-1)
    {
        nextStepButton.enabled = NO;
    }
    else{
        nextStepButton.enabled = YES;
    }
    previousStepButton.enabled = YES;
}

-(void)previousStep{

    self.currentStep--;

    [self moveToStep];

    if(self.currentStep <= 0)
    {
        previousStepButton.enabled = NO; 
    }
    else
    {
        previousStepButton.enabled = YES;
    }
    nextStepButton.enabled = YES;

}

-(void)setSteps:(NSArray *)steps{
    [_steps release];
    _steps = nil;
    _steps = steps;
    [_steps retain];
    self.currentStep = -1;
    self.stepNumberLabel.text = @"";
    previousStepButton.enabled = FALSE;
    if ([self.steps count]) {
        self.directionsLabel.text = @"Press arrow to start your route!";
        nextStepButton.enabled = TRUE;
    } else {
        self.directionsLabel.text = @"No route!";
        nextStepButton.enabled = FALSE;
    }
}

-(NSString *) stringByStrippingHTML : (NSString*)string{
    NSRange r;
    NSString *s = [[string copy] autorelease];
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    return s; 
}

-(void)dealloc{
    self.stepNumberLabel = nil;
    self.directionsLabel = nil;
    self.steps = nil;
    [super dealloc];
}

@end
