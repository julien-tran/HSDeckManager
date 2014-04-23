//
//  HSDeckStatsViewController.h
//  HSDeckManager
//
//  Created by Julien Tran on 18/04/14.
//  Copyright (c) 2014 Julien Tran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPTPlot.h"

@class HSDeck;
@class HSStatsCell;

@interface HSDeckStatsViewController : UIViewController<CPTPlotDataSource,UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) HSDeck *deck;
@property (nonatomic, weak) IBOutlet HSStatsCell     *cardCell;

@end
