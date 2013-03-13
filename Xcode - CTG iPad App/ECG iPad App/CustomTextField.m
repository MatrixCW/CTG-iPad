//
//  CustomTextField.m
//  ECG iPad App
//
//  Created by David Tan on 15/2/13.
//  Copyright (c) 2013 David Tan. All rights reserved.
//

#import "CustomTextField.h"

@implementation CustomTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) drawPlaceholderInRect:(CGRect)rect {
    UIColor * color = [UIColor colorWithRed:55/255.0f green:105/255.0f blue:142/255.0f alpha:1.0f];
    [color setFill];
    [self.placeholder drawInRect:rect withFont:[UIFont boldSystemFontOfSize:12] lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
}

@end