//
//  ViewController.m
//  ECG iPad App
//
//  Created by David Tan on 14/2/13.
//  Copyright (c) 2013 David Tan. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ViewController.h"
#import "MyManager.h"
#define XRANGE 1000
#define X 180
#define Y1 160
#define Y2 100

@interface ViewController ()

@end

@implementation ViewController {
    MyManager *sharedManager;
    CPTXYGraph *graph, *graph2;
    NSMutableArray *dataForPlot;
    NSTimer *timer;
    int count;
    BOOL pauseGraph1, pauseGraph2;
}

@synthesize graphView, graphView2, segmentedControl, timerLabel;
@synthesize patientView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.NoDataWarning.alpha = 0.0;
    self.segmentedControl.selectedSegmentIndex = 0;
    sharedManager = [MyManager sharedManager];
    [sharedManager updateCurrentWardData:self.segmentedControl.selectedSegmentIndex + 1];
    sharedManager.myDelegate = self;
    dataForPlot = [NSMutableArray array];
    
    
    [self constructScatterPlots];
    [self startPlot];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Scatter Plot Methods

-(void)constructScatterPlots
{
    // Graph
    graph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CPTTheme *theme = [CPTTheme themeNamed:kCPTPlainWhiteTheme];
    [graph applyTheme:theme];
    graph.fill = [CPTFill fillWithColor:[CPTColor clearColor]];
    graph.plotAreaFrame.fill = [CPTFill fillWithColor:[CPTColor clearColor]];
    graph.paddingLeft   = 20.0;
    graph.paddingTop    = 30.0;
    graph.paddingRight  = 0.0;
    graph.paddingBottom = 0.0;
    graphView.hostedGraph = graph;
    
    // Graph Title
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color                = [CPTColor blueColor];
    titleStyle.fontSize             = 16.0f;
    graph.title                     = @"Fetal Heart Rate (bpm)";
    graph.titleTextStyle            = titleStyle;
    graph.titlePlotAreaFrameAnchor  = CPTRectAnchorTop;
    graph.titleDisplacement         = CGPointMake(0.0f, 12.0f);
    
    // Plot Space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    plotSpace.globalXRange          = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInt(-1000) length:CPTDecimalFromInt(1000+180)];
    plotSpace.xRange                = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInt(0) length:CPTDecimalFromInt(X)];
    plotSpace.globalYRange          = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInt(50) length:CPTDecimalFromInt(Y1)];
    plotSpace.yRange                = plotSpace.globalYRange;
    
    // Axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.majorIntervalLength         = CPTDecimalFromString(@"60"); // 60s
    x.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0.0");
    x.minorTicksPerInterval       = 5; // 10s
    CPTXYAxis *y = axisSet.yAxis;
    y.majorIntervalLength         = CPTDecimalFromString(@"20"); // 20bpm
    y.orthogonalCoordinateDecimal = CPTDecimalFromString(@"20.0");
    y.minorTicksPerInterval       = 4; // 5bpm
    
    // Grid pattern
    CPTMutableLineStyle *majorLine  = [CPTMutableLineStyle lineStyle];
    majorLine.lineWidth             = 1.0f;
    majorLine.lineColor             = [CPTColor redColor];
    CPTMutableLineStyle *minorLine  = [CPTMutableLineStyle lineStyle];
    minorLine.lineWidth             = 0.5f;
    minorLine.lineColor             = [CPTColor redColor];
    x.majorGridLineStyle            = majorLine;
    y.majorGridLineStyle            = majorLine;
    x.minorGridLineStyle            = minorLine;
    y.minorGridLineStyle            = minorLine;
    
    // Graph
    graph2 = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CPTTheme *theme2 = [CPTTheme themeNamed:kCPTPlainWhiteTheme];
    [graph2 applyTheme:theme2];
    graph2.fill = [CPTFill fillWithColor:[CPTColor clearColor]];
    graph2.plotAreaFrame.fill = [CPTFill fillWithColor:[CPTColor clearColor]];
    graph2.paddingLeft   = 20.0;
    graph2.paddingTop    = 30.0;
    graph2.paddingRight  = 0.0;
    graph2.paddingBottom = 0.0;
    graphView2.hostedGraph = graph2;
    
    // Graph Title
    CPTMutableTextStyle *titleStyle2= [CPTMutableTextStyle textStyle];
    titleStyle2.color               = [CPTColor blueColor];
    titleStyle2.fontSize            = 16.0f;
    graph2.title                    = @"Maternal Mean Arterial Pressure (mmHg)";
    graph2.titleTextStyle           = titleStyle2;
    graph2.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    graph2.titleDisplacement        = CGPointMake(0.0f, 12.0f);
    
    // Plot Space
    CPTXYPlotSpace *plotSpace2 = (CPTXYPlotSpace *)graph2.defaultPlotSpace;
    plotSpace2.allowsUserInteraction = YES;
    plotSpace2.globalXRange          = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInt(-XRANGE) length:CPTDecimalFromInt(XRANGE+X)];
    plotSpace2.xRange                = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInt(0) length:CPTDecimalFromInt(X)];
    plotSpace2.globalYRange          = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInt(0) length:CPTDecimalFromInt(Y2)];
    plotSpace2.yRange                = plotSpace2.globalYRange;
    
    // Axes
    CPTXYAxisSet *axisSet2 = (CPTXYAxisSet *)graph2.axisSet;
    CPTXYAxis *x2          = axisSet2.xAxis;
    x2.majorIntervalLength         = CPTDecimalFromString(@"60"); // 60s
    x2.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0.0");
    x2.minorTicksPerInterval       = 5; // 10s
    CPTXYAxis *y2 = axisSet2.yAxis;
    y2.majorIntervalLength         = CPTDecimalFromString(@"20"); // 20mmHg
    y2.orthogonalCoordinateDecimal = CPTDecimalFromString(@"20.0");
    y2.minorTicksPerInterval       = 1; // 10mmHg
    
    // Grid Pattern
    CPTMutableLineStyle *majorLine2 = [CPTMutableLineStyle lineStyle];
    majorLine2.lineWidth            = 1.0f;
    majorLine2.lineColor            = [CPTColor redColor];
    CPTMutableLineStyle *minorLine2 = [CPTMutableLineStyle lineStyle];
    minorLine2.lineWidth            = 0.5f;
    minorLine2.lineColor            = [CPTColor redColor];
    x2.majorGridLineStyle           = majorLine2;
    y2.majorGridLineStyle           = majorLine2;
    x2.minorGridLineStyle           = minorLine2;
    y2.minorGridLineStyle           = minorLine2;
}

- (void)updatePlots {
    // Plot Area
    if (!pauseGraph1) {
        if ([[graph allPlots] count]) [graph removePlot:[[graph allPlots] objectAtIndex:0]];
        CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
        dataSourceLinePlot.identifier = @"Plot 1";
        CPTMutableLineStyle *lineStyle = [dataSourceLinePlot.dataLineStyle mutableCopy];
        lineStyle.lineWidth              = 1.5f;
        lineStyle.lineColor              = [CPTColor blackColor];
        dataSourceLinePlot.dataLineStyle = lineStyle;
        dataSourceLinePlot.dataSource    = self;
        [graph addPlot:dataSourceLinePlot];
    }
    
    if (!pauseGraph2) {
        if ([[graph2 allPlots] count]) [graph2 removePlot:[[graph2 allPlots] objectAtIndex:0]];
        CPTScatterPlot *dataSourceLinePlot2 = [[CPTScatterPlot alloc] init];
        dataSourceLinePlot2.identifier    = @"Plot 2";
        CPTMutableLineStyle *lineStyle2    = [dataSourceLinePlot2.dataLineStyle mutableCopy];
        lineStyle2.lineWidth               = 1.5f;
        lineStyle2.lineColor               = [CPTColor blackColor];
        dataSourceLinePlot2.dataLineStyle = lineStyle2;
        dataSourceLinePlot2.dataSource    = self;
        [graph2 addPlot:dataSourceLinePlot2];
    }
}

- (void)removeOldPlots {
    if ([[graph allPlots] count]) [graph removePlot:[[graph allPlots] objectAtIndex:0]];
    if ([[graph2 allPlots] count]) [graph2 removePlot:[[graph2 allPlots] objectAtIndex:0]];
}

#pragma mark - Scatter Plot Data Source Methods

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return [dataForPlot count];
}

- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx {
    NSDecimalNumber *num = nil;
    if ([plot.identifier isEqual:@"Plot 1"]) {
        if (fieldEnum == CPTScatterPlotFieldX) {
            num = [NSDecimalNumber decimalNumberWithDecimal:
                   [[NSNumber numberWithInt:idx-count+180+1] decimalValue]];
        }
        else {
            num = [NSDecimalNumber decimalNumberWithString:[[dataForPlot objectAtIndex:idx] valueForKey:@"Heart Rate"]];
        }
    }
    else {
        if (fieldEnum == CPTScatterPlotFieldX) {
            num = [NSDecimalNumber decimalNumberWithDecimal:
                   [[NSNumber numberWithInt:idx-count+180+1] decimalValue]];
        }
        else {
            num = [NSDecimalNumber decimalNumberWithString:[[dataForPlot objectAtIndex:idx] valueForKey:@"Contraction Rate"]];
        }
    }
    return num;
}

#pragma mark - UISegmentedControl Methods

-(void)restoreHistoryButton{
    [self.historyButton setTitle:@"History" forState:UIControlStateNormal];
}

- (IBAction)segmentedControlIndexChanged {
    [self restoreHistoryButton];
    patientView.patient = [sharedManager.patientList objectAtIndex:self.segmentedControl.selectedSegmentIndex];
    [patientView.tableView reloadData];
    [self removeOldPlots];
    [self startPlot];
}

#pragma mark - Segue Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"patientView"]) {
        patientView = segue.destinationViewController;
    }
}

#pragma mark - Custom Methods

- (void)startPlot
{
    [timer invalidate];
    timer = nil;
    [dataForPlot removeAllObjects];
    [sharedManager.wardData removeAllObjects];
    count = 0;
    [self updateGraph];
    timer  = [NSTimer scheduledTimerWithTimeInterval:1
                                              target:self
                                            selector:@selector(updateGraph)
                                            userInfo:nil
                                             repeats:YES];
}

- (void)updateGraph {

    
    timerLabel.text = [NSString stringWithFormat:@"%i", count];
    
    if (sharedManager.wardData.count > count) {
        
        NSDictionary* wardInfo = [[sharedManager.wardData objectAtIndex:count] copy];
        NSString* wardNumber = [wardInfo valueForKey:@"Ward"];
       
        if([wardNumber intValue] == self.segmentedControl.selectedSegmentIndex + 1 ){
            
           
            if([[wardInfo valueForKey:@"id"] intValue] > [[[dataForPlot lastObject] valueForKey:@"id"] intValue]){
                
                [dataForPlot addObject:[sharedManager.wardData objectAtIndex:count]];
                self.NoDataWarning.alpha = 0.0;
            }
            else{
                
                self.NoDataWarning.alpha = 1.0;
                
            }
            
        }
        if ((count+1) % 15 == 0) {
            [sharedManager updateCurrentWardData:(self.segmentedControl.selectedSegmentIndex + 1)];
        }
        
        [self updatePlots];
        
        count++;
    }
    else{
        self.NoDataWarning.alpha = 1.0;
        [sharedManager updateCurrentWardData:(self.segmentedControl.selectedSegmentIndex + 1)];
    }
}

#pragma mark - UIGestureRecognizer Methods


- (IBAction)switchBetweenHistoryAndCurrentData:(id)sender{
    UIButton* switchButton = (UIButton*)sender;
    
    if([switchButton.titleLabel.text isEqualToString:@"History"]){
        [switchButton setTitle:@"Continue" forState:UIControlStateNormal];
        [self showHistoryData];
    }
    else{
        [switchButton setTitle:@"History" forState:UIControlStateNormal];
        [self startPlot];
    }
    
}

- (IBAction)showHistoryData{
    self.NoDataWarning.alpha = 0.0;
    [sharedManager.historyData removeAllObjects];
    timerLabel.text = @"0";
    [timer invalidate];
    timer = nil;
    [dataForPlot removeAllObjects];
    [sharedManager.wardData removeAllObjects];
    count = 0;
    [sharedManager getHistoryData:self.segmentedControl.selectedSegmentIndex+1];
    
}

-(void)finishedLoadPatient{
    
    NSLog(@"%@", [sharedManager.patientList objectAtIndex:0]);
    
    patientView.patient = [sharedManager.patientList objectAtIndex:self.segmentedControl.selectedSegmentIndex];
    [patientView.tableView reloadData];
    
   
    
}
-(void)finishedLoadHistory{
    
    
    [self removeOldPlots];
    
    
    timer  = [NSTimer scheduledTimerWithTimeInterval:0.001
                                              target:self
                                            selector:@selector(second)
                                            userInfo:nil
                                             repeats:YES];
    
    
}

-(void)second{
    
    count++;
    
    if(count < sharedManager.historyData.count){
        [dataForPlot addObject:[sharedManager.historyData objectAtIndex:count]];
        [self updatePlots];
    }
    else{
        [timer invalidate];
        timer = nil;
    }
    
}


- (IBAction)handleGraphScroll:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [recognizer locationInView:recognizer.view];
        pauseGraph1 = (point.y < 420);
        pauseGraph2 = !(point.y < 420);
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded) {
        pauseGraph1 = NO;
        pauseGraph2 = NO;
    }
}


- (IBAction)handleGraphTap:(UITapGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:recognizer.view];
    if (point.y < 420) {
        CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
        plotSpace.xRange          = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInt(0) length:CPTDecimalFromInt(X)];
    }
    else {
        CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph2.defaultPlotSpace;
        plotSpace.xRange          = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInt(0) length:CPTDecimalFromInt(X)];
    }
    
}

#pragma mark - UIGestureRecognizerDelegate Methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end