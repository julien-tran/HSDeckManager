//
//  HSDeckStatsViewController.m
//  HSDeckManager
//
//  Created by Julien Tran on 18/04/14.
//  Copyright (c) 2014 Julien Tran. All rights reserved.
//

#import "HSDeckStatsViewController.h"
#import "CorePlot-CocoaTouch.h"
#import "HSDeck.h"
#import "HSStatsCell.h"
#import "HSDataCenter.h"

#define X_VAL @"x"
#define Y_VAL @"y"
#define BAR_WIDTH               1
#define INTERVAL_AXE_X          10.0
#define INTERVAL_BETWEEN_BAR    7

#define INTERVAL_Y              @"10"
#define MAX_AXE_Y               15.0

@interface HSDeckStatsViewController ()
@property (nonatomic, retain) CPTXYGraph *barChart;
@property (nonatomic, retain) NSMutableArray *sampleArray;
@property (nonatomic, retain) NSTimer* timer;
@property (nonatomic, readwrite)   CGPoint moved;
@property (nonatomic, retain) NSArray *manaCostArray;
@property (weak, nonatomic) IBOutlet UITableView *startTableView;

@property (nonatomic, strong) NSFetchedResultsController *deckFetchedController;
@property (nonatomic, strong) NSMutableDictionary *statsDictionary;

@end

@implementation HSDeckStatsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Get info
    self.manaCostArray = [NSArray arrayWithObjects:@(1),@(2),@(5),@(10),@(4),@(6),@(8),@(9), nil];
    
    [self getGraphValues];
    [self buildGraph];
    self.statsDictionary = [mainDataCenter dictionaryStatsFromDeck:self.deck];
    [self.startTableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

/* Callback method when changes are made to the data */
- (void)controllerWillChangeContent:(NSFetchedResultsController*)controller
{
	[self.startTableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	[self.startTableView endUpdates];
}

#pragma mark - UITableview stats
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 11;
}

/* Load and initialize the cell representing the artists from its nib file.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *HSStatsCellID = @"HSStatsCellID";
    HSStatsCell *cell = (HSStatsCell*)[tableView dequeueReusableCellWithIdentifier:HSStatsCellID];
    
    if (nil == cell)
    {
        [[NSBundle mainBundle] loadNibNamed:@"HSStatsCell" owner:self options:nil];
        cell = self.cardCell;
        self.cardCell = nil;
    }
    // UPDATE
    NSString *key = [[self.statsDictionary allKeys] objectAtIndex:indexPath.row];
    [cell updateUIWithKey:key value:[self.statsDictionary objectForKey:key]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}


#pragma mark - Mana curve
- (void) buildGraph
{
    self.barChart = [[CPTXYGraph alloc] initWithFrame:CGRectMake(0, 0, 250, 150)];
    self.barChart.plotAreaFrame.masksToBorder = NO;
    self.barChart.plotAreaFrame.borderLineStyle = nil;
    self.barChart.plotAreaFrame.cornerRadius = 0.0f;
    
    self.barChart.paddingLeft = 0.0f;
    self.barChart.paddingRight = 0.0f;
    self.barChart.paddingTop = 0.0f;
    self.barChart.paddingBottom = 0.0f;
    
    self.barChart.plotAreaFrame.paddingLeft = 12.0;
    self.barChart.plotAreaFrame.paddingTop = 40.0;
    self.barChart.plotAreaFrame.paddingRight = 0.0;
    self.barChart.plotAreaFrame.paddingBottom = 30.0;
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) self.barChart.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0f) length:CPTDecimalFromDouble(INTERVAL_AXE_X)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0f) length:CPTDecimalFromDouble(MAX_AXE_Y)];

    [self configureAxes];
    
    CPTGraphHostingView *hostingView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(0, 30, 250, 150)];
    hostingView.hostedGraph = self.barChart;
    [self.view addSubview:hostingView];
    
    [self animateNow];
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
	// 2 - Create style, if necessary
	static CPTMutableTextStyle *style = nil;
	if (!style) {
		style = [CPTMutableTextStyle textStyle];
		style.color= [CPTColor blueColor];
		style.fontSize = 12.0f;
		style.fontName = @"Helvetica-Bold";
	}
    
    CPTPlotSpaceAnnotation *valueAnnotation = nil;
    for (NSNumber *mana in self.manaCostArray) {
        // 3 - Create annotation, if necessary
        NSNumber *x1 = [NSNumber numberWithInt:0];
        NSNumber *y1 = [NSNumber numberWithInt:0];
        NSArray *anchorPoint = [NSArray arrayWithObjects:x1, y1, nil];
        valueAnnotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:(CPTXYPlotSpace *) self.barChart.defaultPlotSpace anchorPlotPoint:anchorPoint];
        // 5 - Create text layer for annotation
        NSString *priceValue = [NSString stringWithFormat:@"%@",mana];
        CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:priceValue style:style];
        valueAnnotation.contentLayer = textLayer;
        // 7 - Get the anchor point for annotation
        NSInteger index = [self.manaCostArray indexOfObject:mana];
        CGFloat x = index + 0.2;
        NSNumber *anchorX = [NSNumber numberWithFloat:x];
        CGFloat y = [mana floatValue] + 2;
        NSNumber *anchorY = [NSNumber numberWithFloat:y];
        valueAnnotation.anchorPlotPoint = [NSArray arrayWithObjects:anchorX, anchorY, nil];
        // 8 - Add the annotation
        [self.barChart.plotAreaFrame.plotArea addAnnotation:valueAnnotation];
    }
}

- (void) animateNow
{
    CPTBarPlot *barPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor blueColor] horizontalBars:NO];
    barPlot.plotRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0) length:CPTDecimalFromDouble(INTERVAL_BETWEEN_BAR)];//xAxisLength
    barPlot.barOffset = CPTDecimalFromFloat(0.25f);
    barPlot.baseValue = CPTDecimalFromString(@"0");
    barPlot.barWidth =  CPTDecimalFromFloat(BAR_WIDTH);
    barPlot.cornerRadius = 2.0f;
    barPlot.dataSource = self;
    
    //adding animation here
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
    [anim setDuration:0.75f];
    anim.toValue = [NSNumber numberWithFloat:1];
    anim.fromValue = [NSNumber numberWithFloat:0.0f];
    anim.removedOnCompletion = NO;
    anim.delegate = self;
    anim.fillMode = kCAFillModeForwards;
    
    barPlot.anchorPoint = CGPointMake(0.0, 0.0);
    [barPlot addAnimation:anim forKey:@"grow"];
    [self.barChart addPlot:barPlot];// IMPORTANT here I added the plot data to the graph :) .
}


-(void) getGraphValues
{
    
    self.sampleArray = [[NSMutableArray alloc] initWithObjects:nil];
    
    for (NSNumber *yNb in self.manaCostArray)
    {
        double y = [yNb doubleValue];
        NSDictionary *sample = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithDouble:2],X_VAL,[NSNumber numberWithDouble:y],Y_VAL,nil];
        [self.sampleArray addObject:sample];
    }
}

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [self.sampleArray count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSDictionary *sample = [self.sampleArray objectAtIndex:index];

    if (fieldEnum == CPTScatterPlotFieldX)
        return [sample valueForKey:X_VAL];
    else
        return [sample valueForKey:Y_VAL];
}


-(void)configureAxes {
    CPTMutableTextStyle *textStyle = [CPTTextStyle textStyle];
    textStyle.color = [CPTColor grayColor];
    textStyle.fontSize = 16.0f;
    textStyle.textAlignment = CPTTextAlignmentCenter;
    self.barChart.titleTextStyle = textStyle;  // Error found here
    self.barChart.titleDisplacement = CGPointMake(0.0f, -10.0f);
    self.barChart.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)self.barChart.axisSet;
    CPTXYAxis *x = axisSet.xAxis;
    x.axisLineStyle = nil;
    x.majorTickLineStyle = nil;
    x.minorTickLineStyle = nil;
    x.majorIntervalLength = CPTDecimalFromString(@"20");
    x.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0");
    x.titleLocation = CPTDecimalFromFloat(20.0f);
    x.titleOffset = 25.0f;
    
    // Define some custom labels for the data elements
    x.labelRotation = M_PI/5;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    
    NSArray *customTickLocations = [NSArray arrayWithObjects:[NSDecimalNumber numberWithInt:0], [NSDecimalNumber numberWithInt:1], [NSDecimalNumber numberWithInt:2], [NSDecimalNumber numberWithInt:3], [NSDecimalNumber numberWithInt:4], [NSDecimalNumber numberWithInt:5], [NSDecimalNumber numberWithInt:6], [NSDecimalNumber numberWithInt:7],nil];
    
    NSArray *xAxisLabels = [NSArray arrayWithObjects:@"      0",@"      1", @"      2", @"      3", @"      4", @"      5",@"      6", @"      7+", nil];

    NSUInteger labelLocation = 0;
    
    NSMutableArray *customLabels = [NSMutableArray arrayWithCapacity:[xAxisLabels count]];
    for (NSNumber *tickLocation in customTickLocations)
    {
        CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText: [xAxisLabels objectAtIndex:labelLocation++] textStyle:x.labelTextStyle];
        newLabel.tickLocation = [tickLocation decimalValue];
        newLabel.offset = x.labelOffset + x.majorTickLength;
        [customLabels addObject:newLabel];
    }
    x.axisLabels =  [NSSet setWithArray:customLabels];
    
    CPTXYAxis *y = axisSet.yAxis;
    y.axisLineStyle = nil;
    y.majorTickLineStyle = nil;
    y.minorTickLineStyle = nil;
    y.majorIntervalLength = CPTDecimalFromString(INTERVAL_Y);
    y.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0");
    y.titleOffset = 40.0f;
    y.titleLocation = CPTDecimalFromFloat(150.0f);
    y.labelingPolicy = CPTAxisLabelingPolicyNone;
 }


@end
