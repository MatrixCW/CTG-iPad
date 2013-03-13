//
//  ViewController.h
//  ECG iPad App
//
//  Created by David Tan on 14/2/13.
//  Copyright (c) 2013 David Tan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#import "PatientViewController.h"

@interface ViewController : UIViewController <CPTScatterPlotDataSource, CPTScatterPlotDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet CPTGraphHostingView *graphView;
@property (strong, nonatomic) IBOutlet CPTGraphHostingView *graphView2;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic) IBOutlet UILabel *timerLabel;
@property (strong, nonatomic) PatientViewController *patientView;

- (IBAction)handleGraphScroll:(UIPanGestureRecognizer *)recognizer;
- (IBAction)handleGraphTap:(UITapGestureRecognizer *)recognizer;

@end
