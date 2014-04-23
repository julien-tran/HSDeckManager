//
//  HSDeckCell.h
//  HSDeckManager
//
//  Created by Julien Tran on 18/04/14.
//  Copyright (c) 2014 Julien Tran. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HSDeck;

@interface HSStatsCell : UITableViewCell

- (void)updateUIWithKey:(NSString *)key value:(NSNumber *)value;

@end