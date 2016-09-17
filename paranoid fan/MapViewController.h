//
//  MapViewController.h
//  paranoid fan
//
//  Created by XingGao on 2015-08-28.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>
#import <MapKit/MapKit.h>
#import "DataHandler.h"
#import "InboxViewController.h"

@interface MapViewController : UIViewController<UISearchBarDelegate, CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, GMSMapViewDelegate>

- (IBAction)ZoomIn:(id)sender;
- (IBAction)ZoomOut:(id)sender;
- (IBAction)CurrentLocation:(id)sender;

@end
