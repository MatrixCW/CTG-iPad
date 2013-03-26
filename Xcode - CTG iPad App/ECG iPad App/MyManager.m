//
//  MyManager.m
//  ECG iPad App
//
//  Created by David Tan on 14/2/13.
//  Copyright (c) 2013 David Tan. All rights reserved.
//

#import "MyManager.h"
#import "FSNConnection.h"



#define FSN_QUEUED_CONNECTIONS 1

@interface MyManager ()
@property (strong, nonatomic) FSNConnection *connection;
@property (strong, nonatomic) FSNConnection *connection2;
@property (strong, nonatomic) FSNConnection *connection3;
@property (strong, nonatomic) FSNConnection *connection4;
@end

@implementation MyManager {
    NSUserDefaults *prefs;
    NSDictionary *updatedPatient;
}

@synthesize patientList, wardData, connection, connection2, connection3, connection4,historyData;

+ (id)sharedManager {
    static MyManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        patientList = [NSMutableArray array];
        wardData = [NSMutableArray array];
        historyData = [NSMutableArray array];
        prefs = [NSUserDefaults standardUserDefaults];
        if ([prefs objectForKey:@"patients"] == nil) {
            [self createPatientProfiles];
        }
        patientList = [[prefs objectForKey:@"patients"] mutableCopy];
        [self getPatients];
        [self updateWardData];
    }
    return self;
}

- (void)getPatients {
    [self.connection cancel];
    self.connection = [self makeConnectionFor:@"getPatients.php"];
    [self.connection start];
}

- (void)updateWardData {
    [self.connection2 cancel];
    self.connection2 = [self makeConnectionFor:@"getWardData.php"];
    [self.connection2 start];
}

- (void)updateCurrentWardData:(NSInteger)wardNumber{
    NSNumber *number = [NSNumber numberWithInt:wardNumber];
    NSString *stringValue = [number stringValue];
    [self.connection2 cancel];
    self.connection2 = [self makeConnectionFor:
                        [@"getWardDataWithNumber.php?id=" stringByAppendingString:
                                                                     stringValue]];
    [self.connection2 start];

}

- (void)getHistoryData:(NSString*)wardNumber {
    
    
    [self.connection4 cancel];
    self.connection4 = [self makeConnectionFor:[@"getHistoryData.php?" stringByAppendingString:wardNumber]];
    [self.connection4 start];
}

- (void)updatePatientListWithPatient:(NSDictionary *)patient {
    updatedPatient = patient;
    [self.connection3 cancel];
    NSDictionary *parsedPatient = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [patient objectForKey:@"id"], @"id",
                                   [patient objectForKey:@"IC"], @"IC",
                                   [patient objectForKey:@"Name"], @"Name",
                                   [patient objectForKey:@"D.O.B"], @"DOB",
                                   [patient objectForKey:@"Blood Group"], @"BloodGroup",
                                   [patient objectForKey:@"NOK Name"], @"NOKName",
                                   [patient objectForKey:@"NOK Contact"], @"NOKContact",
                                   [patient objectForKey:@"NOK Relationship"], @"NOKRelationship",
                                   nil];
    self.connection3 = [self updatePatientFor:parsedPatient];
    [self.connection3 start];
}

- (FSNConnection *)makeConnectionFor:(NSString *)scriptName {
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ec2-54-251-66-243.ap-southeast-1.compute.amazonaws.com/%@", scriptName]];;
    
    
    //NSLog(@"%@", url);
    return [FSNConnection withUrl:url
                           method:FSNRequestMethodPOST
                          headers:nil
                       parameters:nil
                       parseBlock:^id(FSNConnection *c, NSError **error) {
                           NSDictionary *d = [c.responseData arrayFromJSONWithError:error];
                           if(!d) return nil;
                           if (c.response.statusCode != 200) {
                               *error = [NSError errorWithDomain:@"FSAPIErrorDomain"
                                                            code:1
                                                        userInfo:[d objectForKey:@"meta"]];
                           }
                           //NSLog(@"%@",d);
                           return d;
                       }
                  completionBlock:^(FSNConnection *c) {
                      NSArray *array = (NSArray *)c.parseResult;
                      NSDictionary *dictionary = [array objectAtIndex:0];
                      
                      for (id object in [dictionary objectForKey:@"objects"]) {
                          if ([scriptName isEqual:@"getPatients.php"]) {
                              int index = [[object objectForKey:@"ward_id"] intValue];
                              [patientList replaceObjectAtIndex:index-1 withObject:object];
                          } else if([scriptName isEqualToString:@"getWardData.php"]){
                              [wardData addObject:object];
                          }
                          else {
                              
                              [self.historyData addObject:object];
                          }
                          
                      }
                      
                      if (![scriptName isEqual:@"getPatients.php"] && ![scriptName isEqualToString:@"getWardData.php"])
                          [self.myDelegate finished];
                  }
                    progressBlock:nil];
}

- (FSNConnection *)updatePatientFor:(NSDictionary *)patient {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ec2-54-251-66-243.ap-southeast-1.compute.amazonaws.com/updatePatient.php"]];
    return [FSNConnection withUrl:url
                           method:FSNRequestMethodPOST
                          headers:nil
                       parameters:patient
                       parseBlock:^id(FSNConnection *c, NSError **error) {
                           NSDictionary *d = [c.responseData arrayFromJSONWithError:error];
                           if(!d) return nil;
                           if (c.response.statusCode != 200) {
                               *error = [NSError errorWithDomain:@"FSAPIErrorDomain"
                                                            code:1
                                                        userInfo:[d objectForKey:@"meta"]];
                           }
                           return d;
                       }
                  completionBlock:^(FSNConnection *c) {
                      //NSLog(@"response: %@, type: %@", c.parseResult, [c.parseResult class]);
                  }
                    progressBlock:nil];
}

#pragma mark - Custom Methods

- (void)createPatientProfiles {
    NSMutableArray *patients = [[NSMutableArray alloc] initWithCapacity:8];
    for(int i = 0; i < 8; i++) {
        NSString *name = [NSString stringWithFormat:@"Person %i", i+1];
        NSString *nokName = [NSString stringWithFormat:@"NOK for Person %i", i+1];
        NSArray *keys = @[ @"Name", @"Blood Group", @"D.O.B", @"IC", @"Date Admitted", @"Attending Doctor", @"NOK Name", @"NOK Contact", @"NOK Relationship", @"ward_id", @"id"];
        NSArray *values = @[ name, @"Blood Group", @"D.O.B", @"IC", @"Date Admitted", @"Attending Doctor", nokName, @"Contact", @"Relationship", [NSString stringWithFormat:@"%i", i+1], @"nil"];
        NSDictionary *aPatient = [NSDictionary dictionaryWithObjects:values forKeys:keys];
        [patients addObject:aPatient];
    }
    [prefs setObject:patients forKey:@"patients"];
    [prefs synchronize];
}

- (void)createDataPoints {
    [prefs removeObjectForKey:@"dataPoints"];
    NSMutableArray *dataPoints = [[NSMutableArray alloc] initWithCapacity:5000];
    int a, b;
    for (int i = 0; i < 5000; i++) {
        NSArray *keys = @[ @"index", @"Heart Rate", @"Contraction Rate" ];
        NSString *index = [NSString stringWithFormat:@"%i", i];
        a = (i % 6 == 0) ? arc4random() : 0;
        b = (i % 23 == 0) ? arc4random() : 0;
        NSString *heartRate = [NSString stringWithFormat:@"%f", MIN(200, MAX(60,((sin(i/10))+a)*70+130))];
        NSString *contractionRate = [NSString stringWithFormat:@"%f", MIN(90, MAX(10, ((cos(i/20))+b)*50+50))];
        NSArray *values = @[ index, heartRate, contractionRate ];
        NSDictionary *dataPoint = [NSDictionary dictionaryWithObjects:values forKeys:keys];
        [dataPoints addObject:dataPoint];
    }
    [prefs setObject:dataPoints forKey:@"dataPoints"];
    [prefs synchronize];
}

@end
