//
//  HSDeckCell.m
//  HSDeckManager
//
//  Created by Minh-Hang LE on 23/04/14.
//  Copyright (c) 2014 Minh-Hang LE. All rights reserved.
//

#import "HSStatsCell.h"
#import "HSDeck.h"

@interface HSStatsCell ()
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;

@end

@implementation HSStatsCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateUIWithKey:(NSString *)key value:(NSNumber *)value
{
    self.infoLabel.text = key;
    self.valueLabel.text = [NSString stringWithFormat:@"%@",value];
}

@end