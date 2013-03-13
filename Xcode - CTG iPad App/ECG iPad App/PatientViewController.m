//
//  PatientViewController.m
//  ECG iPad App
//
//  Created by David Tan on 14/2/13.
//  Copyright (c) 2013 David Tan. All rights reserved.
//

#import "PatientViewController.h"
#import "PatientCell.h"
#import "ViewController.h"
#import "MyManager.h"

@interface PatientViewController ()

@property (strong, nonatomic) IBOutlet UIButton *saveButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;

@end

@implementation PatientViewController {
    NSMutableDictionary *patientCopy;
    MyManager *sharedManager;
}

@synthesize editButton, patient;
@synthesize saveButton, cancelButton;
@synthesize isForEdit;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    sharedManager = [MyManager sharedManager];
    if (self.isForEdit) patientCopy = [patient mutableCopy];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 6;
    }
    else {
        return 3;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return (section == 0) ? @"Patient Information" : @"NOK Information";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PatientCells";
    PatientCell *cell = (PatientCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) {
        cell = [[PatientCell alloc] init];
    }
    [self configureCell:cell forIndexPath:indexPath];
    
    return cell;
}

- (PatientCell *)configureCell:(PatientCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    NSString *prefix = @"";
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                cell.keyLabel.text = @"Name";
                break;
            case 1:
                cell.keyLabel.text = @"Blood Group";
                break;
            case 2:
                cell.keyLabel.text = @"D.O.B";
                break;
            case 3:
                cell.keyLabel.text = @"IC";
                break;
            case 4:
                cell.keyLabel.text = @"Date Admitted";
                break;
            case 5:
                cell.keyLabel.text = @"Attending Doctor";
                break;
                
            default:
                break;
        }
    }
    else {
        prefix = @"NOK ";
        switch (indexPath.row) {
            case 0:
                cell.keyLabel.text = @"Name";
                break;
            case 1:
                cell.keyLabel.text = @"Contact";
                break;
            case 2:
                cell.keyLabel.text = @"Relationship";
                break;
                
            default:
                break;
        }
    }
    NSString *value = [self.patient objectForKey:[NSString stringWithFormat:@"%@%@", prefix, cell.keyLabel.text]];
    if (self.isForEdit) {
        cell.valueEditField.placeholder = value;
        [cell.valueEditField setHidden:!self.isForEdit];
        cell.valueLabel.hidden = self.isForEdit;
    }
    else cell.valueLabel.text = value;
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

#pragma mark - Segue Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"editPatient"]) {
        PatientViewController *editPatientController = segue.destinationViewController;
        editPatientController.patient = patient;
        editPatientController.isForEdit = YES;
    }
}

#pragma mark - Custom Methods

- (IBAction)enterEditMode:(id)sender {
    if (![[patient objectForKey:@"id"] isEqual:@"nil"]) {
        [self performSegueWithIdentifier:@"editPatient" sender:self];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Warning"
                              message: @"There is no patient to edit!"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender {
    for (int section = 0; section < [self.tableView numberOfSections]; section++) {
        for (int row = 0; row < [self.tableView numberOfRowsInSection:section]; row++) {
            NSIndexPath *cellPath = [NSIndexPath indexPathForRow:row inSection:section];
            PatientCell *cell = (PatientCell *)[self.tableView cellForRowAtIndexPath:cellPath];
            if (cell.valueEditField.text.length) {
                NSString *prefix = (section > 0) ? @"NOK " : @"";
                NSString *key = [NSString stringWithFormat:@"%@%@", prefix, cell.keyLabel.text];
                [patientCopy setObject:cell.valueEditField.text forKey:key];
            }
        }
    }
    
    int viewCount = [[self.navigationController viewControllers] count];
    ViewController *viewController = (ViewController *)[[self.navigationController viewControllers] objectAtIndex:viewCount-2];
    int patientIndex = viewController.segmentedControl.selectedSegmentIndex;
    [sharedManager.patientList replaceObjectAtIndex:patientIndex withObject:patientCopy];
    viewController.patientView.patient = patientCopy;
    [viewController.patientView.tableView reloadData];
    [sharedManager updatePatientListWithPatient:patientCopy];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
