//
//  ViewController.m
//  MapDirectionsViewExample
//
//  Created by Kamil Pyć on 11-12-02.
//  Copyright (c) 2011 Kamil Pyć. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //2 example points
    MKPointAnnotation* startPoint = [[[MKPointAnnotation alloc] init] autorelease];
    startPoint.title = @"Start Point";
    startPoint.coordinate = CLLocationCoordinate2DMake(51.110, 17.031509);
    
    self.startPoint = startPoint;
    
    MKPointAnnotation* endPoint = [[[MKPointAnnotation alloc] init] autorelease];
    endPoint.title = @"End Point";
    endPoint.coordinate = CLLocationCoordinate2DMake(51.149, 17.030);
    
    self.endPoint = endPoint;
    
    
    [self.mapView addAnnotation:self.startPoint];
    [self.mapView addAnnotation:self.endPoint];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
