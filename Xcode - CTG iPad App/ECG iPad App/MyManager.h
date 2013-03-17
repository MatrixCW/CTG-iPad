//
//  MyManager.h
//  ECG iPad App
//
//  Created by David Tan on 14/2/13.
//  Copyright (c) 2013 David Tan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "getLargeDataFinishedProtocol.h"

@interface MyManager : NSObject

@property (strong, nonatomic) NSMutableArray *patientList;
@property (strong, nonatomic) NSMutableArray *wardData;
@property (strong, nonatomic) NSMutableArray *historyData;

@property id<getLargeDataFinishedProtocol> myDelegate;


+ (id)sharedManager;

- (void)getPatients;
- (void)updatePatientListWithPatient:(NSDictionary *)patient;
- (void)updateWardData;
- (void)getHistoryData:(NSString*)wardNumber;
@end
