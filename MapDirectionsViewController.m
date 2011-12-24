//
//  MapDirectionsView.m
//  
//
//  Created by Kamil Pyć on 11-12-02.
//  Copyright (c) 2011 Kamil Pyć. All rights reserved.
//

#import "MapDirectionsViewController.h"
#import "JSON.h"
#import "SVProgressHUD.h"

@interface MapDirectionsViewController ()
- (NSMutableArray *)decodePolyLine:(NSMutableString *)encoded;
@end


@implementation MapDirectionsViewController
@synthesize startPoint = _startPoint;
@synthesize endPoint = _endPoint;
@synthesize fillColor = _fillColor;
@synthesize strokeColor = _strokeColor;
@synthesize lineWidth = _lineWidth;
@synthesize walkingMode = _walkingMode;
@synthesize routeLine = _routeLine;
@synthesize mapView = _mapView;


#pragma mark -
#pragma Initial View setup


-(void)viewDidLoad{
    
    [super viewDidLoad];
    
    self.lineWidth = 3;
    self.fillColor = [UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:0.7f];
    self.strokeColor = [UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:0.7f];
    self.walkingMode = FALSE;
    
    NSArray *arrayItems = [NSArray arrayWithObjects:@"Drive",@"Walk", nil];
    UISegmentedControl *topButtons = [[UISegmentedControl alloc]initWithItems:arrayItems];
    topButtons.selectedSegmentIndex = 0;
    [self.navigationItem setTitleView:topButtons];
    [topButtons addTarget:self action:@selector(directionsModeSegmentControlTapped:) forControlEvents:UIControlEventValueChanged];
    [topButtons setSegmentedControlStyle:UISegmentedControlStyleBar];
    [topButtons release];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]initWithTitle:@"Tips" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleDirectionsTip)];
    
    self.navigationItem.rightBarButtonItem = rightButton;
    
    [rightButton release];
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc]initWithTitle:@"Route" style:UIBarButtonItemStyleBordered target:self action:@selector(getRoute)];
    
    self.navigationItem.leftBarButtonItem = leftButton;
    
    [leftButton release];
    
    
    _mapView = [[MKMapView alloc]initWithFrame:self.view.bounds];
    self.mapView.delegate = self;
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.mapView.showsUserLocation = YES;
    [self.view addSubview:self.mapView];
    
    directionsView = [[DirectionsView alloc]initWithFrame:CGRectMake(0, -70, self.view.bounds.size.width, 70)];
    directionsView.clipsToBounds = YES;
    [self.view addSubview:directionsView];
    directionsView.delegate = self;
    [directionsView release];
    
    
}



-(void)toggleDirectionsTip{
    
    [UIView animateWithDuration:0.5f animations:^{
        directionsView.frame = CGRectMake(0,directionsView.frame.origin.y? 0:-70, self.view.bounds.size.width,directionsView.frame.size.height);
    
    }];
}


-(void)calculateDirections{
    [SVProgressHUD showInView:self.view status:@"Calculating directions"];

    if (self.startPoint == nil) {
        [SVProgressHUD dismissWithError:@"No start point selected!" afterDelay:1];
    } else if (self.endPoint == nil){
        [SVProgressHUD dismissWithError:@"No end point selected!" afterDelay:1];
    } else {
        [self.mapView setCenterCoordinate:self.startPoint.coordinate animated:YES];
        NSString *mode = nil;
        if (self.walkingMode) {
            mode= @"walking";
        } else
        {
            mode = @"driving";
        }
        
        NSString* urlString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&sensor=true&language=%@&mode=%@", self.startPoint.coordinate.latitude, self.startPoint.coordinate.longitude,self.endPoint.coordinate.latitude , self.endPoint.coordinate.longitude,[[NSLocale currentLocale] localeIdentifier], mode];
        
        ASIHTTPRequest *asiRequest = [[ASIHTTPRequest alloc]initWithURL:[NSURL URLWithString:urlString]];
        asiRequest.delegate = self;
        [asiRequest startAsynchronous];

    }
        
}



-(void)getRoute{
    
    [self calculateDirections];

}



-(void)directionsModeSegmentControlTapped:(UISegmentedControl *)sender
{
    switch (sender.selectedSegmentIndex)
    {
        case 1: //Walk
            self.walkingMode = YES;    
            break;
        default://Drive 
            self.walkingMode = NO;
            break;
    }
    
}

#pragma mark -
#pragma mark Map Helpers


// Decode a polyline.
// See: http://code.google.com/apis/maps/documentation/utilities/polylinealgorithm.html
- (NSMutableArray *)decodePolyLine:(NSMutableString *)encoded {
	[encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\"
								options:NSLiteralSearch
								  range:NSMakeRange(0, [encoded length])];
	NSInteger len = [encoded length];
	NSInteger index = 0;
	NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
	NSInteger lat=0;
	NSInteger lng=0;
	while (index < len) {
		NSInteger b;
		NSInteger shift = 0;
		NSInteger result = 0;
		do {
			b = [encoded characterAtIndex:index++] - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
		NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
		lat += dlat;
		shift = 0;
		result = 0;
		do {
			b = [encoded characterAtIndex:index++] - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
		NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
		lng += dlng;
		NSNumber *latitude = [[[NSNumber alloc] initWithFloat:lat * 1e-5] autorelease];
		NSNumber *longitude = [[[NSNumber alloc] initWithFloat:lng * 1e-5] autorelease];
		CLLocation *loc = [[[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]] autorelease];
		[array addObject:loc];
	}
	
	return array;
}


-(MKCoordinateRegion)getRegionForBounds:(NSDictionary*)bounds{
    CLLocationCoordinate2D annotationCenter;
    CGFloat southwestLat,southwestLng,northeastLat,northeastLng; 
    northeastLat = [[[bounds objectForKey:@"northeast"] objectForKey:@"lat"] floatValue];
    northeastLng = [[[bounds objectForKey:@"northeast"] objectForKey:@"lng"] floatValue];
    
    southwestLat = [[[bounds objectForKey:@"southwest"] objectForKey:@"lat"] floatValue];
    southwestLng = [[[bounds objectForKey:@"southwest"] objectForKey:@"lng"] floatValue];
    
    
    MKCoordinateSpan span;
    span.longitudeDelta =  fabs(northeastLng - southwestLng) ;
	span.latitudeDelta =  fabs(northeastLat - southwestLat);
    annotationCenter.longitude = (northeastLng + southwestLng)/2;
    annotationCenter.latitude = (northeastLat + southwestLat)/2;
    span.longitudeDelta = span.longitudeDelta*1.1;
    span.latitudeDelta = span.latitudeDelta*1.3;
    MKCoordinateRegion region;
	region.center = annotationCenter;
	region.span = span;
    
    return region;
}

#pragma mark -
#pragma mark Map Delegate


- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id )overlay {
    
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineView* routeLineView = [[[MKPolylineView alloc] initWithPolyline:self.routeLine] autorelease];
        routeLineView.fillColor = self.fillColor;
        routeLineView.strokeColor = self.strokeColor;
        routeLineView.lineWidth = self.lineWidth;
        return routeLineView;
    } else if ([overlay isKindOfClass:[MKCircle class]]){
        MKCircleView* circleView = [[[MKCircleView alloc]initWithOverlay:overlay] autorelease];
        circleView.fillColor = self.fillColor;
        return circleView;
    }
	return nil;
}

#pragma mark -
#pragma mark ASIHttp Delegate

-(void)requestFinished:(ASIHTTPRequest *)request{
    NSDictionary *respondDictionary = [[request responseString]JSONValue];
    
    NSArray *array = [respondDictionary objectForKey:@"routes"];
    NSDictionary *route = [array lastObject];
    NSDictionary *bounds = [route objectForKey:@"bounds"];
    
    if([[respondDictionary objectForKey:@"status"] isEqualToString:@"ZERO_RESULTS"]) {
        [SVProgressHUD dismissWithError:@"Cannot calculate route between points!" afterDelay:1];
        
        return;
    }  else if([[respondDictionary objectForKey:@"status"] isEqualToString:@"OK"]){
        
        NSDictionary *polDict = [route objectForKey:@"overview_polyline"];
        NSMutableArray *polyLine = [self decodePolyLine:[NSMutableString stringWithString:[polDict objectForKey:@"points"]]];	
        
        
        CLLocationCoordinate2D* pointArr = malloc(sizeof(CLLocationCoordinate2D) * polyLine.count);
        for(int idx = 0; idx < polyLine.count; idx++)
        {
            // break the string down even further to latitude and longitude fields.
            CLLocation *loc = [polyLine objectAtIndex:idx];        
            
            // create our coordinate and add it to the correct spot in the array
            CLLocationCoordinate2D coordinate = loc.coordinate;
            
            pointArr[idx] = coordinate;
            
        }
        
        [self.mapView setRegion:[self.mapView regionThatFits:[self getRegionForBounds:bounds]] animated:YES];
        if(self.routeLine){
            [self.mapView removeOverlay:self.routeLine];
            self.routeLine = nil;
            
        }
        self.routeLine = [MKPolyline polylineWithCoordinates:pointArr
                                                       count:[polyLine count]];
        
        [self.mapView addOverlay:self.routeLine];
        //[polyLine release];
        
        free(pointArr);
        directionsView.steps = [[[route objectForKey:@"legs"] lastObject] objectForKey:@"steps"];
        
        
        [SVProgressHUD dismissWithSuccess:[NSString stringWithFormat:@"%@ \n %@ ",[[[[route objectForKey:@"legs"] lastObject] objectForKey:@"distance"]objectForKey:@"text"],[[[[route objectForKey:@"legs"] lastObject] objectForKey:@"duration"]objectForKey:@"text"]] afterDelay:2];
        
        
    } else {
        [SVProgressHUD dismissWithError:@"Unknow error!" afterDelay:1];
        
    }
    
    [request release];
}

-(void)requestFailed:(ASIHTTPRequest *)request{
    
    [SVProgressHUD dismissWithError:@"Internet connection error!" afterDelay:1];
    [request release];
    
}


#pragma mark -
#pragma mark DirectionView Delegate

-(void)moveToPoint:(CLLocationCoordinate2D)location{
    
    [self.mapView setCenterCoordinate:location animated:YES];
    [self.mapView removeOverlay:circle];
    /* Need to find way to animate that overlay */
    circle = [MKCircle circleWithCenterCoordinate:location radius:50.f];
    [self.mapView addOverlay:circle];
   
}

#pragma mark -

-(void)dealloc{
    self.mapView.delegate = nil;
    self.routeLine = nil;
    self.startPoint = nil;
    self.endPoint = nil;
    self.strokeColor = nil;
    self.fillColor = nil;
    self.mapView = nil;
    [super dealloc];
}

@end
