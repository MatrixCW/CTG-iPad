//
//  PatientCell.m
//  ECG iPad App
//
//  Created by David Tan on 14/2/13.
//  Copyright (c) 2013 David Tan. All rights reserved.
//

#import "PatientCell.h"

@implementation PatientCell {
    NSString *placeHolderText;
}

@synthesize keyLabel, valueLabel, valueEditField;


- (id)init {
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PatientCell" owner:self options:nil];
    PatientCell *cell = [topLevelObjects objectAtIndex:0];
    [cell.valueEditField setValue:[UIColor redColor] forKeyPath:@"_placeholderLabel.textColor"];
    return cell;
}

#pragma mark - UITextFieldDelegate Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    placeHolderText = textField.placeholder;
    textField.placeholder = nil;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    textField.placeholder = placeHolderText;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (range.length == 1) {
        return YES;
    }
    else {
        NSMutableCharacterSet *charactersToKeep = [NSMutableCharacterSet alphanumericCharacterSet];
        [charactersToKeep addCharactersInString:@" ./+-"];
        return ([string stringByTrimmingCharactersInSet:[charactersToKeep invertedSet]].length > 0);
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

@end