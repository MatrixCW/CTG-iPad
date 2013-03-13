//
//  PatientCell.h
//  ECG iPad App
//
//  Created by David Tan on 14/2/13.
//  Copyright (c) 2013 David Tan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "CustomTextField.h"

@interface PatientCell : UITableViewCell <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UILabel *keyLabel;
@property (strong, nonatomic) IBOutlet UILabel *valueLabel;
@property (strong, nonatomic) IBOutlet CustomTextField *valueEditField;

@end
