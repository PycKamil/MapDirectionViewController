//
//  MapDirectionsView.h
//  
//
//  Created by Kamil Pyć on 11-12-02.
//  Copyright (c) 2011 Kamil Pyć. All rights reserved.
//
#import <MapKit/MapKit.h>
#import "ASIHTTPRequest.h"
#import "DirectionsView.h"
@interface MapDirectionsViewController : UIViewController <ASIHTTPRequestDelegate, MKMapViewDelegate, DirectionsViewDelegate>
{
    
    DirectionsView *directionsView;
    MKCircle *circle;
    
}


/* Defines start point for route */
@property (nonatomic,assign)    MKPointAnnotation* startPoint;
/* Defines end point for route */
@property (nonatomic,assign)    MKPointAnnotation* endPoint;
/* Defines route line fill color */
@property (nonatomic,retain)    UIColor *fillColor;
/* Defines route stroke color */
@property (nonatomic,retain)    UIColor *strokeColor;
/* Defines line  width*/
@property (nonatomic, assign)   CGFloat lineWidth;
/* Defines is route should be for driving mode (NO) or for walking mode (YES) */
@property (nonatomic, assign)   BOOL walkingMode;
/* Defines route line */
@property (nonatomic, retain)   MKPolyline *routeLine;
/* Define mapView */
@property (nonatomic, retain)   MKMapView *mapView;


-(void)calculateDirections;

@end
