//
//  PatientViewController.h
//  ECG iPad App
//
//  Created by David Tan on 14/2/13.
//  Copyright (c) 2013 David Tan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PatientViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UIButton *editButton;
@property (strong, nonatomic) NSDictionary *patient;
@property (assign, nonatomic) BOOL isForEdit;

@end
